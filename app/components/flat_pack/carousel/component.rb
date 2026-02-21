# frozen_string_literal: true

module FlatPack
  module Carousel
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "aspect-square" "aspect-video" "aspect-[21/9]"
      # "scale-125" "bg-[var(--color-primary)]" "bg-white/50" "hover:bg-white/80"
      TRANSITIONS = %i[slide fade none].freeze
      ASPECT_RATIOS = %i[auto square video wide].freeze

      def initialize(
        autoplay: false,
        interval: 5000,
        loop: true,
        show_indicators: true,
        show_controls: true,
        show_counter: false,
        pause_on_hover: true,
        transition: :slide,
        aspect_ratio: :auto,
        keyboard: true,
        swipe: true,
        start_slide: 0,
        show_thumbnails: false,
        show_progress_bar: false,
        **system_arguments
      )
        super(**system_arguments)
        @autoplay = autoplay
        @interval = interval
        @loop = loop
        @show_indicators = show_indicators
        @show_controls = show_controls
        @show_counter = show_counter
        @pause_on_hover = pause_on_hover
        @transition = transition.to_sym
        @aspect_ratio = aspect_ratio.to_sym
        @keyboard = keyboard
        @swipe = swipe
        @start_slide = start_slide
        @show_thumbnails = show_thumbnails
        @show_progress_bar = show_progress_bar
        @slides = []

        validate_options!
      end

      def slide(alt: nil, thumbnail_url: nil, &block)
        @slides << {
          alt: alt,
          thumbnail_url: sanitize_thumbnail_url(thumbnail_url),
          content: view_context.capture(&block)
        }
      end

      def call
        content

        content_tag(:div, **container_attributes) do
          safe_join([
            render_viewport,
            render_live_region,
            (@show_controls ? render_controls : nil),
            (@show_indicators ? render_indicators : nil),
            (@show_counter ? render_counter : nil),
            (@show_progress_bar ? render_progress_bar : nil),
            (@show_thumbnails ? render_thumbnails : nil)
          ].compact)
        end
      end

      private

      def validate_options!
        raise ArgumentError, "transition must be one of: #{TRANSITIONS.join(", ")}" unless TRANSITIONS.include?(@transition)
        raise ArgumentError, "aspect_ratio must be one of: #{ASPECT_RATIOS.join(", ")}" unless ASPECT_RATIOS.include?(@aspect_ratio)
        raise ArgumentError, "interval must be >= 1000" if @interval < 1000
        raise ArgumentError, "start_slide must be >= 0" if @start_slide < 0
      end

      def sanitize_thumbnail_url(url)
        return if url.blank?

        FlatPack::AttributeSanitizer.sanitize_url(url)
      end

      def container_attributes
        merge_attributes(
          class: "relative overflow-hidden rounded-[var(--radius-lg)] bg-[var(--color-background)]",
          role: "region",
          aria: {
            roledescription: "carousel",
            label: "Image carousel"
          },
          data: {
            controller: "flat-pack--carousel",
            "flat-pack--carousel-autoplay-value": @autoplay,
            "flat-pack--carousel-interval-value": @interval,
            "flat-pack--carousel-loop-value": @loop,
            "flat-pack--carousel-transition-value": @transition,
            "flat-pack--carousel-swipe-value": @swipe,
            "flat-pack--carousel-start-slide-value": @start_slide,
            "flat-pack--carousel-pause-on-hover-value": @pause_on_hover,
            "flat-pack--carousel-keyboard-value": @keyboard
          }
        )
      end

      def render_viewport
        content_tag(:div,
          class: classes("relative overflow-hidden", aspect_ratio_class),
          data: {"flat-pack--carousel-target": "viewport"}) do
          content_tag(:div,
            class: track_classes,
            data: {"flat-pack--carousel-target": "track"}) do
            safe_join(@slides.map.with_index { |slide_data, index| render_slide(slide_data, index) })
          end
        end
      end

      def render_slide(slide_data, index)
        content_tag(:div,
          slide_data[:content].html_safe,
          class: slide_classes(index),
          role: "group",
          aria: {
            roledescription: "slide",
            label: "#{index + 1} of #{@slides.size}"
          },
          data: {"flat-pack--carousel-target": "slide"})
      end

      def render_controls
        safe_join([
          content_tag(:button,
            chevron_left_svg,
            type: "button",
            class: control_button_classes("left-3 top-1/2 -translate-y-1/2"),
            data: {
              "flat-pack--carousel-target": "prevButton",
              action: "flat-pack--carousel#previous"
            },
            aria: {label: "Previous slide"}),
          content_tag(:button,
            chevron_right_svg,
            type: "button",
            class: control_button_classes("right-3 top-1/2 -translate-y-1/2"),
            data: {
              "flat-pack--carousel-target": "nextButton",
              action: "flat-pack--carousel#next"
            },
            aria: {label: "Next slide"})
        ])
      end

      def render_indicators
        content_tag(:div,
          class: "absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2",
          role: "tablist",
          aria: {label: "Slide indicators"}) do
          safe_join(@slides.map.with_index do |_slide_data, index|
            content_tag(:button, "",
              type: "button",
              role: "tab",
              aria: {
                selected: (index == @start_slide),
                label: "Go to slide #{index + 1}"
              },
              class: indicator_classes(index == @start_slide),
              data: {
                "flat-pack--carousel-target": "indicator",
                action: "flat-pack--carousel#goToSlide",
                slide_index: index
              })
          end)
        end
      end

      def render_counter
        content_tag(:div,
          "#{@start_slide + 1} / #{@slides.size}",
          class: "absolute top-4 right-4 rounded-[var(--radius-md)] bg-black/40 px-2.5 py-1 text-xs text-white",
          data: {"flat-pack--carousel-target": "counter"})
      end

      def render_progress_bar
        content_tag(:div, class: "absolute bottom-0 left-0 w-full h-1 bg-black/20") do
          content_tag(:div,
            "",
            class: "h-full bg-[var(--color-primary)]",
            data: {"flat-pack--carousel-target": "progressBar"},
            style: "width: 0%")
        end
      end

      def render_thumbnails
        thumbnails = @slides.map.with_index do |slide_data, index|
          next if slide_data[:thumbnail_url].blank?

          content_tag(:button,
            type: "button",
            class: thumbnail_classes(index == @start_slide),
            data: {
              "flat-pack--carousel-target": "thumbnail",
              action: "flat-pack--carousel#goToSlide",
              slide_index: index
            },
            aria: {label: "Go to slide #{index + 1}"}) do
            tag.img(
              src: slide_data[:thumbnail_url],
              alt: slide_data[:alt].to_s,
              class: "w-full h-full object-cover"
            )
          end
        end.compact

        return if thumbnails.empty?

        content_tag(:div,
          class: "flex gap-2 mt-3 overflow-x-auto px-2 pb-2",
          data: {"flat-pack--carousel-target": "thumbnailStrip"}) do
          safe_join(thumbnails)
        end
      end

      def render_live_region
        content_tag(:div,
          "Slide #{@start_slide + 1} of #{@slides.size}",
          class: "sr-only",
          aria: {
            live: "polite",
            atomic: "true"
          },
          data: {"flat-pack--carousel-target": "liveRegion"})
      end

      def track_classes
        if @transition == :slide
          "flex motion-safe:transition-transform motion-safe:duration-500 motion-safe:ease-in-out"
        else
          "relative"
        end
      end

      def slide_classes(index)
        if @transition == :slide
          "w-full flex-shrink-0"
        else
          visible = index == @start_slide
          base = "w-full h-full"
          state = if visible
            (@transition == :fade) ? "opacity-100" : "block"
          else
            (@transition == :fade) ? "opacity-0" : "hidden"
          end
          fade_class = (@transition == :fade) ? "absolute inset-0 motion-safe:transition-opacity motion-safe:duration-500" : "absolute inset-0"

          "#{base} #{fade_class} #{state}"
        end
      end

      def aspect_ratio_class
        {
          auto: nil,
          square: "aspect-square",
          video: "aspect-video",
          wide: "aspect-[21/9]"
        }[@aspect_ratio]
      end

      def control_button_classes(position)
        "absolute #{position} z-10 flex h-10 w-10 items-center justify-center rounded-full bg-black/30 text-white backdrop-blur-sm hover:bg-black/50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2"
      end

      def indicator_classes(active)
        base = "h-3 w-3 rounded-full transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2"
        active ? "#{base} scale-125 bg-[var(--color-primary)]" : "#{base} bg-white/50 hover:bg-white/80"
      end

      def thumbnail_classes(active)
        base = "flex-shrink-0 w-16 h-12 rounded-[var(--radius-md)] overflow-hidden border-2"
        active ? "#{base} border-[var(--color-primary)]" : "#{base} border-[var(--color-border)]"
      end

      def chevron_left_svg
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          width: "20",
          height: "20",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round") do
          tag.path(d: "m15 18-6-6 6-6")
        end
      end

      def chevron_right_svg
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          width: "20",
          height: "20",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round") do
          tag.path(d: "m9 18 6-6-6-6")
        end
      end
    end
  end
end
