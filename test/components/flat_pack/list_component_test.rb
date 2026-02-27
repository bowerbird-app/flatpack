# frozen_string_literal: true

require "test_helper"

module FlatPack
  module List
    class ComponentTest < ViewComponent::TestCase
      def test_renders_unordered_list_by_default
        render_inline(Component.new) { "content" }

        assert_selector "ul[role='list']"
      end

      def test_renders_ordered_list_when_ordered
        render_inline(Component.new(ordered: true)) { "content" }

        assert_selector "ol[role='list']"
      end

      def test_renders_list_items
        render_inline(Component.new) do
          "<li>Item 1</li><li>Item 2</li><li>Item 3</li>".html_safe
        end

        assert_selector "li", count: 3
        assert_text "Item 1"
        assert_text "Item 2"
        assert_text "Item 3"
      end

      def test_includes_spacing_classes
        render_inline(Component.new) { "content" }

        assert_includes page.native.to_html, "space-y-3"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class")) { "content" }

        assert_selector ".custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "my-list"})) { "content" }

        assert_selector "[data-testid='my-list']"
      end

      def test_renders_dense_spacing
        render_inline(Component.new(spacing: :dense)) { "content" }
        assert_includes page.native.to_html, "space-y-1"
      end

      def test_enables_selectable_behavior_when_requested
        render_inline(Component.new(selectable: true)) { "content" }

        assert_selector "ul[data-controller='flat-pack--list-selectable']"
        assert_selector "ul[data-action='click->flat-pack--list-selectable#activate']"
      end
    end
  end
end
