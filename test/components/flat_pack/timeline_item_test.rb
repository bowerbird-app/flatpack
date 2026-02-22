# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Timeline
    class ItemTest < ViewComponent::TestCase
      def test_renders_timeline_item
        render_inline(Item.new(title: "Event"))

        assert_selector "[role='listitem']"
        assert_selector "h3", text: "Event"
      end

      def test_renders_title
        render_inline(Item.new(title: "Deployment Successful"))

        assert_selector "h3", text: "Deployment Successful"
      end

      def test_renders_timestamp
        render_inline(Item.new(title: "Event", timestamp: "2 hours ago"))

        assert_selector "time", text: "2 hours ago"
      end

      def test_does_not_render_timestamp_when_not_provided
        render_inline(Item.new(title: "Event"))

        refute_selector "time"
      end

      def test_renders_content_block
        render_inline(Item.new(title: "Event")) { "Event details here" }

        assert_text "Event details here"
      end

      def test_renders_description
        render_inline(Item.new(title: "Event", description: "Described event"))
        assert_text "Described event"
      end

      def test_renders_default_variant
        render_inline(Item.new(title: "Event"))

        assert_includes page.native.to_html, "bg-primary"
      end

      def test_renders_success_variant
        render_inline(Item.new(title: "Event", variant: :success))

        assert_includes page.native.to_html, "bg-success-bg"
      end

      def test_renders_warning_variant
        render_inline(Item.new(title: "Event", variant: :warning))

        assert_includes page.native.to_html, "bg-warning-bg"
      end

      def test_renders_danger_variant
        render_inline(Item.new(title: "Event", variant: :danger))

        assert_includes page.native.to_html, "bg-destructive-bg"
      end

      def test_renders_icon_circle
        render_inline(Item.new(title: "Event"))

        assert_selector ".w-10.h-10.rounded-full"
      end

      def test_renders_connecting_line_when_not_last
        render_inline(Item.new(title: "Event", last: false))

        assert_includes page.native.to_html, "w-0.5"
        assert_includes page.native.to_html, "bg-[var(--surface-border-color)]"
      end

      def test_does_not_render_connecting_line_when_last
        render_inline(Item.new(title: "Event", last: true))

        # Check that line is not present by looking for specific marker content
        refute_includes page.native.to_html, "min-h-[2rem]"
      end

      def test_includes_flex_layout
        render_inline(Item.new(title: "Event"))

        assert_includes page.native.to_html, "flex"
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Item.new
        end
      end

      def test_raises_error_for_invalid_variant
        assert_raises(ArgumentError) do
          Item.new(title: "Event", variant: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Item.new(title: "Event", class: "custom-class"))

        assert_selector ".custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Item.new(title: "Event", data: {testid: "timeline-item"}))

        assert_selector "[data-testid='timeline-item']"
      end
    end
  end
end
