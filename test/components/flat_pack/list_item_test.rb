# frozen_string_literal: true

require "test_helper"

module FlatPack
  module List
    class ItemTest < ViewComponent::TestCase
      def test_renders_list_item
        render_inline(Item.new) { "Item content" }

        assert_selector "li[role='listitem']"
        assert_selector "span.flat-pack-list-item-marker[aria-hidden='true']"
        assert_text "Item content"
      end

      def test_renders_without_icon
        render_inline(Item.new) { "Content" }

        refute_selector "svg"
      end

      def test_renders_with_icon
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_selector "span svg[data-controller='flat-pack--icon'][data-flat-pack--icon-name-value='check']"
      end

      def test_inline_svg_icon_renders_as_an_svg_element
        svg = '  <svg data-logo="mark" viewBox="0 0 24 24"></svg>'
        render_inline(Item.new(icon: svg)) { "Content" }

        assert_selector "span.flat-pack-list-item-icon > svg[data-logo='mark']"
        refute_selector "svg[data-flat-pack--icon-name-value]"
        refute_includes page.native.to_html, "&lt;svg"
      end

      def test_icon_has_proper_styling
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_includes page.native.to_html, "flat-pack-list-item-icon"
        assert_includes page.native.to_html, "flex-shrink-0"
        refute_includes page.native.to_html, "text-[var(--surface-muted-content-color)]"
      end

      def test_named_icons_do_not_use_legacy_sprite_markup
        render_inline(Item.new(icon: :check)) { "Content" }

        refute_includes page.native.to_html, "xlink:href"
      end

      def test_content_wrapped_in_container
        render_inline(Item.new) { "Content" }

        assert_selector "div.min-w-0.flex-1", text: "Content"
      end

      def test_includes_flex_layout
        render_inline(Item.new) { "Content" }

        assert_includes page.native.to_html, "flex items-start"
        assert_selector "li.flex.items-start > span.flat-pack-list-item-marker"
      end

      def test_includes_padding_and_corner_radius
        render_inline(Item.new) { "Content" }

        assert_includes page.native.to_html, "py-[var(--list-item-padding-y)] px-[var(--list-item-padding-x)]"
        assert_includes page.native.to_html, "rounded-[var(--radius-sm)]"
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
        assert_selector "li a.flat-pack-list-item-link > span.flat-pack-list-item-marker[aria-hidden='true']:first-child"
        assert_includes page.native.to_html, "flat-pack-list-item-link"
        assert_includes page.native.to_html, "focus-visible:ring-inset"
      end

      def test_renders_hover_styles_when_hover_enabled
        render_inline(Item.new(href: "/demo/list", hover: true)) { "Content" }

        assert_includes page.native.to_html, "hover:bg-[var(--list-item-hover-background-color)]"
      end

      def test_renders_active_styles_when_active_enabled
        render_inline(Item.new(href: "/demo/list", active: true)) { "Content" }

        assert_selector "li[class*='bg-[var(--list-item-active-background-color)]']"
        assert_no_selector "a[class*='bg-[var(--list-item-active-background-color)]']"
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

      def test_key_value_row_renders_term_value_icon_and_trailing
        Rendering.with(layout: :key_value, stack_below: :sm) do
          render_inline(Item.new(key: " Guest code ", icon: :key, trailing: "Copy")) { "morning-b" }
        end

        assert_selector "div.flat-pack-list-key-value-row > dt > span.flat-pack-list-key", text: "Guest code"
        assert_selector "div.flat-pack-list-key-value-row > dd .flat-pack-list-value", text: "morning-b"
        assert_selector "dt span.flat-pack-list-item-icon[aria-hidden='true'] svg[data-flat-pack--icon-name-value='key']"
        assert_selector "dd span.flat-pack-list-key-value-trailing", text: "Copy"
        html = page.native.to_html
        assert_includes html, "sm:grid-cols-subgrid"
        assert_includes html, "text-[var(--surface-muted-content-color)]"
        assert_includes html, "break-words"
        refute_selector "li"
        refute_selector "a"
      end

      def test_key_value_without_an_icon_keeps_an_icon_slot
        Rendering.with(layout: :key_value) do
          render_inline(Item.new(key: "Room")) { "Studio B" }
        end

        assert_selector "dt span.flat-pack-list-key-value-icon-slot[aria-hidden='true']"
        refute_selector "svg"
      end

      def test_key_value_hides_the_empty_icon_slot_until_the_breakpoint
        Rendering.with(layout: :key_value, stack_below: :md) do
          render_inline(Item.new(key: "Room")) { "Studio B" }
        end

        assert_includes page.native.to_html, "hidden md:block"
      end

      def test_key_value_requires_a_key_and_rejects_href_and_leading
        error = assert_raises(ArgumentError) do
          Rendering.with(layout: :key_value) { Item.new }
        end
        assert_match(/key: is required/, error.message)

        error = assert_raises(ArgumentError) do
          Rendering.with(layout: :key_value) { Item.new(key: "   ") }
        end
        assert_match(/key: is required/, error.message)

        error = assert_raises(ArgumentError) do
          Rendering.with(layout: :key_value) { Item.new(key: :room) }
        end
        assert_match(/must be a String/, error.message)

        error = assert_raises(ArgumentError) do
          Rendering.with(layout: :key_value) { Item.new(key: "Room", href: "/demo/list") }
        end
        assert_match(/href/, error.message)

        error = assert_raises(ArgumentError) do
          Rendering.with(layout: :key_value) { Item.new(key: "Room", leading: "1") }
        end
        assert_match(/leading/, error.message)
      end

      def test_key_is_only_supported_in_a_key_value_list
        error = assert_raises(ArgumentError) { Item.new(key: "Room") }
        assert_match(/only supported/, error.message)
      end

      def test_marker_does_not_replace_icon_or_content
        render_inline(Item.new(icon: :check)) { "Content" }

        assert_selector "span.flat-pack-list-item-marker[aria-hidden='true']"
        assert_selector "span.flat-pack-list-item-icon svg[data-controller='flat-pack--icon'][data-flat-pack--icon-name-value='check']"
        assert_selector "div.min-w-0.flex-1", text: "Content"
      end
    end
  end
end
