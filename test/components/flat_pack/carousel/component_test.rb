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

      def test_renders_carousel_shell_with_targets
        render_inline(Component.new(slides: sample_slides))

        assert_selector "section[data-controller='flat-pack--carousel']"
        assert_selector "div[data-flat-pack--carousel-target='slide']", count: 3, visible: :all
        assert_selector "button[data-flat-pack--carousel-target='indicator']", count: 3
        indicator = page.find("button[data-flat-pack--carousel-target='indicator']", match: :first)
        assert_includes indicator[:class], "cursor-pointer"
        assert_selector "button[data-action='click->flat-pack--carousel#prev']"
        assert_selector "button[data-action='click->flat-pack--carousel#next']"
      end

      def test_renders_circular_flex_chevron_controls_with_theme_token_background
        render_inline(Component.new(slides: sample_slides))

        prev_button = page.find("button[data-action='click->flat-pack--carousel#prev']")
        control_classes = prev_button[:class]

        assert_includes control_classes, "rounded-[9999px]"
        assert_includes control_classes, "aspect-square"
        assert_includes control_classes, "flex"
        assert_includes control_classes, "cursor-pointer"
        assert_includes control_classes, "bg-[var(--carousel-chevron-background-color)]"
        assert_includes rendered_content, "#icon-chevron-left"
        assert_includes rendered_content, "#icon-chevron-right"
        assert_selector "button[data-action='click->flat-pack--carousel#prev'] svg.pointer-events-none", visible: :all
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

      def test_defaults_transition_to_slide
        render_inline(Component.new(slides: sample_slides))

        root = page.find("section[data-controller='flat-pack--carousel']")
        assert_equal "true", root["data-flat-pack--carousel-loop-value"]
        assert_equal "slide", root["data-flat-pack--carousel-transition-value"]
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
        assert_includes rendered_content, "<input id=\"lead_email\" name=\"lead[email]\" type=\"text\" required=\"required\">"
        refute_includes rendered_content, "<script>"
        refute_includes rendered_content, "javascript:alert"
      end

      def test_renders_video_poster_as_absolute_background_image
        render_inline(Component.new(slides: sample_slides))

        assert_includes rendered_content, "<img src=\"https://images.example.com/poster.jpg\""
        assert_includes rendered_content, "class=\"absolute inset-0 h-full w-full object-cover\""
        assert_includes rendered_content, "aria-hidden=\"true\""
        assert_selector "video.relative.z-10.h-full.w-full.object-cover", visible: :all
        assert_selector "video source[src='https://videos.example.com/two.mp4'][type='video/mp4']", visible: :all

        video = page.find("video.relative.z-10.h-full.w-full.object-cover", visible: :all)
        assert_nil video[:poster]
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
      end

      def test_requires_at_least_one_valid_slide
        assert_raises(ArgumentError) do
          Component.new(slides: [{type: :image, src: "javascript:alert('x')"}])
        end
      end
    end
  end
end
