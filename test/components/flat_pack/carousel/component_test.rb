# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Carousel
    class ComponentTest < ViewComponent::TestCase
      def build_carousel(component = Component.new, with_thumbnail: false)
        render_inline(component) do |carousel|
          carousel.slide(alt: "Slide one", thumbnail_url: (with_thumbnail ? "/thumb-1.png" : nil)) { "Slide 1" }
          carousel.slide(alt: "Slide two", thumbnail_url: (with_thumbnail ? "/thumb-2.png" : nil)) { "Slide 2" }
          carousel.slide(alt: "Slide three", thumbnail_url: (with_thumbnail ? "/thumb-3.png" : nil)) { "Slide 3" }
        end
      end

      def build_single_slide_carousel(component = Component.new)
        render_inline(component) do |carousel|
          carousel.slide(alt: "Slide one") { "Slide 1" }
        end
      end

      def test_renders_carousel_container
        build_carousel

        assert_selector "div[role='region'][aria-roledescription='carousel']"
      end

      def test_renders_slides
        build_carousel

        assert_selector "div[data-flat-pack--carousel-target='slide']", count: 3
      end

      def test_renders_indicators_by_default
        build_carousel

        assert_selector "button[data-flat-pack--carousel-target='indicator']", count: 3
      end

      def test_hides_indicators_when_disabled
        build_carousel(Component.new(show_indicators: false))

        refute_selector "button[data-flat-pack--carousel-target='indicator']"
      end

      def test_renders_prev_next_controls
        build_carousel

        assert_selector "button[aria-label='Previous slide']"
        assert_selector "button[aria-label='Next slide']"
      end

      def test_hides_controls_when_disabled
        build_carousel(Component.new(show_controls: false))

        refute_selector "button[aria-label='Previous slide']"
        refute_selector "button[aria-label='Next slide']"
      end

      def test_hides_controls_for_single_slide
        build_single_slide_carousel

        refute_selector "button[aria-label='Previous slide']"
        refute_selector "button[aria-label='Next slide']"
      end

      def test_hides_indicators_for_single_slide
        build_single_slide_carousel

        refute_selector "button[data-flat-pack--carousel-target='indicator']"
      end

      def test_renders_counter_when_enabled
        build_carousel(Component.new(show_counter: true))

        assert_selector "div[data-flat-pack--carousel-target='counter']", text: "1 / 3"
      end

      def test_hides_counter_by_default
        build_carousel

        refute_selector "div[data-flat-pack--carousel-target='counter']"
      end

      def test_has_stimulus_controller
        build_carousel

        assert_selector "div[data-controller='flat-pack--carousel']"
      end

      def test_autoplay_value_passed
        build_carousel(Component.new(autoplay: true))

        assert_selector "div[data-flat-pack--carousel-autoplay-value='true']"
      end

      def test_interval_value_passed
        build_carousel(Component.new(interval: 6000))

        assert_selector "div[data-flat-pack--carousel-interval-value='6000']"
      end

      def test_transition_slide
        build_carousel(Component.new(transition: :slide))

        assert_selector "div[data-flat-pack--carousel-transition-value='slide']"
      end

      def test_transition_fade
        build_carousel(Component.new(transition: :fade))

        assert_selector "div[data-flat-pack--carousel-transition-value='fade']"
      end

      def test_invalid_transition_raises
        assert_raises(ArgumentError) { Component.new(transition: :invalid) }
      end

      def test_invalid_aspect_ratio_raises
        assert_raises(ArgumentError) { Component.new(aspect_ratio: :invalid) }
      end

      def test_invalid_interval_raises
        assert_raises(ArgumentError) { Component.new(interval: 999) }
      end

      def test_aspect_ratio_square
        build_carousel(Component.new(aspect_ratio: :square))

        assert_selector "div.aspect-square[data-flat-pack--carousel-target='viewport']"
        assert_selector "div[data-flat-pack--carousel-target='viewport'][style*='aspect-ratio: 1 / 1']"
      end

      def test_aspect_ratio_video
        build_carousel(Component.new(aspect_ratio: :video))

        assert_selector "div.aspect-video[data-flat-pack--carousel-target='viewport']"
        assert_selector "div[data-flat-pack--carousel-target='viewport'][style*='aspect-ratio: 16 / 9']"
      end

      def test_aspect_ratio_wide
        build_carousel(Component.new(aspect_ratio: :wide))

        assert_selector "div.aspect-\\[21\\/9\\][data-flat-pack--carousel-target='viewport']"
        assert_selector "div[data-flat-pack--carousel-target='viewport'][style*='aspect-ratio: 21 / 9']"
      end

      def test_renders_thumbnails_when_enabled
        build_carousel(Component.new(show_thumbnails: true), with_thumbnail: true)

        assert_selector "button[data-flat-pack--carousel-target='thumbnail']", count: 3
      end

      def test_renders_progress_bar_when_enabled
        build_carousel(Component.new(show_progress_bar: true))

        assert_selector "div[data-flat-pack--carousel-target='progressBar']"
      end

      def test_renders_live_region
        build_carousel

        assert_selector "div.sr-only[aria-live='polite'][data-flat-pack--carousel-target='liveRegion']"
      end

      def test_slides_have_aria_labels
        build_carousel

        assert_selector "div[aria-roledescription='slide'][aria-label='1 of 3']"
        assert_selector "div[aria-roledescription='slide'][aria-label='2 of 3']"
        assert_selector "div[aria-roledescription='slide'][aria-label='3 of 3']"
      end

      def test_system_arguments_forwarded
        build_carousel(Component.new(id: "my-carousel", class: "custom-carousel", data: {foo: "bar"}))

        assert_selector "div#my-carousel.custom-carousel[data-foo='bar']"
      end

      def test_start_slide_value
        build_carousel(Component.new(start_slide: 2))

        assert_selector "div[data-flat-pack--carousel-start-slide-value='2']"
      end

      def test_loop_value
        build_carousel(Component.new(loop: false))

        assert_selector "div[data-flat-pack--carousel-loop-value='false']"
      end
    end
  end
end
