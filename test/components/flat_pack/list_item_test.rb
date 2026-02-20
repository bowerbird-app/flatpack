# frozen_string_literal: true

require "test_helper"

module FlatPack
  module List
    class ItemTest < ViewComponent::TestCase
      def test_renders_list_item
        render_inline(Item.new) { "Item content" }

        assert_selector "li[role='listitem']"
        assert_text "Item content"
      end

      def test_renders_without_icon
        render_inline(Item.new) { "Content" }

        refute_selector "svg"
      end

      def test_renders_with_icon
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_selector "svg"
        assert_selector "use[xlink:href='#icon-check']"
      end

      def test_icon_has_proper_styling
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_includes page.native.to_html, "flex-shrink-0"
        assert_includes page.native.to_html, "text-[var(--color-text-muted)]"
      end

      def test_content_wrapped_in_span
        render_inline(Item.new) { "Content" }

        assert_selector "span.flex-1", text: "Content"
      end

      def test_includes_flex_layout
        render_inline(Item.new) { "Content" }

        assert_includes page.native.to_html, "flex items-start"
      end

      def test_includes_padding
        render_inline(Item.new) { "Content" }

        assert_includes page.native.to_html, "py-2 px-3"
      end

      def test_merges_custom_classes
        render_inline(Item.new(class: "custom-class")) { "Content" }

        assert_selector "li.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Item.new(data: {testid: "list-item"})) { "Content" }

        assert_selector "li[data-testid='list-item']"
      end
    end
  end
end
