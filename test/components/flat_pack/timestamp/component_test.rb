# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Timestamp
    class ComponentTest < ViewComponent::TestCase
      def test_renders_past_timestamp_with_ago_suffix
        render_inline(Component.new(timestamp: 3.minutes.ago))

        assert_text "ago"
      end

      def test_renders_future_timestamp_with_from_now_suffix
        render_inline(Component.new(timestamp: 3.minutes.from_now))

        assert_text "from now"
      end

      def test_renders_fallback_text_for_nil_timestamp
        render_inline(Component.new(timestamp: nil, fallback_text: "Unavailable"))

        assert_selector "span.flat-pack-timestamp.inline-flex.mb-0", text: "Unavailable"
        refute_selector "[data-controller='flat-pack--tooltip']"
      end

      def test_renders_fallback_text_for_invalid_timestamp
        render_inline(Component.new(timestamp: "not-a-timestamp", fallback_text: "Unavailable"))

        assert_selector "span", text: "Unavailable"
      end

      def test_applies_class_name_to_fallback_rendering
        render_inline(Component.new(timestamp: nil, fallback_text: "Unavailable", class_name: "text-green-600 text-xs"))

        assert_selector "span.flat-pack-timestamp.text-green-600.text-xs", text: "Unavailable"
      end

      def test_renders_tooltip_with_top_placement_by_default
        render_inline(Component.new(timestamp: Time.zone.parse("2026-06-10 09:30:00")))

        assert_selector "div[data-controller='flat-pack--tooltip']"
        assert_selector "div[data-flat-pack--tooltip-placement-value='top']"
      end

      def test_accepts_custom_tooltip_placement
        render_inline(Component.new(timestamp: Time.zone.parse("2026-06-10 09:30:00"), tooltip_placement: :right))

        assert_selector "div[data-flat-pack--tooltip-placement-value='right']"
      end

      def test_sets_timestamp_stimulus_data_attributes
        render_inline(Component.new(timestamp: Time.zone.parse("2026-06-10 09:30:00")))

        assert_selector "time.flat-pack-timestamp.cursor-help.mb-0[data-controller='flat-pack--timestamp']"
        assert_selector "time[data-flat-pack--timestamp-iso-value]"
        assert_selector "time[data-flat-pack--timestamp-fallback-value]"
        assert_selector "time[data-flat-pack--timestamp-format-value='%e %b %Y %l:%M%P']"
      end

      def test_class_name_can_override_default_margin
        render_inline(Component.new(timestamp: Time.zone.parse("2026-06-10 09:30:00"), class_name: "mb-4"))

        assert_selector "time.flat-pack-timestamp.cursor-help.mb-4"
        refute_selector "time.mb-0"
      end

      def test_applies_class_name_to_timestamp_time_element
        render_inline(Component.new(timestamp: Time.zone.parse("2026-06-10 09:30:00"), class_name: "text-green-600 text-xs"))

        assert_selector "time.flat-pack-timestamp.cursor-help.text-green-600.text-xs"
      end

      def test_raises_error_for_invalid_tooltip_placement
        assert_raises(ArgumentError) do
          Component.new(timestamp: Time.zone.now, tooltip_placement: :invalid)
        end
      end
    end
  end
end
