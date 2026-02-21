# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Timeline
    class ComponentTest < ViewComponent::TestCase
      def test_renders_timeline_container
        render_inline(Component.new) { "content" }

        assert_selector "[role='list']"
      end

      def test_includes_relative_positioning
        render_inline(Component.new) { "content" }

        assert_includes page.native.to_html, "relative"
      end

      def test_includes_spacing
        render_inline(Component.new) { "content" }

        assert_includes page.native.to_html, "space-y-8"
      end

      def test_renders_timeline_items
        render_inline(Component.new) do
          safe_join([
            tag.div("Item 1"),
            tag.div("Item 2")
          ])
        end

        assert_text "Item 1"
        assert_text "Item 2"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class")) { "content" }

        assert_selector ".custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "timeline"})) { "content" }

        assert_selector "[data-testid='timeline']"
      end
    end
  end
end
