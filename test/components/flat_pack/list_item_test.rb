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
        assert_includes page.native.to_html, "#icon-check"
      end

      def test_icon_has_proper_styling
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_includes page.native.to_html, "flex-shrink-0"
        assert_includes page.native.to_html, "text-[var(--surface-muted-content-color)]"
      end

      def test_content_wrapped_in_span
        render_inline(Item.new) { "Content" }

        assert_selector "span.min-w-0.flex-1", text: "Content"
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

      def test_renders_link_when_href_is_present
        render_inline(Item.new(href: "/demo/list")) { "Content" }

        assert_selector "li a[href='/demo/list']", text: "Content"
        assert_includes page.native.to_html, "flat-pack-list-item-link"
      end

      def test_renders_hover_styles_when_hover_enabled
        render_inline(Item.new(href: "/demo/list", hover: true)) { "Content" }

        assert_includes page.native.to_html, "hover:bg-[var(--list-item-hover-background-color)]"
      end

      def test_renders_active_styles_when_active_enabled
        render_inline(Item.new(href: "/demo/list", active: true)) { "Content" }

        assert_includes page.native.to_html, "bg-[var(--list-item-active-background-color)]"
      end

      def test_accepts_link_arguments
        render_inline(Item.new(href: "/demo/list", link_arguments: {data: {turbo_frame: "chat-demo-panel"}})) { "Content" }

        assert_selector "li a[data-turbo-frame='chat-demo-panel']"
      end

      def test_raises_error_for_unsafe_href
        assert_raises ArgumentError do
          Item.new(href: "javascript:alert('xss')")
        end
      end
    end
  end
end
