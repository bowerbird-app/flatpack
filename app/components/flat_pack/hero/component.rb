# frozen_string_literal: true

module FlatPack
  module Hero
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[
        centered
        centered_image
        screenshot
        split_image
        angled_image
        image_tiles
        offset_image
      ].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-left" "text-center" "justify-start" "justify-center"
      # "ps-[max(2rem,env(safe-area-inset-left))]" "sm:ps-10" "lg:ps-16" "pe-6" "py-16" "px-6" "leading-tight" "text-2xl"
      # "fp-hero-overlay-on-light"
      ALIGNS = {
        left: {
          text: "text-left",
          actions: "justify-start",
          canvas: "justify-start",
          overlay_copy: "ps-[max(2rem,env(safe-area-inset-left))] pe-6 py-16 sm:ps-10 lg:ps-16 max-w-2xl w-full"
        },
        center: {
          text: "text-center",
          actions: "justify-center",
          canvas: "justify-center",
          overlay_copy: "px-6 py-16"
        }
      }.freeze

      ONS = {
        dark: {overlay: ""},
        light: {overlay: "fp-hero-overlay-on-light"}
      }.freeze

      renders_one :actions_slot
      renders_one :badge_slot

      undef_method :with_actions_slot, :with_actions_slot_content
      undef_method :with_badge_slot, :with_badge_slot_content

      def slot(**args, &block)
        return actions_slot if args.empty? && !block

        set_slot(:actions_slot, nil, **args, &block)
      end

      def slot?
        actions_slot?
      end

      def actions(**args, &block)
        warn_deprecated_api(:actions, :slot)
        slot(**args, &block)
      end

      def badge(**args, &block)
        return badge_slot if args.empty? && !block

        set_slot(:badge_slot, nil, **args, &block)
      end

      def initialize(
        variant: :centered,
        align: :center,
        on: :dark,
        tagline: nil,
        headline: nil,
        description: nil,
        image_url: nil,
        image_alt: "",
        background_image_url: nil,
        background: nil,
        tiles: [],
        **system_arguments
      )
        super(**system_arguments)
        @variant = variant.to_sym
        @align = align.to_sym
        @on = on.to_sym
        @tagline = tagline
        @headline = headline
        @description = description
        @image_alt = image_alt
        @image_url = image_url ? FlatPack::AttributeSanitizer.sanitize_url(image_url) : nil
        @background_image_url = background_image_url ? FlatPack::AttributeSanitizer.sanitize_url(background_image_url) : nil
        @background = sanitize_background(background)
        @tiles = Array(tiles).map { |t| t.merge(url: FlatPack::AttributeSanitizer.sanitize_url(t[:url])) }

        validate_variant!
        validate_align!
        validate_on!
      end

      def call
        send(:"render_#{@variant}")
      end

      private

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
      end

      def validate_align!
        return if ALIGNS.key?(@align)

        raise ArgumentError, "Invalid align: #{@align}. Must be one of: #{ALIGNS.keys.join(", ")}"
      end

      def validate_on!
        return if ONS.key?(@on)

        raise ArgumentError, "Invalid on: #{@on}. Must be one of: #{ONS.keys.join(", ")}"
      end

      def align_row
        ALIGNS.fetch(@align)
      end

      def on_row
        ONS.fetch(@on)
      end

      def combined_style
        [html_attributes[:style], background_style].compact_blank.join("; ").presence
      end

      def overlay_section_class
        [
          "fp-hero-overlay relative overflow-hidden min-h-[560px] flex items-center",
          align_row[:canvas],
          on_row[:overlay]
        ].compact_blank.join(" ")
      end

      def overlay_inner_margin_class
        (@align == :left) ? "mr-auto" : "mx-auto"
      end

      def centered_image_copy_class
        [
          "relative z-10",
          align_row[:text],
          "text-[var(--hero-overlay-text-color)]",
          align_row[:overlay_copy]
        ].join(" ")
      end

      def overlay_headline_class
        wrap = (@align == :left) ? "fp-text-pretty" : "fp-text-balance"
        [
          "mt-2 text-[length:var(--text-4xl)] sm:text-[length:var(--text-5xl)] font-semibold tracking-tight leading-tight text-[var(--hero-overlay-text-color)]",
          wrap
        ].join(" ")
      end

      def overlay_description_class
        "mt-6 text-2xl text-[var(--hero-overlay-muted-text-color)] fp-text-pretty"
      end

      def overlay_wash
        if @align == :left
          content_tag(:div, nil, class: "absolute inset-0", style: "background: var(--hero-overlay-left-background)")
        else
          content_tag(:div, nil, class: "absolute inset-0 bg-[var(--hero-overlay-background-color)]")
        end
      end

      def render_overlay_tagline
        return nil unless @tagline.present?

        content_tag(:p, @tagline,
          class: "text-sm font-medium text-[var(--hero-overlay-muted-text-color)]")
      end

      # Strip url() functions to prevent CSS-based URL injection.
      # Colors and gradients don't need url(), so this is safe to strip entirely.
      def sanitize_background(value)
        return nil if value.nil? || value.to_s.strip.empty?

        value.to_s.gsub(/url\s*\([^)]*\)/i, "").strip.presence
      end

      def background_style
        return nil unless @background.present?

        "background: #{@background}"
      end

      # ─── shared text-block helpers ───────────────────────────────────────────

      def render_badge_content
        return nil unless badge_slot?

        content_tag(:div, badge, class: "mb-4")
      end

      def render_tagline
        return nil unless @tagline.present?

        content_tag(:p, @tagline,
          class: "text-sm font-medium text-[var(--surface-muted-content-color)]")
      end

      def render_headline
        return nil unless @headline.present?

        content_tag(:h1, @headline,
          class: "mt-2 text-[length:var(--text-4xl)] sm:text-[length:var(--text-5xl)] font-semibold tracking-tight text-[var(--surface-content-color)] fp-text-balance")
      end

      def render_description
        return nil unless @description.present?

        content_tag(:p, @description,
          class: "mt-6 text-lg text-[var(--surface-muted-content-color)] fp-text-pretty")
      end

      def render_actions_block(extra_classes: "")
        return nil unless slot?

        content_tag(:div, slot, class: "mt-10 flex flex-col sm:flex-row gap-4 #{extra_classes}".strip)
      end

      def render_text_block
        safe_join([
          render_badge_content,
          render_tagline,
          render_headline,
          render_description,
          render_actions_block
        ].compact)
      end

      # ─── variant renderers ───────────────────────────────────────────────────

      def render_centered
        content_tag(:section, **merge_attributes(class: "w-full px-6 py-24 #{align_row[:text]}", style: combined_style)) do
          content_tag(:div, class: "max-w-4xl #{overlay_inner_margin_class}") do
            safe_join([
              render_badge_content,
              render_tagline,
              render_headline,
              render_description,
              render_actions_block(extra_classes: align_row[:actions])
            ].compact)
          end
        end
      end

      def render_centered_image
        content_tag(:section, **merge_attributes(class: overlay_section_class, style: combined_style)) do
          safe_join([
            content_tag(:div, nil,
              class: "absolute inset-0 bg-cover bg-center",
              style: @background_image_url ? "background-image: url('#{@background_image_url}')" : nil),
            overlay_wash,
            content_tag(:div, class: centered_image_copy_class) do
              safe_join([
                render_badge_content,
                render_overlay_tagline,
                content_tag_if(@headline, :h1, @headline, class: overlay_headline_class),
                content_tag_if(@description, :p, @description, class: overlay_description_class),
                render_actions_block(extra_classes: align_row[:actions])
              ].compact)
            end
          ].compact)
        end
      end

      def render_screenshot
        content_tag(:section, **merge_attributes(class: "px-6 py-24", style: combined_style)) do
          safe_join([
            content_tag(:div, class: "max-w-2xl #{overlay_inner_margin_class} #{align_row[:text]}") do
              safe_join([
                render_badge_content,
                render_tagline,
                render_headline,
                render_description
              ].compact)
            end,
            (content_tag(:div, render_actions_block(extra_classes: align_row[:actions]), class: "mt-10 flex #{align_row[:actions]}") if slot?),
            (@image_url ? content_tag(:div, class: "mt-16 max-w-5xl mx-auto rounded-[var(--radius-xl)] shadow-2xl overflow-hidden") {
              image_tag(@image_url, alt: @image_alt, class: "w-full object-cover")
            } : nil)
          ].compact)
        end
      end

      def render_split_image
        content_tag(:section, **merge_attributes(class: "grid lg:grid-cols-2 min-h-[540px]", style: combined_style)) do
          safe_join([
            content_tag(:div, class: "flex flex-col justify-center px-16 py-24 lg:pr-16") do
              render_text_block
            end,
            content_tag(:div, class: "relative min-h-[300px] lg:min-h-full") do
              @image_url ? image_tag(@image_url, alt: @image_alt, class: "absolute inset-0 w-full h-full object-cover") : "".html_safe
            end
          ])
        end
      end

      def render_angled_image
        content_tag(:section, **merge_attributes(class: "relative overflow-hidden py-24", style: combined_style)) do
          safe_join([
            content_tag(:div, class: "lg:grid lg:grid-cols-2 items-center px-16") do
              content_tag(:div, render_text_block, class: "")
            end,
            content_tag(:div, class: "hidden lg:block absolute right-0 top-0 h-full w-1/2") do
              safe_join([
                (@image_url ? image_tag(@image_url, alt: @image_alt, class: "w-full h-full object-cover") : "".html_safe),
                content_tag(:div, nil,
                  class: "absolute inset-y-0 left-0 w-20 bg-[var(--surface-background-color)]",
                  style: "clip-path: polygon(0 0, 100% 0, 0 100%)")
              ].compact)
            end,
            content_tag(:div, class: "lg:hidden mt-12") do
              @image_url ? image_tag(@image_url, alt: @image_alt, class: "w-full rounded-[var(--radius-xl)] object-cover") : "".html_safe
            end
          ])
        end
      end

      def render_image_tiles
        content_tag(:section, **merge_attributes(class: "grid lg:grid-cols-2 gap-16 items-center py-24", style: combined_style)) do
          safe_join([
            content_tag(:div, render_text_block, class: "px-16"),
            content_tag(:div, class: "grid grid-cols-2 gap-4 pr-16") do
              safe_join(@tiles.first(4).map { |tile|
                tile[:url] ? image_tag(tile[:url], alt: tile[:alt].to_s, class: "rounded-[var(--radius-lg)] object-cover aspect-square w-full") : "".html_safe
              })
            end
          ])
        end
      end

      def render_offset_image
        content_tag(:section, **merge_attributes(class: "overflow-hidden py-24", style: combined_style)) do
          content_tag(:div, class: "lg:grid lg:grid-cols-2 gap-16 items-start px-16") do
            safe_join([
              content_tag(:div, render_text_block, class: ""),
              content_tag(:div, class: "relative mt-12 lg:mt-0") do
                @image_url ? image_tag(@image_url, alt: @image_alt, class: "w-full rounded-[var(--radius-xl)] shadow-2xl object-cover lg:-mr-24") : "".html_safe
              end
            ])
          end
        end
      end

      # ─── utility ─────────────────────────────────────────────────────────────

      def content_tag_if(value, tag, content, **options)
        return nil unless value.present?

        content_tag(tag, content, **options)
      end
    end
  end
end
