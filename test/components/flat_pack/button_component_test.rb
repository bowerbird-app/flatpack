# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_with_primary_scheme
        render_inline(Component.new(label: "Click me", scheme: :primary))

        assert_selector "button", text: "Click me"
        assert_selector "button[type='button']"
      end

      def test_renders_button_with_secondary_scheme
        render_inline(Component.new(label: "Secondary", scheme: :secondary))

        assert_selector "button", text: "Secondary"
      end

      def test_renders_button_with_ghost_scheme
        render_inline(Component.new(label: "Ghost", scheme: :ghost))

        assert_selector "button", text: "Ghost"
      end

      def test_renders_link_when_url_provided
        render_inline(Component.new(label: "Link", url: "/path"))

        assert_selector "a[href='/path']", text: "Link"
      end

      def test_renders_link_with_method
        render_inline(Component.new(label: "Delete", url: "/path", method: :delete))

        assert_selector "a[href='/path']", text: "Delete"
      end

      def test_raises_error_for_invalid_scheme
        assert_raises(ArgumentError) do
          Component.new(label: "Invalid", scheme: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(label: "Custom", class: "custom-class"))

        assert_selector "button.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(label: "Data", data: {action: "click"}))

        assert_selector "button[data-action='click']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(label: "Aria", aria: {label: "Custom label"}))

        assert_selector "button[aria-label='Custom label']"
      end

      def test_default_scheme_is_primary
        component = Component.new(label: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
      end

      def test_default_size_is_md
        component = Component.new(label: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
        # The rendered HTML should contain the md size classes
        assert_includes page.native.to_html, "px-4"
        assert_includes page.native.to_html, "py-2"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_small_size
        render_inline(Component.new(label: "Small", size: :sm))

        assert_selector "button", text: "Small"
        assert_includes page.native.to_html, "px-3"
        assert_includes page.native.to_html, "py-1.5"
        assert_includes page.native.to_html, "text-xs"
      end

      def test_renders_button_with_medium_size
        render_inline(Component.new(label: "Medium", size: :md))

        assert_selector "button", text: "Medium"
        assert_includes page.native.to_html, "px-4"
        assert_includes page.native.to_html, "py-2"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_large_size
        render_inline(Component.new(label: "Large", size: :lg))

        assert_selector "button", text: "Large"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      def test_renders_link_with_size
        render_inline(Component.new(label: "Link", url: "/path", size: :lg))

        assert_selector "a[href='/path']", text: "Link"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(label: "Invalid", size: :xl)
        end
      end

      def test_renders_link_with_target_blank
        render_inline(Component.new(label: "External", url: "https://example.com", target: "_blank"))

        assert_selector "a[href='https://example.com'][target='_blank']", text: "External"
        assert_selector "a[rel='noopener noreferrer']"
      end

      def test_renders_link_with_target_self
        render_inline(Component.new(label: "Same Tab", url: "/path", target: "_self"))

        assert_selector "a[href='/path'][target='_self']", text: "Same Tab"
      end

      def test_link_without_target_has_no_target_attribute
        render_inline(Component.new(label: "Link", url: "/path"))

        assert_selector "a[href='/path']", text: "Link"
        refute_selector "a[target]"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(label: "With ID", id: "my-button"))

        assert_selector "button#my-button", text: "With ID"
      end

      def test_accepts_id_attribute_on_link
        render_inline(Component.new(label: "Link ID", url: "/path", id: "my-link"))

        assert_selector "a#my-link[href='/path']", text: "Link ID"
      end

      def test_renders_success_scheme
        render_inline(Component.new(label: "Success", scheme: :success))

        assert_selector "button", text: "Success"
      end

      def test_renders_warning_scheme
        render_inline(Component.new(label: "Warning", scheme: :warning))

        assert_selector "button", text: "Warning"
      end

      def test_renders_icon_only_button
        render_inline(Component.new(icon: "search", icon_only: true))

        assert_selector "button"
        refute_selector "button span"
      end

      def test_renders_button_with_icon_and_label
        render_inline(Component.new(label: "Search", icon: "search"))

        assert_selector "button", text: "Search"
      end

      def test_renders_loading_button
        render_inline(Component.new(label: "Save", loading: true))

        assert_selector "button[disabled]"
        assert_selector "button svg.animate-spin"
        assert_selector "button", text: "Loading"
      end

      def test_renders_loading_icon_only_button
        render_inline(Component.new(icon: "search", icon_only: true, loading: true))

        assert_selector "button[disabled]"
        assert_selector "button svg.animate-spin"
        refute_selector "button", text: "Loading"
      end

      def test_raises_error_for_button_without_content
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_sanitizes_javascript_url
        error = assert_raises(ArgumentError) do
          Component.new(label: "Click", url: "javascript:alert('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_data_url
        error = assert_raises(ArgumentError) do
          Component.new(label: "Click", url: "data:text/html,<script>alert('xss')</script>")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_vbscript_url
        error = assert_raises(ArgumentError) do
          Component.new(label: "Click", url: "vbscript:msgbox('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_allows_safe_urls
        render_inline(Component.new(label: "Click", url: "https://example.com"))
        assert_selector "a[href='https://example.com']", text: "Click"
      end

      def test_allows_relative_urls
        render_inline(Component.new(label: "Click", url: "/path/to/page"))
        assert_selector "a[href='/path/to/page']", text: "Click"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(label: "Click", onclick: "alert('xss')"))
        refute_selector "button[onclick]"
      end
    end
  end
end
