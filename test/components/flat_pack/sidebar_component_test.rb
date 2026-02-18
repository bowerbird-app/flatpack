# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    class ComponentTest < ViewComponent::TestCase
      def test_renders_basic_sidebar
        render_inline(Component.new)
        assert_selector "aside"
      end

      def test_renders_with_collapsed_false
        render_inline(Component.new(collapsed: false))
        assert_selector "aside"
      end

      def test_renders_with_collapsed_true
        render_inline(Component.new(collapsed: true))
        assert_selector "aside"
      end

      def test_renders_header_slot
        render_inline(Component.new) do |sidebar|
          sidebar.header do
            "Header content"
          end
        end
        assert_text "Header content"
      end

      def test_renders_items_slot
        render_inline(Component.new) do |sidebar|
          sidebar.items do
            "Items content"
          end
        end
        assert_text "Items content"
      end

      def test_renders_footer_slot
        render_inline(Component.new) do |sidebar|
          sidebar.footer do
            "Footer content"
          end
        end
        assert_text "Footer content"
      end

      def test_renders_all_slots
        render_inline(Component.new) do |sidebar|
          sidebar.header { "Header" }
          sidebar.items { "Items" }
          sidebar.footer { "Footer" }
        end
        assert_text "Header"
        assert_text "Items"
        assert_text "Footer"
      end

      def test_items_container_is_scrollable
        render_inline(Component.new) do |sidebar|
          sidebar.items { "Items" }
        end
        assert_selector "div.flex-1.overflow-y-auto"
      end

      def test_has_correct_layout_classes
        render_inline(Component.new)
        assert_includes page.native.to_html, "flex flex-col"
        assert_includes page.native.to_html, "h-full"
      end

      def test_has_border
        render_inline(Component.new)
        assert_includes page.native.to_html, "border-r"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-sidebar"))
        assert_includes page.native.to_html, "custom-sidebar"
      end
    end
  end
end
