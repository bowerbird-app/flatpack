# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Carousel
    class ComponentTest < ViewComponent::TestCase
      def sample_slides
        [
          {
            type: :image,
            src: "https://images.example.com/one.jpg",
            alt: "Slide one",
            caption: "First"
          },
          {
            type: :video,
            src: "https://videos.example.com/two.mp4",
            poster: "https://images.example.com/poster.jpg",
            caption: "Second"
          },
          {
            type: :html,
            html: "<p><strong>Custom</strong> content</p>",
            caption: "Third"
          }
        ]
      end

      def lightbox_slides
        [
          {
            type: :image,
            src: "https://images.example.com/one.jpg",
            alt: "Slide one",
            caption: "First"
          },
          {
            type: :image,
            src: "https://images.example.com/two.jpg",
            alt: "Slide two",
            caption: "Second",
            lightbox: false
          },
          {
            type: :video,
            src: "https://videos.example.com/two.mp4",
            poster: "https://images.example.com/poster.jpg",
            caption: "Third",
            lightbox: true
          }
        ]
      end

      def single_lightbox_slide
        [
          {
            type: :image,
            src: "https://images.example.com/single.jpg",
            alt: "Single slide",
            caption: "Only",
            lightbox: true
          }
        ]
      end

      def test_renders_carousel_shell_with_targets
        render_inline(Component.new(slides: sample_slides))

        assert_selector "section[data-controller='flat-pack--carousel']"
        assert_selector "div[data-flat-pack--carousel-target='slide']", count: 3, visible: :all
        assert_selector "button[data-flat-pack--carousel-target='indicator']", count: 3
        assert_selector "div[data-flat-pack--carousel-target='counter']"
        indicator = page.find("button[data-flat-pack--carousel-target='indicator']", match: :first)
        assert_includes indicator[:class], "cursor-pointer"
        assert_selector "button[data-action='click->flat-pack--carousel#prev']"
        assert_selector "button[data-action='click->flat-pack--carousel#next']"
      end

      def test_places_counter_in_bottom_footer_row_with_indicators
        render_inline(Component.new(slides: sample_slides))

        counter = page.find("div[data-flat-pack--carousel-target='counter']", visible: :all)
        footer = counter.find(:xpath, "./ancestor::div[contains(@class, 'bottom-3') and contains(@class, 'grid')][1]", visible: :all)
        counter = footer.find("div[data-flat-pack--carousel-target='counter']", visible: :all)
        indicators = footer.find("button[data-flat-pack--carousel-target='indicator']", match: :first, visible: :all)

        assert_includes counter[:class], "justify-self-end"
        assert_includes counter[:class], "bg-[rgba(0,0,0,0.5)]"
        assert_includes counter[:class], "text-white"
        assert_includes indicators.find(:xpath, "ancestor::div[1]")[:class], "rounded-full"
      end

      def test_renders_circular_flex_chevron_controls_with_tinted_round_background
        render_inline(Component.new(slides: sample_slides))

        prev_button = page.find("button[data-action='click->flat-pack--carousel#prev']")
        control_classes = prev_button[:class]

        assert_includes control_classes, "rounded-full"
        assert_includes control_classes, "aspect-square"
        assert_includes control_classes, "flex"
        assert_includes control_classes, "cursor-pointer"
        assert_includes control_classes, "bg-[rgba(0,0,0,0.5)]"
        assert_includes control_classes, "hover:bg-[rgba(0,0,0,0.75)]"
        assert_includes control_classes, "text-white"
        assert_selector "button[data-action='click->flat-pack--carousel#prev'] svg[data-flat-pack--icon-name-value='chevron-left']", visible: :all
        assert_selector "button[data-action='click->flat-pack--carousel#next'] svg[data-flat-pack--icon-name-value='chevron-right']", visible: :all
        assert_selector "button[data-action='click->flat-pack--carousel#prev'] svg.pointer-events-none", visible: :all
      end

      def test_enables_lightbox_by_default_for_images_and_disables_for_non_image_slides
        render_inline(Component.new(slides: lightbox_slides))

        slides = page.all("div[data-flat-pack--carousel-target='slide']", visible: :all)

        assert_equal "true", slides[0]["data-lightbox-enabled"]
        assert_equal "https://images.example.com/one.jpg", slides[0]["data-lightbox-src"]
        assert_equal "false", slides[1]["data-lightbox-enabled"]
        assert_nil slides[1]["data-lightbox-src"]
        assert_equal "false", slides[2]["data-lightbox-enabled"]
        assert_nil slides[2]["data-lightbox-src"]
      end

      def test_renders_lightbox_toggle_button_with_expand_icon
        render_inline(Component.new(slides: sample_slides))

        lightbox_toggle = page.find("button[data-flat-pack--carousel-target='lightboxToggle'][data-action='click->flat-pack--carousel#openLightbox']", visible: :all)

        assert_includes lightbox_toggle[:class], "top-3"
        assert_includes lightbox_toggle[:class], "bg-[rgba(0,0,0,0.5)]"
        assert_includes lightbox_toggle[:class], "hover:bg-[rgba(0,0,0,0.75)]"
        assert_includes lightbox_toggle[:class], "text-white"
        refute_includes lightbox_toggle[:class], "top-12"
        assert_selector "button[data-flat-pack--carousel-target='lightboxToggle'] svg[data-flat-pack--icon-name-value='arrows-pointing-out']", visible: :all
      end

      def test_renders_lightbox_image_with_intrinsic_sizing_capped_to_90_percent_viewport_bounds
        render_inline(Component.new(slides: lightbox_slides))

        lightbox_image = page.find("img[data-flat-pack--carousel-target='lightboxImage']", visible: :all)
        figure = lightbox_image.find(:xpath, "./ancestor::figure[1]", visible: :all)
        image_classes = lightbox_image[:class].split
        figure_classes = figure[:class].split

        assert_includes image_classes, "w-auto"
        assert_includes image_classes, "h-auto"
        assert_includes image_classes, "max-w-[90vw]"
        assert_includes image_classes, "max-h-[90vh]"
        refute_includes image_classes, "w-full"
        assert_includes figure_classes, "inline-flex"
        assert_includes figure_classes, "max-w-full"
        refute_includes figure_classes, "w-full"
        refute_includes figure_classes, "max-w-6xl"
      end

      def test_hides_controls_and_counter_for_single_slide_but_keeps_lightbox_toggle
        render_inline(Component.new(slides: single_lightbox_slide))

        assert_no_selector "button[data-action='click->flat-pack--carousel#prev']"
        assert_no_selector "button[data-action='click->flat-pack--carousel#next']"
        assert_no_selector "div[data-flat-pack--carousel-target='counter']"
        assert_no_selector "button[data-flat-pack--carousel-target='indicator']"
        assert_selector "button[data-flat-pack--carousel-target='lightboxToggle']", count: 1, visible: :all
      end

      def test_exposes_owl_style_configuration_values
        render_inline(
          Component.new(
            slides: sample_slides,
            initial_index: 1,
            autoplay: true,
            autoplay_interval_ms: 3100,
            loop: true,
            transition: :fade,
            touch_swipe: false
          )
        )

        root = page.find("section[data-controller='flat-pack--carousel']")
        assert_equal "1", root["data-flat-pack--carousel-initial-index-value"]
        assert_equal "true", root["data-flat-pack--carousel-autoplay-value"]
        assert_equal "3100", root["data-flat-pack--carousel-autoplay-interval-value"]
        assert_equal "true", root["data-flat-pack--carousel-loop-value"]
        assert_equal "fade", root["data-flat-pack--carousel-transition-value"]
        assert_equal "false", root["data-flat-pack--carousel-touch-swipe-value"]
      end

      def test_exposes_logo_slider_configuration_values
        render_inline(
          Component.new(
            slides: [
              {type: :image, src: "https://images.example.com/a.svg", alt: "A"},
              {type: :image, src: "https://images.example.com/b.svg", alt: "B"},
              {type: :image, src: "https://images.example.com/c.svg", alt: "C"},
              {type: :image, src: "https://images.example.com/d.svg", alt: "D"}
            ],
            variant: :logo_slider,
            logo_items_per_view_desktop: 5,
            logo_items_per_view_tablet: 3,
            logo_items_per_view_mobile: 3,
            logo_grayscale: true,
            logo_opacity: 0.75,
            logo_wrapper_background: "#f7f8fa"
          )
        )

        root = page.find("section[data-controller='flat-pack--carousel']")
        assert_equal "logo_slider", root["data-flat-pack--carousel-variant-value"]
        assert_equal "5", root["data-flat-pack--carousel-logo-items-per-view-desktop-value"]
        assert_equal "3", root["data-flat-pack--carousel-logo-items-per-view-tablet-value"]
        assert_equal "3", root["data-flat-pack--carousel-logo-items-per-view-mobile-value"]

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:style], "background: transparent"
      end

      def test_logo_slider_defaults_to_autoplay_and_hides_controls
        render_inline(
          Component.new(
            slides: [
              {type: :image, src: "https://images.example.com/a.svg", alt: "A"},
              {type: :image, src: "https://images.example.com/b.svg", alt: "B"},
              {type: :image, src: "https://images.example.com/c.svg", alt: "C"},
              {type: :image, src: "https://images.example.com/d.svg", alt: "D"}
            ],
            variant: :logo_slider
          )
        )

        root = page.find("section[data-controller='flat-pack--carousel']")
        assert_equal "true", root["data-flat-pack--carousel-autoplay-value"]
        assert_no_selector "button[data-action='click->flat-pack--carousel#prev']"
        assert_no_selector "button[data-action='click->flat-pack--carousel#next']"
        assert_no_selector "div[data-flat-pack--carousel-target='counter']"
      end

      def test_defaults_transition_to_slide
        render_inline(Component.new(slides: sample_slides))

        root = page.find("section[data-controller='flat-pack--carousel']")
        assert_equal "true", root["data-flat-pack--carousel-loop-value"]
        assert_equal "slide", root["data-flat-pack--carousel-transition-value"]
      end

      def test_logo_slider_filters_non_image_slides
        render_inline(Component.new(slides: sample_slides, variant: :logo_slider, loop: false))

        assert_selector "div[data-flat-pack--carousel-target='slide']", count: 1, visible: :all
      end

      def test_logo_slider_renders_responsive_logo_classes_and_disables_lightbox
        render_inline(
          Component.new(
            slides: [
              {type: :image, src: "https://images.example.com/a.svg", alt: "A", url: "https://example.com/a"},
              {type: :image, src: "https://images.example.com/b.svg", alt: "B"},
              {type: :image, src: "https://images.example.com/c.svg", alt: "C"},
              {type: :image, src: "https://images.example.com/d.svg", alt: "D"}
            ],
            variant: :logo_slider,
            logo_grayscale: true,
            logo_opacity: 0.8
          )
        )

        slide = page.find("div[data-flat-pack--carousel-target='slide']", match: :first, visible: :all)
        assert_includes slide[:class], "basis-1/3"
        assert_includes slide[:class], "lg:basis-1/5"

        logo = page.find("div[data-flat-pack--carousel-target='slide'] img", match: :first, visible: :all)
        assert_includes logo[:class], "object-contain"
        assert_includes logo[:class], "grayscale"
        assert_includes logo[:style], "opacity: 0.8"
        assert_equal "A", logo[:title]

        link = page.find("div[data-flat-pack--carousel-target='slide'] a[href='https://example.com/a']", visible: :all, match: :first)
        assert_equal "_blank", link[:target]
        assert_includes link[:rel], "noopener"
        assert_includes link[:rel], "noreferrer"

        assert_no_selector "button[data-flat-pack--carousel-target='lightboxToggle']", visible: :visible
      end

      def test_adds_drag_and_touch_swipe_viewport_affordances_when_enabled
        render_inline(Component.new(slides: sample_slides, touch_swipe: true))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "cursor-grab"
        assert_includes viewport[:class], "select-none"
        assert_includes viewport[:style], "touch-action: pan-y"
      end

      def test_omits_drag_and_touch_swipe_viewport_affordances_when_disabled
        render_inline(Component.new(slides: sample_slides, touch_swipe: false))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        refute_includes viewport[:class], "cursor-grab"
        refute_includes viewport[:class], "select-none"
        refute_includes viewport[:style], "touch-action: pan-y"
      end

      def test_renders_thumbs_when_enabled
        render_inline(Component.new(slides: sample_slides, show_thumbs: true))

        assert_selector "button[data-flat-pack--carousel-target='thumb']", count: 3

        thumb = page.find("button[data-flat-pack--carousel-target='thumb']", match: :first)

        assert_includes thumb[:class], "cursor-pointer"
        assert_includes thumb[:class], "hover:opacity-100"
        assert_includes thumb[:class], "hover:ring-2"
        assert_includes thumb[:class], "hover:ring-primary"
      end

      def test_thumbs_force_root_overflow_visible_to_preserve_active_ring
        render_inline(Component.new(slides: sample_slides, show_thumbs: true, class: "overflow-hidden rounded-2xl"))

        root = page.find("section[data-controller='flat-pack--carousel']")

        assert_includes root[:class], "overflow-visible"
        refute_includes root[:class], "overflow-hidden"
        assert_includes root[:class], "rounded-2xl"
      end

      def test_sanitizes_html_slides
        render_inline(
          Component.new(
            slides: [
              {
                type: :html,
                html: "<label for='lead_email'>Work email</label><input id='lead_email' name='lead[email]' type='text' required><script>alert('x')</script><a href='javascript:alert(1)'>bad</a>"
              }
            ]
          )
        )

        assert_includes rendered_content, "<label for=\"lead_email\">Work email</label>"
        assert_selector "input#lead_email[name='lead[email]'][type='text'][required]", visible: :all
        refute_includes rendered_content, "<script>"
        refute_includes rendered_content, "javascript:alert"
      end

      def test_renders_video_poster_as_absolute_background_image
        render_inline(Component.new(slides: sample_slides))

        assert_includes rendered_content, "<img src=\"https://images.example.com/poster.jpg\""
        assert_includes rendered_content, "class=\"absolute inset-0 h-full w-full object-cover pointer-events-none\""
        assert_includes rendered_content, "aria-hidden=\"true\""
        assert_selector "video.absolute.inset-0.z-10.block.h-full.w-full.bg-black.object-contain", visible: :all
        assert_selector "video source[src='https://videos.example.com/two.mp4'][type='video/mp4']", visible: :all

        video = page.find("video.absolute.inset-0.z-10.block.h-full.w-full.bg-black.object-contain", visible: :all)
        assert_nil video[:poster]
        assert_equal "width: 100%; height: 100%; object-fit: contain;", video[:style]
      end

      def test_ignores_invalid_slide_sources
        render_inline(
          Component.new(
            slides: [
              {type: :image, src: "javascript:alert('x')"},
              {type: :image, src: "https://images.example.com/ok.jpg"}
            ]
          )
        )

        assert_selector "div[data-flat-pack--carousel-target='slide']", count: 1, visible: :all
      end

      def test_rejects_invalid_configuration
        assert_raises(ArgumentError) do
          Component.new(slides: sample_slides, transition: :zoom)
        end

        assert_raises(ArgumentError) do
          Component.new(slides: sample_slides, caption_mode: :floating)
        end

        assert_raises(ArgumentError) do
          Component.new(slides: sample_slides, aspect_ratio: "wide")
        end

        assert_raises(ArgumentError) do
          Component.new(slides: sample_slides, variant: :logo_slider, transition: :fade)
        end
      end

      def test_requires_at_least_one_valid_slide
        assert_raises(ArgumentError) do
          Component.new(slides: [{type: :image, src: "javascript:alert('x')"}])
        end
      end
    end
  end
end
