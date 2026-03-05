# frozen_string_literal: true

module FlatPack
  module Carousel
    class Component < FlatPack::BaseComponent
      SLIDE_TYPES = %i[image video html].freeze
      TRANSITIONS = %i[slide fade].freeze
      THUMBS_POSITIONS = %i[top bottom].freeze
      THUMBS_ALIGNMENTS = %i[start center end].freeze
      CAPTION_MODES = %i[below overlay].freeze
      DEFAULT_ARIA_LABEL = "Carousel"

      SANITIZED_HTML_TAGS = %w[
        p div span a ul ol li strong em b i u br
        h1 h2 h3 h4 h5 h6
        code pre blockquote
        form label input
      ].freeze

      SANITIZED_HTML_ATTRIBUTES = %w[
        class id title
        href rel target
        aria-label aria-hidden aria-current
        for type name value placeholder required disabled autocomplete
        aria-invalid aria-describedby
      ].freeze

      def initialize(
        slides:,
        initial_index: 0,
        show_thumbs: false,
        thumbs_position: :bottom,
        thumbs_alignment: :center,
        show_indicators: true,
        show_controls: true,
        autoplay: false,
        autoplay_interval_ms: 5000,
        pause_on_hover: true,
        pause_on_focus: true,
        loop: false,
        transition: :slide,
        aspect_ratio: "16/9",
        responsive: true,
        touch_swipe: true,
        show_captions: true,
        caption_mode: :below,
        aria_label: DEFAULT_ARIA_LABEL,
        **system_arguments
      )
        super(**system_arguments)

        @slides = normalize_slides(slides)
        @show_thumbs = !!show_thumbs
        @thumbs_position = thumbs_position.to_sym
        @thumbs_alignment = thumbs_alignment.to_sym
        @show_indicators = !!show_indicators
        @show_controls = !!show_controls
        @autoplay = !!autoplay
        @autoplay_interval_ms = normalize_interval(autoplay_interval_ms)
        @pause_on_hover = !!pause_on_hover
        @pause_on_focus = !!pause_on_focus
        @loop = !!loop
        @transition = transition.to_sym
        @aspect_ratio = normalize_aspect_ratio(aspect_ratio)
        @responsive = !!responsive
        @touch_swipe = !!touch_swipe
        @show_captions = !!show_captions
        @caption_mode = caption_mode.to_sym
        @aria_label = aria_label.presence || DEFAULT_ARIA_LABEL
        @initial_index = normalize_initial_index(initial_index)

        validate_configuration!
      end

      def call
        content_tag(:section, **carousel_attributes) do
          safe_join([
            (@show_thumbs && @thumbs_position == :top) ? render_thumbs : nil,
            render_viewport,
            (@show_captions && @caption_mode == :below) ? render_below_caption : nil,
            (@show_thumbs && @thumbs_position == :bottom) ? render_thumbs : nil
          ].compact)
        end
      end

      private

      def carousel_attributes
        merge_attributes(
          class: root_classes,
          data: {
            controller: "flat-pack--carousel",
            flat_pack__carousel_initial_index_value: @initial_index,
            flat_pack__carousel_loop_value: @loop,
            flat_pack__carousel_autoplay_value: @autoplay,
            flat_pack__carousel_autoplay_interval_value: @autoplay_interval_ms,
            flat_pack__carousel_pause_on_hover_value: @pause_on_hover,
            flat_pack__carousel_pause_on_focus_value: @pause_on_focus,
            flat_pack__carousel_touch_swipe_value: @touch_swipe,
            flat_pack__carousel_transition_value: @transition
          }
        )
      end

      def root_classes
        classes(
          "flat-pack-carousel relative w-full",
          @responsive ? "max-w-full" : nil
        )
      end

      def render_viewport
        content_tag(:div,
          class: viewport_classes,
          style: viewport_style,
          tabindex: 0,
          role: "region",
          aria: {label: @aria_label},
          data: {
            flat_pack__carousel_target: "viewport",
            action: "keydown->flat-pack--carousel#handleKeydown"
          }) do
          safe_join([
            render_slides,
            (@show_controls ? render_controls : nil),
            render_counter,
            (@show_indicators ? render_indicators : nil),
            ((@show_captions && @caption_mode == :overlay) ? render_overlay_caption : nil)
          ].compact)
        end
      end

      def render_slides
        content_tag(:div, class: slide_frame_classes, data: {flat_pack__carousel_target: "frame"}) do
          safe_join(@slides.map.with_index { |slide, index| render_slide(slide, index) })
        end
      end

      def render_slide(slide, index)
        is_active = index == @initial_index

        content_tag(:div,
          class: [slide_classes, slide_state_classes(is_active)].compact.join(" "),
          hidden: hide_slide?(is_active),
          data: {
            flat_pack__carousel_target: "slide",
            index: index,
            caption: slide[:caption].to_s
          },
          aria: {
            hidden: (!is_active).to_s,
            label: "Slide #{index + 1} of #{@slides.length}"
          }) do
          render_slide_content(slide)
        end
      end

      def render_slide_content(slide)
        case slide[:type]
        when :image
          tag.img(
            src: slide[:src],
            alt: slide[:alt],
            class: "h-full w-full object-cover",
            loading: "lazy",
            draggable: false
          )
        when :video
          content_tag(:div, class: "relative h-full w-full") do
            safe_join([
              (slide[:poster].present? ? tag.img(
                src: slide[:poster],
                alt: "",
                class: "absolute inset-0 h-full w-full object-cover",
                loading: "lazy",
                draggable: false,
                aria: {hidden: true}
              ) : nil),
              content_tag(:video,
                class: "relative z-10 h-full w-full object-cover",
                controls: slide[:controls],
                muted: slide[:muted],
                loop: slide[:video_loop],
                playsinline: slide[:playsinline],
                preload: "metadata") do
                tag.source(src: slide[:src], type: "video/mp4")
              end
            ].compact)
          end
        else
          # SECURITY: HTML content is sanitized before being marked as safe.
          content_tag(:div, slide[:html].html_safe, class: "h-full w-full overflow-auto p-4")
        end
      end

      def render_controls
        safe_join([
          control_button(direction: :prev, classes: "left-3"),
          control_button(direction: :next, classes: "right-3")
        ])
      end

      def control_button(direction:, classes:)
        label = (direction == :prev) ? "Previous slide" : "Next slide"
        icon_name = (direction == :prev) ? :chevron_left : :chevron_right

        content_tag(:button,
          type: "button",
          class: "absolute top-1/2 z-20 flex w-10 -translate-y-1/2 cursor-pointer aspect-square items-center justify-center rounded-[9999px] bg-[var(--carousel-chevron-background-color)] text-[var(--carousel-control-text-color)] transition hover:bg-[var(--carousel-control-hover-background-color)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring #{classes}",
          aria: {label: label},
          data: {action: "click->flat-pack--carousel##{direction}"}) do
          render FlatPack::Shared::IconComponent.new(name: icon_name, size: :md, class: "pointer-events-none")
        end
      end

      def render_counter
        content_tag(:div,
          "",
          class: "absolute right-3 top-3 z-20 rounded-full bg-[var(--carousel-counter-background-color)] px-2 py-1 text-xs font-medium text-[var(--carousel-counter-text-color)]",
          data: {flat_pack__carousel_target: "counter"})
      end

      def render_indicators
        content_tag(:div,
          class: "absolute inset-x-0 bottom-3 z-20 flex justify-center") do
          content_tag(:div, class: "flex items-center gap-2 rounded-full bg-[var(--carousel-indicator-track-background-color)] px-3 py-2") do
            safe_join(@slides.map.with_index { |_slide, index| render_indicator(index) })
          end
        end
      end

      def render_indicator(index)
        content_tag(:button,
          "",
          type: "button",
          class: "h-2.5 w-2.5 cursor-pointer rounded-full bg-[var(--carousel-indicator-background-color)] transition",
          aria: {
            label: "Go to slide #{index + 1}",
            current: (index == @initial_index).to_s
          },
          data: {
            flat_pack__carousel_target: "indicator",
            action: "click->flat-pack--carousel#goTo",
            index: index
          })
      end

      def render_thumbs
        content_tag(:div, class: "mt-3 flex flex-wrap gap-2 #{thumb_alignment_class}") do
          safe_join(@slides.map.with_index { |slide, index| render_thumb(slide, index) })
        end
      end

      def render_thumb(slide, index)
        content_tag(:button,
          type: "button",
          class: "h-16 w-16 shrink-0 overflow-hidden rounded-md border border-[var(--carousel-thumb-border-color)]",
          aria: {
            label: "Show slide #{index + 1}",
            current: (index == @initial_index).to_s
          },
          data: {
            flat_pack__carousel_target: "thumb",
            action: "click->flat-pack--carousel#goTo",
            index: index
          }) do
          thumb_markup(slide, index)
        end
      end

      def thumb_markup(slide, index)
        thumb_src = slide[:thumb_src].presence || slide[:src]

        if slide[:type] == :image && thumb_src.present?
          tag.img(src: thumb_src, alt: "Thumbnail #{index + 1}", class: "h-full w-full object-cover", loading: "lazy", draggable: false)
        elsif slide[:type] == :video && slide[:poster].present?
          tag.img(src: slide[:poster], alt: "Video thumbnail #{index + 1}", class: "h-full w-full object-cover", loading: "lazy", draggable: false)
        else
          content_tag(:span,
            "#{index + 1}",
            class: "flex h-full w-full items-center justify-center bg-[var(--carousel-thumb-placeholder-background-color)] text-xs font-medium text-[var(--carousel-thumb-placeholder-text-color)]")
        end
      end

      def render_overlay_caption
        content_tag(:div,
          "",
          class: "absolute inset-x-3 bottom-12 z-20 rounded-md bg-[var(--carousel-caption-overlay-background-color)] px-3 py-2 text-sm text-[var(--carousel-caption-overlay-text-color)]",
          data: {flat_pack__carousel_target: "caption"})
      end

      def render_below_caption
        content_tag(:p,
          "",
          class: "mt-3 text-sm text-[var(--carousel-caption-below-text-color)]",
          data: {flat_pack__carousel_target: "caption"})
      end

      def slide_frame_classes
        if @transition == :fade
          "relative h-full w-full overflow-hidden"
        else
          "flex h-full w-full transition-transform duration-300 ease-out"
        end
      end

      def slide_classes
        base = "h-full w-full shrink-0"
        return "absolute inset-0 transition-opacity duration-300 #{base}" if @transition == :fade

        base
      end

      def slide_state_classes(is_active)
        return nil unless @transition == :fade

        is_active ? "opacity-100" : "opacity-0 pointer-events-none"
      end

      def viewport_classes
        classes(
          "flat-pack-carousel__viewport relative overflow-hidden rounded-lg border border-[var(--carousel-viewport-border-color)] bg-[var(--carousel-viewport-background-color)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          @touch_swipe ? "cursor-grab select-none" : nil
        )
      end

      def viewport_style
        declarations = ["aspect-ratio: #{@aspect_ratio}"]
        declarations << "touch-action: pan-y" if @touch_swipe
        "#{declarations.join("; ")};"
      end

      def hide_slide?(is_active)
        return false if @transition == :fade

        !is_active
      end

      def normalize_slides(slides)
        Array(slides).filter_map.with_index do |slide, index|
          payload = slide.respond_to?(:to_h) ? slide.to_h.symbolize_keys : {}
          type = (payload[:type] || infer_type(payload)).to_sym
          next unless SLIDE_TYPES.include?(type)

          normalize_slide(type, payload, index)
        end
      end

      def normalize_slide(type, payload, index)
        caption = payload[:caption].to_s

        case type
        when :image
          src = FlatPack::AttributeSanitizer.sanitize_url(payload[:src])
          return nil unless src.present?

          {
            type: :image,
            src: src,
            alt: payload[:alt].presence || "Slide #{index + 1}",
            thumb_src: FlatPack::AttributeSanitizer.sanitize_url(payload[:thumb_src] || payload[:thumb]),
            caption: caption
          }
        when :video
          src = FlatPack::AttributeSanitizer.sanitize_url(payload[:src])
          return nil unless src.present?

          {
            type: :video,
            src: src,
            poster: FlatPack::AttributeSanitizer.sanitize_url(payload[:poster]),
            controls: payload.fetch(:controls, true),
            muted: payload.fetch(:muted, false),
            video_loop: payload.fetch(:video_loop, false),
            playsinline: payload.fetch(:playsinline, true),
            caption: caption
          }
        else
          raw_html = payload[:html].to_s
          return nil if raw_html.blank?

          {
            type: :html,
            html: sanitize_html(raw_html),
            caption: caption
          }
        end
      end

      def sanitize_html(raw_html)
        ActionController::Base.helpers.sanitize(
          raw_html,
          tags: SANITIZED_HTML_TAGS,
          attributes: SANITIZED_HTML_ATTRIBUTES
        )
      end

      def infer_type(payload)
        return :html if payload[:html].present?
        return :video if payload[:src].to_s.end_with?(".mp4") || payload[:poster].present?

        :image
      end

      def normalize_initial_index(value)
        parsed = Integer(value, exception: false) || 0
        max_index = [@slides.length - 1, 0].max

        parsed.clamp(0, max_index)
      end

      def normalize_interval(value)
        parsed = Integer(value, exception: false) || 5000
        parsed.positive? ? parsed : 5000
      end

      def normalize_aspect_ratio(value)
        ratio = value.to_s.strip
        return "16/9" if ratio.blank?

        unless ratio.match?(/\A\d+(?:\.\d+)?\s*\/\s*\d+(?:\.\d+)?\z/)
          raise ArgumentError, "aspect_ratio must look like '16/9'"
        end

        ratio.delete(" ")
      end

      def thumb_alignment_class
        case @thumbs_alignment
        when :start
          "justify-start"
        when :end
          "justify-end"
        else
          "justify-center"
        end
      end

      def validate_configuration!
        raise ArgumentError, "slides must include at least one valid slide" if @slides.empty?

        validate_option!(:thumbs_position, @thumbs_position, THUMBS_POSITIONS)
        validate_option!(:thumbs_alignment, @thumbs_alignment, THUMBS_ALIGNMENTS)
        validate_option!(:transition, @transition, TRANSITIONS)
        validate_option!(:caption_mode, @caption_mode, CAPTION_MODES)
      end

      def validate_option!(name, value, allowed)
        return if allowed.include?(value)

        raise ArgumentError, "Invalid #{name}: #{value}. Must be one of: #{allowed.join(", ")}"
      end
    end
  end
end
