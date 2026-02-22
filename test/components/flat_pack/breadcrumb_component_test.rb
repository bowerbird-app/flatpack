# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Breadcrumb
    class ComponentTest < ViewComponent::TestCase
      # Basic Rendering Tests
      def test_renders_breadcrumb_with_items
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products", href: "/products")
          breadcrumb.item(text: "Laptops")
        end

        assert_selector "nav[aria-label='Breadcrumb']"
        assert_selector "ol"
        assert_selector "li", count: 5 # 3 items + 2 separators
        assert_text "Home"
        assert_text "Products"
        assert_text "Laptops"
      end

      def test_renders_single_item
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
        end

        assert_selector "nav"
        assert_selector "li", count: 1
        assert_text "Home"
      end

      def test_renders_multiple_items
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Item 1", href: "/1")
          breadcrumb.item(text: "Item 2", href: "/2")
          breadcrumb.item(text: "Item 3", href: "/3")
        end

        assert_selector "li", count: 5 # 3 items + 2 separators
        assert_text "Item 1"
        assert_text "Item 2"
        assert_text "Item 3"
      end

      def test_renders_current_item_without_link
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Current Page")
        end

        assert_selector "a[href='/']", text: "Home"
        assert_selector "span[aria-current='page']", text: "Current Page"
        refute_selector "a", text: "Current Page"
      end

      def test_renders_items_with_links
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products", href: "/products")
        end

        assert_selector "a[href='/']", text: "Home"
        assert_selector "a[href='/products']", text: "Products"
      end

      # Separator Tests
      def test_renders_with_chevron_separator
        render_inline(Component.new(separator: :chevron)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_text "›"
      end

      def test_renders_with_slash_separator
        render_inline(Component.new(separator: :slash)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_text "/"
      end

      def test_renders_with_arrow_separator
        render_inline(Component.new(separator: :arrow)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_text "→"
      end

      def test_renders_with_dot_separator
        render_inline(Component.new(separator: :dot)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_text "•"
      end

      def test_renders_with_custom_separator_icon
        render_inline(Component.new(separator: :custom, separator_icon: "chevron-right")) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_selector "svg"
        # Check for use element with icon reference
        assert_includes page.native.to_html, "#icon-chevron-right"
      end

      def test_validates_separator
        assert_raises(ArgumentError) do
          Component.new(separator: :invalid)
        end
      end

      def test_raises_error_for_invalid_separator
        error = assert_raises(ArgumentError) do
          Component.new(separator: :unknown)
        end

        assert_includes error.message, "Invalid separator"
        assert_includes error.message, "chevron, slash, arrow, dot, custom"
      end

      # Home Item Tests
      def test_renders_home_item_when_enabled
        render_inline(Component.new(show_home: true)) do |breadcrumb|
          breadcrumb.item(text: "Products", href: "/products")
        end

        assert_selector "a[href='/']", text: "Home"
        assert_selector "svg"
        assert_includes page.native.to_html, "#icon-home"
      end

      def test_does_not_render_home_when_disabled
        render_inline(Component.new(show_home: false)) do |breadcrumb|
          breadcrumb.item(text: "Products", href: "/products")
        end

        refute_selector "a[href='/']", text: "Home"
        assert_selector "a[href='/products']", text: "Products"
      end

      def test_renders_home_with_custom_url
        render_inline(Component.new(show_home: true, home_url: "/dashboard")) do |breadcrumb|
          breadcrumb.item(text: "Products")
        end

        assert_selector "a[href='/dashboard']", text: "Home"
      end

      def test_renders_home_with_custom_text
        render_inline(Component.new(show_home: true, home_text: "Dashboard")) do |breadcrumb|
          breadcrumb.item(text: "Products")
        end

        assert_selector "a[href='/']", text: "Dashboard"
      end

      def test_renders_home_with_icon
        render_inline(Component.new(show_home: true, home_icon: "house")) do |breadcrumb|
          breadcrumb.item(text: "Products")
        end

        assert_selector "svg"
        assert_includes page.native.to_html, "#icon-house"
        assert_text "Home"
      end

      def test_renders_back_item_when_enabled
        render_inline(Component.new(show_back: true, back_fallback_url: "/previous")) do |breadcrumb|
          breadcrumb.item(text: "Current")
        end

        assert_selector "a[href='/previous']", text: "Back"
        assert_selector "nav ol li:first-child a[href='/previous']", text: "Back"
        assert_includes page.native.to_html, "#icon-chevron-left"
      end

      def test_renders_back_before_home_when_both_enabled
        render_inline(Component.new(show_back: true, show_home: true, back_fallback_url: "/previous")) do |breadcrumb|
          breadcrumb.item(text: "Settings")
        end

        html = page.native.to_html
        assert_operator html.index("Back"), :<, html.index("Home")
      end

      def test_hides_separator_to_the_right_of_back_item
        render_inline(Component.new(show_back: true, show_home: true, back_fallback_url: "/previous")) do |breadcrumb|
          breadcrumb.item(text: "Current")
        end

        assert_selector "a[href='/previous']", text: "Back"
        assert_selector "a[href='/']", text: "Home"
        assert_no_selector "nav[aria-label='Breadcrumb'] li:first-child + li[aria-hidden='true']"
        assert_selector "nav[aria-label='Breadcrumb'] li[aria-hidden='true']"
      end

      def test_renders_back_with_custom_text
        render_inline(Component.new(show_back: true, back_text: "Go Back", back_fallback_url: "/prev")) do |breadcrumb|
          breadcrumb.item(text: "Current")
        end

        assert_selector "a[href='/prev']", text: "Go Back"
      end

      # Collapsed Items Tests
      def test_collapses_items_when_exceeds_max
        render_inline(Component.new(max_items: 3)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Level 1", href: "/l1")
          breadcrumb.item(text: "Level 2", href: "/l2")
          breadcrumb.item(text: "Level 3", href: "/l3")
          breadcrumb.item(text: "Current")
        end

        assert_text "Home"
        assert_text "..."
        assert_text "Level 3"
        assert_text "Current"
        refute_text "Level 1"
        refute_text "Level 2"
      end

      def test_keeps_first_and_last_items_when_collapsed
        render_inline(Component.new(max_items: 2)) do |breadcrumb|
          breadcrumb.item(text: "First", href: "/first")
          breadcrumb.item(text: "Second", href: "/second")
          breadcrumb.item(text: "Third", href: "/third")
          breadcrumb.item(text: "Last")
        end

        assert_text "First"
        assert_text "..."
        assert_text "Last"
        refute_text "Second"
        refute_text "Third"
      end

      def test_adds_ellipsis_when_collapsed
        render_inline(Component.new(max_items: 3)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "A", href: "/a")
          breadcrumb.item(text: "B", href: "/b")
          breadcrumb.item(text: "C", href: "/c")
          breadcrumb.item(text: "D")
        end

        assert_selector "span[aria-current='page']", text: "..."
      end

      def test_does_not_collapse_when_under_max
        render_inline(Component.new(max_items: 5)) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products", href: "/products")
          breadcrumb.item(text: "Laptops")
        end

        assert_text "Home"
        assert_text "Products"
        assert_text "Laptops"
        refute_text "..."
      end

      # Array Items Tests
      def test_accepts_array_of_items
        items = [
          {text: "Home", href: "/"},
          {text: "Products", href: "/products"},
          {text: "Laptops"}
        ]

        render_inline(Component.new(items: items))

        assert_text "Home"
        assert_text "Products"
        assert_text "Laptops"
        assert_selector "a[href='/']"
        assert_selector "a[href='/products']"
      end

      def test_builds_items_from_array
        items = [
          {text: "Item 1", href: "/1"},
          {text: "Item 2", href: "/2"}
        ]

        render_inline(Component.new(items: items))

        assert_selector "li", count: 3 # 2 items + 1 separator
      end

      # Accessibility Tests
      def test_has_nav_with_aria_label
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home")
        end

        assert_selector "nav[aria-label='Breadcrumb']"
      end

      def test_current_item_has_aria_current
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Current")
        end

        assert_selector "span[aria-current='page']", text: "Current"
      end

      def test_separator_has_aria_hidden
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_selector "li[aria-hidden='true']"
      end

      # Item Component Tests
      def test_item_renders_link_when_href_provided
        render_inline(Item::Component.new(text: "Home", href: "/"))

        assert_selector "a[href='/']", text: "Home"
        refute_selector "span[aria-current='page']"
      end

      def test_item_renders_span_when_no_href
        render_inline(Item::Component.new(text: "Current"))

        assert_selector "span[aria-current='page']", text: "Current"
        refute_selector "a"
      end

      def test_item_with_icon
        render_inline(Item::Component.new(text: "Home", href: "/", icon: "home"))

        assert_selector "svg"
        assert_includes page.native.to_html, "#icon-home"
        assert_text "Home"
      end

      def test_item_validates_text_required
        assert_raises(ArgumentError, match: /text is required/) do
          Item::Component.new(text: nil)
        end
      end

      def test_item_validates_empty_text
        assert_raises(ArgumentError, match: /text is required/) do
          Item::Component.new(text: "   ")
        end
      end

      def test_item_has_hover_styles
        render_inline(Item::Component.new(text: "Home", href: "/"))

        assert_includes page.native.to_html, "hover:text-[var(--surface-content-color)]"
        assert_includes page.native.to_html, "transition-colors"
      end

      # Security Tests
      def test_sanitizes_dangerous_attributes
        render_inline(Component.new(onclick: "alert('xss')")) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
        end

        refute_selector "nav[onclick]"
      end

      def test_escapes_text_content
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "<script>alert('xss')</script>", href: "/")
        end

        refute_selector "script"
        assert_text "<script>alert('xss')</script>"
      end

      def test_validates_hrefs
        # This test ensures hrefs are rendered as-is for relative/safe URLs
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/home")
          breadcrumb.item(text: "Products", href: "/products")
        end

        assert_selector "a[href='/home']"
        assert_selector "a[href='/products']"
      end

      # Styling Tests
      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-breadcrumb")) do |breadcrumb|
          breadcrumb.item(text: "Home")
        end

        assert_selector "nav.custom-breadcrumb"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "breadcrumb"})) do |breadcrumb|
          breadcrumb.item(text: "Home")
        end

        assert_selector "nav[data-testid='breadcrumb']"
      end

      def test_current_item_has_distinct_style
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Current")
        end

        assert_includes page.native.to_html, "font-medium"
        assert_includes page.native.to_html, "text-[var(--surface-content-color)]"
      end

      def test_default_separator_is_chevron
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_text "›"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(id: "main-breadcrumb")) do |breadcrumb|
          breadcrumb.item(text: "Home")
        end

        assert_selector "nav#main-breadcrumb"
      end

      def test_renders_semantic_html
        render_inline(Component.new) do |breadcrumb|
          breadcrumb.item(text: "Home", href: "/")
          breadcrumb.item(text: "Products")
        end

        assert_selector "nav > ol > li"
      end
    end
  end
end
