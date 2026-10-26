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
        assert_selector "section.flat-pack-carousel > .flat-pack-carousel__viewport [data-flat-pack--carousel-target='slide']", count: 3, visible: :all
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
        assert_includes counter[:class], "bg-[var(--carousel-counter-background-color)]"
        assert_includes counter[:class], "text-[var(--carousel-counter-text-color)]"
        assert_includes indicators.find(:xpath, "ancestor::div[1]")[:class], "rounded-[var(--radius-full)]"
      end

      def test_renders_circular_flex_chevron_controls_with_tinted_round_background
        render_inline(Component.new(slides: sample_slides))

        prev_button = page.find("button[data-action='click->flat-pack--carousel#prev']")
        control_classes = prev_button[:class]

        assert_includes control_classes, "fp-button"
        assert_includes control_classes, "flat-pack-carousel__control"
        assert_includes control_classes, FlatPack::Button::Component::ROUND_RADIUS_CLASS
        assert_includes control_classes, "inline-flex"
        assert_includes control_classes, "cursor-pointer"
        assert_equal "secondary", prev_button["data-fp-style"]
        assert_equal "Previous slide", prev_button["aria-label"]
        assert_selector ".fp-overlay-icon-button button[data-action='click->flat-pack--carousel#prev']", visible: :all
        assert_selector "button[data-action='click->flat-pack--carousel#prev'] svg[data-flat-pack--icon-name-value='chevron-left']", visible: :all
        assert_selector "button[data-action='click->flat-pack--carousel#next'] svg[data-flat-pack--icon-name-value='chevron-right']", visible: :all
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        assert_includes css, ".fp-overlay-icon-button svg {\n  pointer-events: none;\n}"
        assert_includes css, "--button-secondary-background-color: var(--carousel-control-background-color);"
      end

      def test_hides_controls_until_hover_on_desktop_when_controls_on_hover_enabled
        render_inline(Component.new(slides: sample_slides, controls_on_hover: true))

        prev_button = page.find("button[data-action='click->flat-pack--carousel#prev']")
        control_classes = prev_button[:class]

        assert_includes control_classes, "md:opacity-0"
        assert_includes control_classes, "md:group-hover:opacity-100"
        assert_includes control_classes, "md:group-focus-within:opacity-100"

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "group"
      end

      def test_enables_lightbox_for_images_and_for_videos_when_asked
        render_inline(Component.new(slides: lightbox_slides))

        slides = page.all("section.flat-pack-carousel > .flat-pack-carousel__viewport [data-flat-pack--carousel-target='slide']", visible: :all)

        assert_equal "true", slides[0]["data-lightbox-enabled"]
        assert_equal "https://images.example.com/one.jpg", slides[0]["data-lightbox-src"]
        assert_equal "0", slides[0]["data-lightbox-index"]
        assert_equal "false", slides[1]["data-lightbox-enabled"]
        assert_nil slides[1]["data-lightbox-src"]
        assert_nil slides[1]["data-lightbox-index"]
        assert_equal "true", slides[2]["data-lightbox-enabled"]
        assert_equal "https://videos.example.com/two.mp4", slides[2]["data-lightbox-src"]
        assert_equal "1", slides[2]["data-lightbox-index"]
      end

      def test_keeps_the_lightbox_group_on_the_carousel_root
        render_inline(Component.new(slides: lightbox_slides))

        root = page.find("section.flat-pack-carousel")
        assert_match(/\Acarousel-/, root["data-flat-pack-lightbox-group"])

        page.all("[data-flat-pack--carousel-target='slide']", visible: :all).each do |slide|
          assert_nil slide["data-flat-pack-lightbox-group"]
          assert_nil slide["data-flat-pack-lightbox-index"]
        end

        page.all(
          "button[data-action='click->flat-pack--carousel#prev'], button[data-action='click->flat-pack--carousel#next'], button[data-flat-pack--carousel-target='indicator'], button[data-flat-pack--carousel-target='thumb']",
          visible: :all
        ).each do |control|
          assert_nil control["data-flat-pack-lightbox-group"]
          assert_nil control["data-flat-pack-lightbox-index"]
        end

        stage = page.find("dialog [data-flat-pack-lightbox-stage='true']", visible: :all)
        assert_nil stage["data-flat-pack-lightbox-group"]
      end

      def test_renders_lightbox_toggle_button_with_expand_icon
        render_inline(Component.new(slides: sample_slides))

        lightbox_toggle = page.find("button[data-flat-pack--carousel-target='lightboxToggle'][data-action='click->flat-pack--carousel#openLightbox']", visible: :all)

        assert_includes lightbox_toggle[:class], "top-3"
        assert_includes lightbox_toggle[:class], "fp-button"
        assert_equal "secondary", lightbox_toggle["data-fp-style"]
        assert_equal "click->flat-pack--carousel#openLightbox", lightbox_toggle["data-action"]
        assert_equal "lightboxToggle", lightbox_toggle["data-flat-pack--carousel-target"]
        refute_includes lightbox_toggle[:class], "top-12"
        assert_selector "button[data-flat-pack--carousel-target='lightboxToggle'] svg[data-flat-pack--icon-name-value='arrows-pointing-out']", visible: :all
      end

      def test_renders_shared_lightbox_dialog_for_enabled_image_and_video_slides
        render_inline(Component.new(slides: lightbox_slides))

        root = page.find("section.flat-pack-carousel")
        dialog = page.find("dialog[data-controller='flat-pack--lightbox']", visible: :all)
        refute root.has_css?("dialog", visible: :all)
        assert_equal root["data-flat-pack-lightbox-group"], dialog["data-flat-pack--lightbox-group-value"]
        assert page.has_css?("dialog[data-controller='flat-pack--lightbox'][hidden]", visible: :all)
        assert_includes dialog[:class], "backdrop:bg-[var(--modal-backdrop-color)]"

        stage = dialog.find("[data-flat-pack-lightbox-stage='true']", visible: :all)
        image = stage.find("img[src='https://images.example.com/one.jpg']", visible: :all)
        assert_includes image[:class], "object-contain"
        assert_includes image[:class], "bg-transparent"
        refute_includes image[:class], "lightbox-image-background-color"
        assert_includes image[:class], "w-full"
        video = stage.find("video", visible: :all)
        assert_includes video[:class], "bg-transparent"
        assert_includes video[:class], "object-contain"
        assert stage.has_css?("video source[src='https://videos.example.com/two.mp4']", visible: :all)
        refute_includes stage.native.to_html, "https://images.example.com/two.jpg"
        assert_includes dialog.native.to_html, "fp-overlay-pad"
        refute_includes dialog.native.to_html, "place-items-center"
        refute_includes dialog.native.to_html, "max-w-[90vw]"
        viewport = stage.find("[data-flat-pack--carousel-target='viewport']", visible: :all)
        assert_includes viewport[:class], "rounded-none"
        assert_includes viewport[:class], "bg-transparent"
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
            items_per_view_mobile: 1,
            items_per_view_tablet: 2,
            items_per_view_desktop: 3,
            side_preview: true,
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
        assert_equal "1", root["data-flat-pack--carousel-items-per-view-mobile-value"]
        assert_equal "2", root["data-flat-pack--carousel-items-per-view-tablet-value"]
        assert_equal "3", root["data-flat-pack--carousel-items-per-view-desktop-value"]
        assert_equal "false", root["data-flat-pack--carousel-side-preview-value"]
      end

      def test_exposes_side_preview_when_enabled_for_default_slide_variant
        render_inline(
          Component.new(
            slides: sample_slides,
            transition: :slide,
            side_preview: true,
            items_per_view_mobile: 1,
            items_per_view_tablet: 1,
            items_per_view_desktop: 3
          )
        )

        root = page.find("section[data-controller='flat-pack--carousel']")

        assert_equal "true", root["data-flat-pack--carousel-side-preview-value"]
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
              {type: :image, src: "https://images.example.com/a.svg", alt: "A"},
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

      def test_viewport_keeps_border_and_background_by_default
        render_inline(Component.new(slides: sample_slides))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "border-[var(--carousel-viewport-border-color)]"
        assert_includes viewport[:class], "bg-[var(--carousel-viewport-background-color)]"
        refute_includes viewport[:class], "border-0"
        refute_includes viewport[:class], "bg-transparent"
      end

      def test_hides_viewport_border_when_show_border_is_false
        render_inline(Component.new(slides: sample_slides, show_border: false))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "border-0"
        refute_includes viewport[:class], "border-[var(--carousel-viewport-border-color)]"
        assert_includes viewport[:class], "bg-[var(--carousel-viewport-background-color)]"
        refute_includes viewport[:class], "bg-transparent"
      end

      def test_hides_viewport_background_when_show_background_is_false
        render_inline(Component.new(slides: sample_slides, show_background: false))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "bg-transparent"
        refute_includes viewport[:class], "bg-[var(--carousel-viewport-background-color)]"
        assert_includes viewport[:class], "border-[var(--carousel-viewport-border-color)]"
        refute_includes viewport[:class], "border-0"
      end

      def test_hides_viewport_border_and_background_together
        render_inline(Component.new(slides: sample_slides, show_border: false, show_background: false))

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "border-0"
        assert_includes viewport[:class], "bg-transparent"
        refute_includes viewport[:class], "border-[var(--carousel-viewport-border-color)]"
        refute_includes viewport[:class], "bg-[var(--carousel-viewport-background-color)]"
      end

      def test_logo_slider_stays_borderless_and_transparent
        render_inline(
          Component.new(
            slides: [{type: :image, src: "https://images.example.com/a.svg", alt: "A"}],
            variant: :logo_slider,
            show_border: true,
            show_background: true
          )
        )

        viewport = page.find("div[data-flat-pack--carousel-target='viewport']")
        assert_includes viewport[:class], "border-0"
        assert_includes viewport[:class], "bg-transparent"
        assert_includes viewport[:style], "background: transparent"
        refute_includes viewport[:class], "border-[var(--carousel-viewport-border-color)]"
        refute_includes viewport[:class], "bg-[var(--carousel-viewport-background-color)]"
      end

      def test_renders_thumbs_when_enabled
        render_inline(Component.new(slides: sample_slides, show_thumbs: true))

        thumbs = page.all("button[data-flat-pack--carousel-target='thumb']")
        assert_equal 3, thumbs.length
        assert_includes rendered_content, "flex-wrap"
        assert_no_selector "[data-flat-pack--carousel-target='thumbStrip']", visible: :all

        image_thumb = thumbs[0].find("img")
        assert_equal "https://images.example.com/one.jpg", image_thumb[:src]
        assert_equal "Thumbnail 1", image_thumb[:alt]

        video_thumb = thumbs[1].find("img")
        assert_equal "https://images.example.com/poster.jpg", video_thumb[:src]
        assert_equal "Video thumbnail 2", video_thumb[:alt]

        assert_equal "3", thumbs[2].text.strip
        assert_includes thumbs[0][:class], "cursor-pointer"
        assert_includes thumbs[0][:class], "hover:opacity-100"
        assert_includes thumbs[0][:class], "hover:ring-2"
        assert_includes thumbs[0][:class], "hover:ring-primary"
      end

      def test_image_thumb_prefers_thumb_src_over_slide_src
        render_inline(
          Component.new(
            slides: [
              {
                type: :image,
                src: "https://images.example.com/full.jpg",
                thumb_src: "https://images.example.com/small.jpg",
                alt: "Full"
              }
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb'] img")
        assert_equal "https://images.example.com/small.jpg", thumb[:src]
      end

      def test_html_slide_uses_thumb_src_for_thumbnail
        render_inline(
          Component.new(
            slides: [
              {
                type: :html,
                html: "<p>Release notes</p>",
                thumb_src: "https://images.example.com/card.jpg",
                caption: "Notes"
              }
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb']")
        image = thumb.find("img")

        assert_equal "https://images.example.com/card.jpg", image[:src]
        assert_equal "Thumbnail 1", image[:alt]
        assert_includes rendered_content, "<p>Release notes</p>"
      end

      def test_html_slide_accepts_thumb_alias
        render_inline(
          Component.new(
            slides: [
              {
                type: :html,
                html: "<p>Workshop</p>",
                thumb: "https://images.example.com/alias.jpg"
              }
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb'] img")
        assert_equal "https://images.example.com/alias.jpg", thumb[:src]
      end

      def test_html_slide_without_thumb_shows_slide_number
        render_inline(
          Component.new(
            slides: [
              {type: :html, html: "<p>No picture</p>"}
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb']")

        assert_equal "1", thumb.text.strip
        assert_no_selector "button[data-flat-pack--carousel-target='thumb'] img"
      end

      def test_html_slide_drops_unsafe_thumb_url
        render_inline(
          Component.new(
            slides: [
              {
                type: :html,
                html: "<p>Notes</p>",
                thumb_src: "javascript:alert(1)"
              },
              {
                type: :html,
                html: "<p>Also notes</p>",
                thumb: "data:text/html,hi"
              },
              {
                type: :html,
                html: "<p>Blank</p>",
                thumb_src: "  "
              }
            ],
            show_thumbs: true
          )
        )

        thumbs = page.all("button[data-flat-pack--carousel-target='thumb']")

        assert_equal %w[1 2 3], thumbs.map { |thumb| thumb.text.strip }
        assert_no_selector "button[data-flat-pack--carousel-target='thumb'] img"
        refute_includes rendered_content, "javascript:"
        refute_includes rendered_content, "data:text/html"
      end

      def test_html_slide_accepts_relative_thumb_path
        render_inline(
          Component.new(
            slides: [
              {type: :html, html: "<p>Local</p>", thumb_src: "/images/card.jpg"}
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb'] img")
        assert_equal "/images/card.jpg", thumb[:src]
      end

      def test_video_thumb_keeps_poster_when_thumb_src_is_passed
        render_inline(
          Component.new(
            slides: [
              {
                type: :video,
                src: "https://videos.example.com/two.mp4",
                poster: "https://images.example.com/poster.jpg",
                thumb_src: "https://images.example.com/other.jpg"
              }
            ],
            show_thumbs: true
          )
        )

        thumb = page.find("button[data-flat-pack--carousel-target='thumb'] img")
        assert_equal "https://images.example.com/poster.jpg", thumb[:src]
        assert_equal "Video thumbnail 1", thumb[:alt]
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
        video = page.find("video", visible: :all)
        assert_includes video[:class], "bg-[var(--carousel-media-background-color)]"
        assert_includes video[:class], "object-contain"
        assert_selector "video source[src='https://videos.example.com/two.mp4'][type='video/mp4']", visible: :all

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

        assert_selector "section.flat-pack-carousel > .flat-pack-carousel__viewport [data-flat-pack--carousel-target='slide']", count: 1, visible: :all
      end

      def test_preserves_chart_data_attributes_in_html_slides
        render_inline(
          Component.new(
            slides: [
              {
                type: :html,
                html: '<div data-controller="flat-pack--chart" data-flat-pack--chart-series-value="[{&quot;name&quot;:&quot;Users&quot;,&quot;data&quot;:[1,2,3]}]" data-flat-pack--chart-type-value="line" data-flat-pack--chart-options-value="{}" data-flat-pack--chart-height-value="220"></div>'
              }
            ]
          )
        )

        assert_selector "div[data-controller='flat-pack--chart'][data-flat-pack--chart-type-value='line']", visible: :all
      end

      def test_hides_controls_when_items_per_view_exceeds_slide_count
        render_inline(
          Component.new(
            slides: sample_slides,
            items_per_view_mobile: 4,
            items_per_view_tablet: 4,
            items_per_view_desktop: 4,
            show_controls: true,
            show_indicators: true
          )
        )

        assert_no_selector "button[data-action='click->flat-pack--carousel#prev']"
        assert_no_selector "button[data-action='click->flat-pack--carousel#next']"
        assert_no_selector "button[data-flat-pack--carousel-target='indicator']"
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

        assert_raises(ArgumentError) do
          Component.new(slides: sample_slides, fit: :stretch)
        end
      end

      def test_show_counter_false_omits_the_count_and_contain_keeps_the_frame
        render_inline(Component.new(slides: sample_slides, show_counter: false, fit: :contain))

        assert_no_selector "[data-flat-pack--carousel-target='counter']", visible: :all
        image = page.find("section.flat-pack-carousel > .flat-pack-carousel__viewport img[alt='Slide one']", visible: :all)
        assert_includes image[:class], "object-contain"
        assert_includes image[:class], "bg-[var(--carousel-lightbox-image-background-color)]"
        viewport = page.find("section.flat-pack-carousel > .flat-pack-carousel__viewport")
        assert_includes viewport[:style], "aspect-ratio"
        refute_includes viewport[:class], "rounded-none"
      end

      def test_requires_at_least_one_valid_slide
        assert_raises(ArgumentError) do
          render_inline(Component.new(slides: [{type: :image, src: "javascript:alert('x')"}]))
        end
      end

      def test_item_slot_renders_trusted_markup_without_a_fixed_frame
        view = vc_test_controller.view_context

        render_inline(Component.new(
          side_preview: true,
          bleed: true,
          show_controls: true
        )) do |carousel|
          carousel.with_item do
            view.safe_join([
              view.tag.img(src: "/artwork.jpg", alt: "Cover"),
              view.tag.button(type: "button", data: {action: "click->player#play"}) { "Play" }
            ])
          end
          carousel.with_item { "Next episode" }
        end

        assert_selector "img[src='/artwork.jpg'][alt='Cover']", visible: :all
        assert_selector "button[data-action='click->player#play']", text: "Play", visible: :all
        refute_selector "[data-flat-pack--carousel-target='slide'] .overflow-auto.p-4", visible: :all

        viewport = page.find(".flat-pack-carousel__viewport")
        refute_includes viewport[:style].to_s, "aspect-ratio"
        assert_includes viewport[:style].to_s, "height: auto"
        assert_includes viewport[:class], "border-0"
        assert_includes viewport[:class], "bg-transparent"
        assert_includes viewport[:style], "var(--carousel-bleed, var(--card-inset, var(--card-padding-md)))"
        assert_includes viewport[:style], "margin-inline: calc(-1 * var(--carousel-bleed, var(--card-inset, var(--card-padding-md))))"
        assert_includes viewport[:style], "padding-inline-start: var(--carousel-bleed, var(--card-inset, var(--card-padding-md)))"
        assert_includes viewport[:style], "width: calc(100% + 2 * var(--carousel-bleed, var(--card-inset, var(--card-padding-md))))"

        control = page.find("button[data-action='click->flat-pack--carousel#prev']", visible: :all)
        assert_includes control[:class], "absolute"
        assert_includes control[:class], "flat-pack-carousel__control"
        assert_includes control[:class], "flat-pack-carousel__control--touch-hidden"
        assert_selector "[data-flat-pack--carousel-side-preview-value='true']"

        frame = page.find(".flat-pack-carousel__frame--items")
        assert_includes frame[:class], "h-auto"

        slide = page.all("[data-flat-pack--carousel-target='slide']", visible: :all).first
        assert_includes slide[:class], "h-auto"
        assert_includes slide[:class], "flat-pack-carousel__slide--item"
        refute_includes slide[:class], "h-full"
        refute_includes slide[:class], "self-stretch"
      end

      def test_controls_on_touch_defaults_and_overrides
        view = vc_test_controller.view_context

        render_inline(Component.new(controls_on_touch: true, show_controls: true)) do |carousel|
          carousel.with_item { view.tag.p("One") }
          carousel.with_item { view.tag.p("Two") }
        end

        shown = page.find("button[data-action='click->flat-pack--carousel#prev']", visible: :all)
        refute_includes shown[:class], "flat-pack-carousel__control--touch-hidden"

        render_inline(Component.new(
          slides: sample_slides.first(2),
          controls_on_touch: false,
          show_controls: true
        ))

        hidden = page.find("button[data-action='click->flat-pack--carousel#prev']", visible: :all)
        assert_includes hidden[:class], "flat-pack-carousel__control--touch-hidden"
      end

      def test_hash_slides_keep_sanitized_html_and_the_aspect_ratio
        render_inline(Component.new(slides: [
          {
            type: :html,
            html: "<button type=\"button\" data-action=\"click->player#play\">Play</button><img src=\"/artwork.jpg\" alt=\"Cover\"><p>Keep</p>"
          },
          {type: :image, src: "https://images.example.com/two.jpg", alt: "Two"}
        ]))

        html = page.native.to_html
        assert_includes html, "<p>Keep</p>"
        assert_includes html, "overflow-auto p-4"
        refute_includes html, "click->player#play"
        refute_includes html, "src=\"/artwork.jpg\""

        viewport = page.find(".flat-pack-carousel__viewport")
        assert_includes viewport[:style], "aspect-ratio: 16/9"
        refute_includes viewport[:style].to_s, "margin-inline"
        assert_includes viewport[:class], "border"
        refute_includes viewport[:class], "border-0"
        control = page.find("button[data-action='click->flat-pack--carousel#prev']", visible: :all)
        assert_includes control[:class], "absolute"
        refute_includes control[:class], "flat-pack-carousel__control--touch-hidden"
        refute_includes html, "flat-pack-carousel__slide--item"
        refute_includes html, "flat-pack-carousel__frame--items"
      end

      def test_peek_token_and_touch_rule_live_in_kit_css
        variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
        application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/carousel_controller.js").read

        assert_match(/--carousel-peek:\s*0\.25;/, variables)
        assert_includes application, ".flat-pack-carousel__slide--item > .fp-card"
        frame_rule = application[application.index(".flat-pack-carousel__frame--items"), 80]
        assert_includes frame_rule, "align-items: stretch"
        refute_includes frame_rule, "flex-start"
        card_rule = application[application.index(".flat-pack-carousel__slide--item > .fp-card {"), 120]
        assert_includes card_rule, "min-height: 100%"
        assert_includes card_rule, "flex: 1 1 auto"
        slide_rule = application[application.index(".flat-pack-carousel__slide--item {"), 240]
        assert_includes slide_rule, "padding-inline-end: var(--space-3)"
        assert_includes slide_rule, "box-sizing: border-box"
        refute_includes application, "--carousel-gap"
        assert_includes application, ".flat-pack-carousel__control--touch-hidden"
        touch_rule = application[application.index("@media (hover: none)"), 220]
        assert_includes touch_rule, ".flat-pack-carousel__control--touch-hidden"
        refute_includes touch_rule, "data-theme="
        assert_includes controller, 'getPropertyValue("--carousel-peek")'
        refute_includes controller, "perView + 0.25"
      end
    end
  end
end
