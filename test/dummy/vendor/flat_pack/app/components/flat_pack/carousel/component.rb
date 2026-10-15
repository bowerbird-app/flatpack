# frozen_string_literal: true

module FlatPack
  module Carousel
    class Component < FlatPack::BaseComponent
      SLIDE_TYPES = %i[image video html].freeze
      TRANSITIONS = %i[slide fade].freeze
      VARIANTS = %i[default logo_slider].freeze
      THUMBS_POSITIONS = %i[top bottom].freeze
      THUMBS_ALIGNMENTS = %i[start center end].freeze
      CAPTION_MODES = %i[below overlay].freeze
      FITS = %i[cover contain].freeze
      DEFAULT_ARIA_LABEL = "Carousel"
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-full" "object-contain" "object-cover" "tabular-nums" "flex" "flex-col" "min-h-0" "flex-1" "shrink-0" "w-full"
      # "bg-transparent" "rounded-none" "border-0" "text-center" "pb-20"
      # "inset-x-0" "bottom-0" "z-30" "flex-nowrap" "overflow-x-auto" "overscroll-x-contain" "px-1" "pb-1"
      # "[justify-content:safe_center]"
      # "bg-[var(--carousel-lightbox-image-background-color)]"
      # "text-[var(--carousel-caption-overlay-text-color)]"

      SANITIZED_HTML_TAGS = %w[
        p div span a ul ol li strong em b i u br
        h1 h2 h3 h4 h5 h6
        code pre blockquote
        form label input
      ].freeze

      SANITIZED_HTML_ATTRIBUTES = %w[
        class id title
        href rel target
        data-controller
        data-flat-pack--chart-series-value
        data-flat-pack--chart-type-value
        data-flat-pack--chart-options-value
        data-flat-pack--chart-height-value
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
        show_controls: nil,
        controls_on_hover: false,
        autoplay: nil,
        autoplay_interval_ms: 5000,
        pause_on_hover: true,
        pause_on_focus: true,
        loop: true,
        transition: :slide,
        variant: :default,
        items_per_view_mobile: 1,
        items_per_view_tablet: 1,
        items_per_view_desktop: 1,
        side_preview: false,
        logo_items_per_view_mobile: 3,
        logo_items_per_view_tablet: 3,
        logo_items_per_view_desktop: 5,
        logo_grayscale: true,
        logo_opacity: 1.0,
        logo_wrapper_background: nil,
        aspect_ratio: "16/9",
        responsive: true,
        touch_swipe: true,
        show_captions: true,
        caption_mode: :below,
        show_border: true,
        show_background: true,
        show_counter: true,
        fit: :cover,
        stage: false,
        aria_label: FlatPack::Copy::OMITTED,
        **system_arguments
      )
        super(**system_arguments)

        @variant = variant.to_sym
        @slides = normalize_slides(slides)
        @show_thumbs = !!show_thumbs
        @thumbs_position = thumbs_position.to_sym
        @thumbs_alignment = thumbs_alignment.to_sym
        @show_indicators = !!show_indicators
        @show_controls = if show_controls.nil?
          @variant != :logo_slider
        else
          !!show_controls
        end
        @controls_on_hover = !!controls_on_hover
        @autoplay = if autoplay.nil?
          @variant == :logo_slider
        else
          !!autoplay
        end
        @autoplay_interval_ms = normalize_interval(autoplay_interval_ms)
        @pause_on_hover = !!pause_on_hover
        @pause_on_focus = !!pause_on_focus
        @loop = !!loop
        @transition = transition.to_sym
        @items_per_view_mobile = normalize_items_per_view(items_per_view_mobile, fallback: 1)
        @items_per_view_tablet = normalize_items_per_view(items_per_view_tablet, fallback: 1)
        @items_per_view_desktop = normalize_items_per_view(items_per_view_desktop, fallback: 1)
        @side_preview = !!side_preview
        @logo_items_per_view_mobile = normalize_logo_items_per_view(logo_items_per_view_mobile, fallback: 3)
        @logo_items_per_view_tablet = normalize_logo_items_per_view(logo_items_per_view_tablet, fallback: 3)
        @logo_items_per_view_desktop = normalize_logo_items_per_view(logo_items_per_view_desktop, fallback: 5)
        @logo_grayscale = !!logo_grayscale
        @logo_opacity = normalize_logo_opacity(logo_opacity)
        @logo_wrapper_background = sanitize_background(logo_wrapper_background)
        @aspect_ratio = normalize_aspect_ratio(aspect_ratio)
        @responsive = !!responsive
        @touch_swipe = !!touch_swipe
        @show_captions = !!show_captions
        @caption_mode = caption_mode.to_sym
        @show_border = !!show_border
        @show_background = !!show_background
        @show_counter = !!show_counter
        @fit = fit.to_sym
        @stage = !!stage
        @aria_label = fp_text(aria_label.equal?(FlatPack::Copy::OMITTED) ? FlatPack::Copy::OMITTED : (aria_label.presence || FlatPack::Copy::OMITTED), "carousel.label")
        @initial_index = normalize_initial_index(initial_index)
        @lightbox_items = build_lightbox_items
        @lightbox_group = @lightbox_items.any? ? "carousel-#{SecureRandom.hex(4)}" : nil

        validate_configuration!
      end

      def call
        carousel = content_tag(root_tag, **carousel_attributes) do
          safe_join([
            (thumbs_visible? && @thumbs_position == :top && !stage_layout?) ? render_thumbs : nil,
            render_viewport,
            (@show_captions && @caption_mode == :below) ? render_below_caption : nil,
            (thumbs_visible? && (@thumbs_position == :bottom || stage_layout?)) ? render_thumbs : nil
          ].compact)
        end

        lightbox = render_shared_lightbox
        return carousel if lightbox.blank?

        safe_join([carousel, lightbox])
      end

      private

      def root_tag
        @stage ? :div : :section
      end

      def carousel_attributes
        merge_attributes(
          class: root_classes,
          style: root_style,
          data: carousel_data
        )
      end

      def carousel_data
        data = {
          controller: "flat-pack--carousel",
          flat_pack__carousel_initial_index_value: @initial_index,
          flat_pack__carousel_loop_value: @loop,
          flat_pack__carousel_autoplay_value: @autoplay,
          flat_pack__carousel_autoplay_interval_value: @autoplay_interval_ms,
          flat_pack__carousel_pause_on_hover_value: @pause_on_hover,
          flat_pack__carousel_pause_on_focus_value: @pause_on_focus,
          flat_pack__carousel_touch_swipe_value: @touch_swipe,
          flat_pack__carousel_transition_value: @transition,
          flat_pack__carousel_variant_value: @variant,
          flat_pack__carousel_items_per_view_mobile_value: @items_per_view_mobile,
          flat_pack__carousel_items_per_view_tablet_value: @items_per_view_tablet,
          flat_pack__carousel_items_per_view_desktop_value: @items_per_view_desktop,
          flat_pack__carousel_side_preview_value: side_preview_enabled?,
          flat_pack__carousel_logo_items_per_view_mobile_value: @logo_items_per_view_mobile,
          flat_pack__carousel_logo_items_per_view_tablet_value: @logo_items_per_view_tablet,
          flat_pack__carousel_logo_items_per_view_desktop_value: @logo_items_per_view_desktop,
          flat_pack__carousel_logical_slide_count_value: @slides.length
        }
        data[:flat_pack_lightbox_group] = @lightbox_group if @lightbox_group
        data[:flat_pack_lightbox_stage] = "true" if @stage
        data
      end

      def root_classes
        classes(
          "flat-pack-carousel relative w-full",
          stage_layout? ? "flex min-h-0 w-full flex-1 flex-col" : nil,
          stage_thumbs? ? "pb-20" : nil,
          (@variant == :logo_slider) ? "m-0 p-0 bg-transparent" : nil,
          @show_thumbs ? "overflow-visible" : nil,
          @responsive ? "max-w-full" : nil
        )
      end

      def root_style
        html_attributes[:style].presence
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
            (controls_visible? ? render_controls : nil),
            (lightbox_toggle_visible? ? render_lightbox_toggle : nil),
            (footer_visible? ? render_footer : nil),
            ((@show_captions && @caption_mode == :overlay) ? render_overlay_caption : nil)
          ].compact)
        end
      end

      def render_slides
        content_tag(:div, class: slide_frame_classes, data: {flat_pack__carousel_target: "frame"}) do
          safe_join(rendered_slides.map.with_index { |slide, index| render_slide(slide, index) })
        end
      end

      def rendered_slides
        return @slides unless logo_slider_loop_clones?

        @slides + @slides.first(logo_slider_clone_count)
      end

      def logo_slider_loop_clones?
        @variant == :logo_slider && @loop && multiple_slides?
      end

      def logo_slider_clone_count
        [@logo_items_per_view_mobile, @logo_items_per_view_tablet, @logo_items_per_view_desktop].max
      end

      def render_slide(slide, index)
        is_active = index == @initial_index
        aria_hidden = (@variant == :logo_slider) ? false : !is_active

        content_tag(:div,
          class: [slide_classes, slide_state_classes(is_active)].compact.join(" "),
          hidden: hide_slide?(is_active),
          data: slide_data(slide, index),
          aria: {
            hidden: aria_hidden.to_s,
            label: fp_t("carousel.slide", current: index + 1, total: @slides.length)
          }) do
          render_slide_content(slide)
        end
      end

      def render_slide_content(slide)
        case slide[:type]
        when :image
          return render_logo_image(slide) if @variant == :logo_slider

          tag.img(
            src: slide[:src],
            alt: slide[:alt],
            class: image_classes,
            loading: "lazy",
            draggable: false
          )
        when :video
          content_tag(:div, class: "relative h-full w-full overflow-hidden") do
            safe_join([
              (slide[:poster].present? ? tag.img(
                src: slide[:poster],
                alt: "",
                class: poster_classes,
                loading: "lazy",
                draggable: false,
                aria: {hidden: true}
              ) : nil),
              content_tag(:video,
                class: video_classes,
                style: "width: 100%; height: 100%; object-fit: contain;",
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
          content_tag(:div, slide[:html].html_safe, class: "overflow-auto p-4")
        end
      end

      def render_logo_image(slide)
        image_classes = classes(
          "h-10 w-auto max-w-full object-contain sm:h-12 md:h-14 lg:h-16",
          @logo_grayscale ? "grayscale" : nil
        )

        content_tag(:div, class: "flex h-full w-full items-center justify-center p-0 m-0") do
          tag.img(
            src: slide[:src],
            alt: slide[:alt],
            class: image_classes,
            style: "opacity: #{@logo_opacity}",
            loading: "lazy",
            draggable: false
          )
        end
      end

      def render_controls
        safe_join([
          control_button(direction: :prev, classes: "left-3"),
          control_button(direction: :next, classes: "right-3")
        ])
      end

      def control_button(direction:, classes:)
        label = (direction == :prev) ? fp_t("carousel.previous") : fp_t("carousel.next")
        icon_name = (direction == :prev) ? :chevron_left : :chevron_right

        content_tag(:button,
          type: "button",
          class: "absolute top-1/2 z-20 flex w-10 -translate-y-1/2 cursor-pointer aspect-square items-center justify-center rounded-full bg-[var(--carousel-control-background-color)] text-[var(--carousel-control-text-color)] transition hover:bg-[var(--carousel-control-hover-background-color)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring #{controls_visibility_classes} #{classes}",
          aria: {label: label},
          data: {action: "click->flat-pack--carousel##{direction}"}) do
          render FlatPack::Shared::IconComponent.new(name: icon_name, size: :md, class: "pointer-events-none")
        end
      end

      def controls_visibility_classes
        return nil unless @controls_on_hover

        "opacity-100 md:opacity-0 md:pointer-events-none md:group-hover:opacity-100 md:group-hover:pointer-events-auto md:group-focus-within:opacity-100 md:group-focus-within:pointer-events-auto"
      end

      def render_footer
        footer_classes = if indicators_visible?
          "absolute inset-x-0 bottom-3 z-20 grid grid-cols-[1fr_auto_1fr] items-center px-3"
        else
          "absolute inset-x-0 bottom-3 z-20 flex justify-end px-3"
        end

        content_tag(:div, class: footer_classes) do
          safe_join([
            (indicators_visible? ? content_tag(:div, nil) : nil),
            (indicators_visible? ? render_indicators : nil),
            (counter_visible? ? render_counter : nil)
          ].compact)
        end
      end

      def controls_visible?
        @show_controls && multiple_slides?
      end

      def footer_visible?
        indicators_visible? || counter_visible?
      end

      def counter_visible?
        return false if @variant == :logo_slider
        return false unless @show_counter

        multiple_slides?
      end

      def indicators_visible?
        @show_indicators && multiple_slides?
      end

      def multiple_slides?
        @slides.length > visible_item_threshold
      end

      def visible_item_threshold
        if @variant == :logo_slider
          return [@logo_items_per_view_mobile, @logo_items_per_view_tablet, @logo_items_per_view_desktop].min
        end

        [@items_per_view_mobile, @items_per_view_tablet, @items_per_view_desktop].min
      end

      def render_counter
        content_tag(:div,
          "",
          class: "justify-self-end rounded-full bg-[var(--carousel-counter-background-color)] px-2 py-1 text-xs font-medium tabular-nums text-[var(--carousel-counter-text-color)]",
          data: {flat_pack__carousel_target: "counter"})
      end

      def lightbox_toggle_visible?
        return false if @stage

        @slides.any? { |slide| slide_lightbox_enabled?(slide) }
      end

      def render_lightbox_toggle
        content_tag(:button,
          type: "button",
          hidden: !lightbox_available_for_index?(@initial_index),
          class: "absolute right-3 top-3 z-20 flex aspect-square flex-nowrap items-center justify-center cursor-pointer rounded-full bg-[var(--carousel-control-background-color)] p-2 text-[var(--carousel-control-text-color)] transition hover:bg-[var(--carousel-control-hover-background-color)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          aria: {label: fp_t("carousel.expand_image")},
          data: {
            flat_pack__carousel_target: "lightboxToggle",
            action: "click->flat-pack--carousel#openLightbox"
          }) do
          render FlatPack::Shared::IconComponent.new(name: :arrows_pointing_out, size: :sm, class: "pointer-events-none")
        end
      end

      def render_shared_lightbox
        return if @stage || @lightbox_items.empty?

        render FlatPack::Lightbox::Component.new(
          group: @lightbox_group,
          items: @lightbox_items,
          loop: @loop,
          show_count: true
        )
      end

      def render_indicators
        content_tag(:div, class: "justify-self-center") do
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
            label: fp_t("carousel.go_to_slide", number: index + 1),
            current: (index == @initial_index).to_s
          },
          data: {
            flat_pack__carousel_target: "indicator",
            action: "click->flat-pack--carousel#goTo",
            index: index
          })
      end

      def render_thumbs
        content_tag(:div, class: thumb_strip_classes, data: thumb_strip_data) do
          safe_join(@slides.map.with_index { |slide, index| render_thumb(slide, index) })
        end
      end

      def thumb_strip_classes
        return stage_thumb_strip_classes if stage_layout?

        "mt-3 flex flex-wrap gap-2 #{thumb_alignment_class}"
      end

      def stage_thumb_strip_classes
        "flat-pack-carousel__thumbs absolute inset-x-0 bottom-0 z-30 flex flex-nowrap gap-2 overflow-x-auto overscroll-x-contain px-1 pb-1 [justify-content:safe_center]"
      end

      def thumb_strip_data
        return {} unless stage_layout?

        {flat_pack__carousel_target: "thumbStrip"}
      end

      def thumbs_visible?
        return false unless @show_thumbs
        return false if stage_layout? && !multiple_slides?

        true
      end

      def stage_thumbs?
        stage_layout? && thumbs_visible?
      end

      def render_thumb(slide, index)
        content_tag(:button,
          type: "button",
          class: "h-16 w-16 shrink-0 cursor-pointer overflow-hidden rounded-[var(--radius-md)] border border-[var(--carousel-thumb-border-color)] transition-opacity hover:opacity-100 hover:ring-2 hover:ring-inset hover:ring-primary",
          aria: {
            label: fp_t("carousel.show_slide", number: index + 1),
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
        source = thumb_image_source(slide)
        return numbered_thumb(index) if source.blank?

        tag.img(
          src: source,
          alt: thumb_alt(slide, index),
          class: "h-full w-full object-cover",
          loading: "lazy",
          draggable: false
        )
      end

      def thumb_image_source(slide)
        case slide[:type]
        when :image
          slide[:thumb_src].presence || slide[:src]
        when :video
          return slide[:thumb_src].presence || slide[:poster].presence if stage_layout?

          slide[:poster]
        else
          slide[:thumb_src]
        end
      end

      def thumb_alt(slide, index)
        key = (slide[:type] == :video) ? "carousel.video_thumbnail" : "carousel.thumbnail"
        fp_t(key, number: index + 1)
      end

      def numbered_thumb(index)
        content_tag(:span,
          (index + 1).to_s,
          class: "flex h-full w-full items-center justify-center bg-[var(--carousel-thumb-placeholder-background-color)] text-xs font-medium text-[var(--carousel-thumb-placeholder-text-color)]")
      end

      def render_overlay_caption
        content_tag(:div,
          "",
          class: "absolute inset-x-3 bottom-12 z-20 rounded-[var(--radius-md)] bg-[var(--carousel-caption-overlay-background-color)] px-3 py-2 text-sm text-[var(--carousel-caption-overlay-text-color)]",
          data: {flat_pack__carousel_target: "caption"})
      end

      def render_below_caption
        content_tag(:p,
          "",
          class: caption_classes,
          data: {flat_pack__carousel_target: "caption"})
      end

      def caption_classes
        if stage_layout?
          return "mt-3 shrink-0 text-center text-sm text-[var(--carousel-caption-overlay-text-color)]"
        end

        "mt-3 text-sm text-[var(--carousel-caption-below-text-color)]"
      end

      def slide_frame_classes
        if @transition == :fade
          "relative h-full w-full overflow-hidden"
        else
          classes(
            "flex h-full w-full transition-transform duration-[var(--duration-slow)] ease-out",
            (@variant == :logo_slider) ? "items-center" : nil
          )
        end
      end

      def slide_classes
        if @variant == :logo_slider
          return "h-full shrink-0 basis-1/3 md:basis-1/3 lg:basis-1/5"
        end

        base = "h-full w-full shrink-0"
        return "absolute inset-0 transition-opacity duration-[var(--duration-slow)] #{base}" if @transition == :fade

        base
      end

      def slide_state_classes(is_active)
        return nil unless @transition == :fade

        is_active ? "opacity-100" : "opacity-0 pointer-events-none"
      end

      def viewport_classes
        return logo_slider_viewport_classes if @variant == :logo_slider
        return stage_viewport_classes if stage_layout?

        classes(
          "flat-pack-carousel__viewport group relative overflow-hidden rounded-[var(--radius-lg)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          @show_border ? "border border-[var(--carousel-viewport-border-color)]" : "border-0",
          @show_background ? "bg-[var(--carousel-viewport-background-color)]" : "bg-transparent",
          @touch_swipe ? "cursor-grab select-none" : nil
        )
      end

      def stage_viewport_classes
        classes(
          "flat-pack-carousel__viewport group relative min-h-0 w-full flex-1 overflow-hidden rounded-none border-0 bg-transparent focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          @touch_swipe ? "cursor-grab select-none" : nil
        )
      end

      def logo_slider_viewport_classes
        classes(
          "flat-pack-carousel__viewport relative overflow-hidden rounded-none border-0 bg-transparent",
          @touch_swipe ? "cursor-grab select-none" : nil,
          "m-0 p-0"
        )
      end

      def viewport_style
        declarations = []
        declarations << "aspect-ratio: #{@aspect_ratio}" unless @variant == :logo_slider || stage_layout?
        declarations << "touch-action: pan-y" if @touch_swipe
        declarations << "height: auto" if @variant == :logo_slider
        declarations << "background: transparent" if @variant == :logo_slider
        "#{declarations.join("; ")};"
      end

      def hide_slide?(is_active)
        return false if @variant == :logo_slider
        return false if @transition == :fade

        !is_active
      end

      def normalize_slides(slides)
        Array(slides).filter_map.with_index do |slide, index|
          payload = slide.respond_to?(:to_h) ? slide.to_h.symbolize_keys : {}
          type = (payload[:type] || infer_type(payload)).to_sym
          next unless SLIDE_TYPES.include?(type)
          next if @variant == :logo_slider && type != :image

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
            alt: payload[:alt].presence || fp_t("carousel.slide_fallback", number: index + 1),
            thumb_src: sanitize_thumb_src(payload),
            lightbox: normalize_lightbox(payload[:lightbox], default: true),
            caption: caption
          }
        when :video
          src = FlatPack::AttributeSanitizer.sanitize_url(payload[:src])
          return nil unless src.present?

          {
            type: :video,
            src: src,
            poster: FlatPack::AttributeSanitizer.sanitize_url(payload[:poster]),
            thumb_src: sanitize_thumb_src(payload),
            controls: payload.fetch(:controls, true),
            muted: payload.fetch(:muted, false),
            video_loop: payload.fetch(:video_loop, false),
            playsinline: payload.fetch(:playsinline, true),
            lightbox: normalize_lightbox(payload[:lightbox], default: false),
            caption: caption
          }
        else
          raw_html = payload[:html].to_s
          return nil if raw_html.blank?

          {
            type: :html,
            html: sanitize_html(raw_html),
            thumb_src: sanitize_thumb_src(payload),
            lightbox: normalize_lightbox(payload[:lightbox], default: false),
            caption: caption
          }
        end
      end

      def normalize_lightbox(value, default:)
        return default if value.nil?

        ActiveModel::Type::Boolean.new.cast(value)
      end

      def slide_lightbox_enabled?(slide)
        return false if @variant == :logo_slider || @stage
        return false unless slide[:lightbox] && slide[:src].present?

        slide[:type] == :image || slide[:type] == :video
      end

      def slide_data(slide, index)
        data = {
          flat_pack__carousel_target: "slide",
          index: index,
          caption: slide[:caption].to_s,
          lightbox_enabled: slide_lightbox_enabled?(slide).to_s,
          lightbox_src: slide_lightbox_src(slide),
          lightbox_alt: slide_lightbox_alt(slide)
        }
        data[:lightbox_index] = slide[:lightbox_index] unless slide[:lightbox_index].nil?
        data
      end

      def image_classes
        return "h-full w-full bg-transparent object-contain" if stage_layout?
        return "h-full w-full object-contain bg-[var(--carousel-lightbox-image-background-color)]" if contain_fit?

        "h-full w-full object-cover"
      end

      def poster_classes
        return "pointer-events-none absolute inset-0 h-full w-full bg-transparent object-contain" if stage_layout?

        "absolute inset-0 h-full w-full object-cover pointer-events-none"
      end

      def video_classes
        return "absolute inset-0 z-10 block h-full w-full bg-transparent object-contain" if stage_layout?

        "absolute inset-0 z-10 block h-full w-full bg-[var(--carousel-media-background-color)] object-contain"
      end

      def contain_fit?
        @fit == :contain && @variant != :logo_slider
      end

      def stage_layout?
        @stage && @variant != :logo_slider
      end

      def build_lightbox_items
        index = 0
        @slides.filter_map do |slide|
          next unless slide_lightbox_enabled?(slide)

          slide[:lightbox_index] = index
          index += 1
          lightbox_item_from(slide)
        end
      end

      def lightbox_item_from(slide)
        {
          type: slide[:type],
          src: slide[:src],
          alt: slide[:alt],
          caption: slide[:caption],
          poster: slide[:poster],
          controls: slide[:controls],
          muted: slide[:muted],
          video_loop: slide[:video_loop],
          playsinline: slide[:playsinline]
        }.compact
      end

      def sanitize_thumb_src(payload)
        FlatPack::AttributeSanitizer.sanitize_url(payload[:thumb_src] || payload[:thumb])
      end

      # Strip url() functions to prevent CSS-based URL injection.
      def sanitize_background(value)
        return nil if value.nil? || value.to_s.strip.empty?

        value.to_s.gsub(/url\s*\([^)]*\)/i, "").strip.presence
      end

      def normalize_logo_items_per_view(value, fallback:)
        normalize_items_per_view(value, fallback: fallback)
      end

      def normalize_items_per_view(value, fallback:)
        parsed = Integer(value, exception: false)
        return fallback if parsed.nil? || parsed <= 0

        parsed
      end

      def side_preview_enabled?
        @variant == :default && @transition == :slide && @side_preview
      end

      def normalize_logo_opacity(value)
        parsed = Float(value, exception: false)
        return 1.0 if parsed.nil?

        parsed.clamp(0.0, 1.0)
      end

      def slide_lightbox_src(slide)
        slide_lightbox_enabled?(slide) ? slide[:src] : nil
      end

      def slide_lightbox_alt(slide)
        slide_lightbox_enabled?(slide) ? slide[:alt] : nil
      end

      def lightbox_available_for_index?(index)
        slide = @slides[index]
        slide.present? && slide_lightbox_enabled?(slide)
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

        validate_option!(:variant, @variant, VARIANTS)
        validate_option!(:thumbs_position, @thumbs_position, THUMBS_POSITIONS)
        validate_option!(:thumbs_alignment, @thumbs_alignment, THUMBS_ALIGNMENTS)
        validate_option!(:transition, @transition, TRANSITIONS)
        validate_option!(:caption_mode, @caption_mode, CAPTION_MODES)
        validate_option!(:fit, @fit, FITS)

        if @variant == :logo_slider && @transition == :fade
          raise ArgumentError, "logo_slider variant only supports :slide transition"
        end
      end

      def validate_option!(name, value, allowed)
        return if allowed.include?(value)

        raise ArgumentError, "Invalid #{name}: #{value}. Must be one of: #{allowed.join(", ")}"
      end
    end
  end
end
