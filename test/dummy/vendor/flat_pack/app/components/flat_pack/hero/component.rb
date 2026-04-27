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

      renders_one :actions_slot
      renders_one :badge_slot

      undef_method :with_actions_slot, :with_actions_slot_content
      undef_method :with_badge_slot, :with_badge_slot_content

      def actions(**args, &block)
        return actions_slot if args.empty? && !block

        set_slot(:actions_slot, nil, **args, &block)
      end

      def badge(**args, &block)
        return badge_slot if args.empty? && !block

        set_slot(:badge_slot, nil, **args, &block)
      end

      def initialize(
        variant: :centered,
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
        @tagline = tagline
        @headline = headline
        @description = description
        @image_alt = image_alt
        @image_url = image_url ? FlatPack::AttributeSanitizer.sanitize_url(image_url) : nil
        @background_image_url = background_image_url ? FlatPack::AttributeSanitizer.sanitize_url(background_image_url) : nil
        @background = sanitize_background(background)
        @tiles = Array(tiles).map { |t| t.merge(url: FlatPack::AttributeSanitizer.sanitize_url(t[:url])) }

        validate_variant!
      end

      def call
        send(:"render_#{@variant}")
      end

      private

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
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
          class: "text-sm font-semibold uppercase tracking-widest text-[var(--surface-muted-content-color)]")
      end

      def render_headline
        return nil unless @headline.present?

        content_tag(:h1, @headline,
          class: "mt-2 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-[var(--surface-content-color)]")
      end

      def render_description
        return nil unless @description.present?

        content_tag(:p, @description,
          class: "mt-6 text-lg sm:text-xl text-[var(--surface-muted-content-color)]")
      end

      def render_actions_block(extra_classes: "")
        return nil unless actions_slot?

        content_tag(:div, actions, class: "mt-10 flex flex-col sm:flex-row gap-4 #{extra_classes}".strip)
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
        content_tag(:section, **merge_attributes(class: "w-full px-6 py-24 text-center", style: background_style)) do
          content_tag(:div, class: "max-w-4xl mx-auto") do
            safe_join([
              render_badge_content,
              render_tagline,
              render_headline,
              render_description,
              render_actions_block(extra_classes: "justify-center")
            ].compact)
          end
        end
      end

      def render_centered_image
        content_tag(:section, **merge_attributes(class: "relative overflow-hidden min-h-[560px] flex items-center justify-center", style: background_style)) do
          safe_join([
            content_tag(:div, nil,
              class: "absolute inset-0 bg-cover bg-center",
              style: @background_image_url ? "background-image: url('#{@background_image_url}')" : nil),
            content_tag(:div, nil, class: "absolute inset-0 bg-black/60"),
            content_tag(:div, class: "relative z-10 text-center text-white px-6 py-24") do
              safe_join([
                render_badge_content,
                render_tagline,
                content_tag_if(@headline, :h1, @headline,
                  class: "mt-2 text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-white"),
                content_tag_if(@description, :p, @description,
                  class: "mt-6 text-lg sm:text-xl text-white/80"),
                render_actions_block(extra_classes: "justify-center")
              ].compact)
            end
          ].compact)
        end
      end

      def render_screenshot
        content_tag(:section, **merge_attributes(class: "px-6 py-24", style: background_style)) do
          safe_join([
            content_tag(:div, class: "max-w-2xl mx-auto text-center") do
              safe_join([
                render_badge_content,
                render_tagline,
                render_headline,
                render_description
              ].compact)
            end,
            (content_tag(:div, render_actions_block(extra_classes: "justify-center"), class: "mt-10 flex justify-center") if actions_slot?),
            (@image_url ? content_tag(:div, class: "mt-16 max-w-5xl mx-auto rounded-xl shadow-2xl overflow-hidden") {
              image_tag(@image_url, alt: @image_alt, class: "w-full object-cover")
            } : nil)
          ].compact)
        end
      end

      def render_split_image
        content_tag(:section, **merge_attributes(class: "grid lg:grid-cols-2 min-h-[540px]", style: background_style)) do
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
        content_tag(:section, **merge_attributes(class: "relative overflow-hidden py-24", style: background_style)) do
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
              @image_url ? image_tag(@image_url, alt: @image_alt, class: "w-full rounded-xl object-cover") : "".html_safe
            end
          ])
        end
      end

      def render_image_tiles
        content_tag(:section, **merge_attributes(class: "grid lg:grid-cols-2 gap-16 items-center py-24", style: background_style)) do
          safe_join([
            content_tag(:div, render_text_block, class: "px-16"),
            content_tag(:div, class: "grid grid-cols-2 gap-4 pr-16") do
              safe_join(@tiles.first(4).map { |tile|
                tile[:url] ? image_tag(tile[:url], alt: tile[:alt].to_s, class: "rounded-lg object-cover aspect-square w-full") : "".html_safe
              })
            end
          ])
        end
      end

      def render_offset_image
        content_tag(:section, **merge_attributes(class: "overflow-hidden py-24", style: background_style)) do
          content_tag(:div, class: "lg:grid lg:grid-cols-2 gap-16 items-start px-16") do
            safe_join([
              content_tag(:div, render_text_block, class: ""),
              content_tag(:div, class: "relative mt-12 lg:mt-0") do
                @image_url ? image_tag(@image_url, alt: @image_alt, class: "w-full rounded-xl shadow-2xl object-cover lg:-mr-24") : "".html_safe
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
