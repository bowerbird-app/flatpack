# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_with_primary_scheme
        render_inline(Component.new(text: "Click me", style: :primary))

        assert_selector "button", text: "Click me"
        assert_selector "button[type='button']"
      end

      def test_renders_button_with_secondary_scheme
        render_inline(Component.new(text: "Secondary", style: :secondary))

        assert_selector "button", text: "Secondary"
      end

      def test_renders_button_with_ghost_scheme
        render_inline(Component.new(text: "Ghost", style: :ghost))

        assert_selector "button", text: "Ghost"
      end

      def test_renders_link_when_url_provided
        render_inline(Component.new(text: "Link", url: "/path"))

        assert_selector "a[href='/path']", text: "Link"
      end

      def test_renders_link_with_method
        render_inline(Component.new(text: "Delete", url: "/path", method: :delete))

        assert_selector "a[href='/path']", text: "Delete"
      end

      def test_raises_error_for_invalid_scheme
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", style: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(text: "Custom", class: "custom-class"))

        assert_selector "button.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(text: "Data", data: {action: "click"}))

        assert_selector "button[data-action='click']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(text: "Aria", aria: {label: "Custom label"}))

        assert_selector "button[aria-label='Custom label']"
      end

      def test_default_scheme_is_primary
        component = Component.new(text: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
      end

      def test_default_size_is_md
        component = Component.new(text: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
        # The rendered HTML should contain the md size classes
        assert_includes page.native.to_html, "px-4"
        assert_includes page.native.to_html, "py-2"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_small_size
        render_inline(Component.new(text: "Small", size: :sm))

        assert_selector "button", text: "Small"
        assert_includes page.native.to_html, "px-3"
        assert_includes page.native.to_html, "py-1.5"
        assert_includes page.native.to_html, "text-xs"
      end

      def test_renders_button_with_medium_size
        render_inline(Component.new(text: "Medium", size: :md))

        assert_selector "button", text: "Medium"
        assert_includes page.native.to_html, "px-4"
        assert_includes page.native.to_html, "py-2"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_large_size
        render_inline(Component.new(text: "Large", size: :lg))

        assert_selector "button", text: "Large"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      def test_renders_link_with_size
        render_inline(Component.new(text: "Link", url: "/path", size: :lg))

        assert_selector "a[href='/path']", text: "Link"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", size: :xl)
        end
      end

      def test_renders_link_with_target_blank
        render_inline(Component.new(text: "External", url: "https://example.com", target: "_blank"))

        assert_selector "a[href='https://example.com'][target='_blank']", text: "External"
        assert_selector "a[rel='noopener noreferrer']"
      end

      def test_renders_link_with_target_self
        render_inline(Component.new(text: "Same Tab", url: "/path", target: "_self"))

        assert_selector "a[href='/path'][target='_self']", text: "Same Tab"
      end

      def test_link_without_target_has_no_target_attribute
        render_inline(Component.new(text: "Link", url: "/path"))

        assert_selector "a[href='/path']", text: "Link"
        refute_selector "a[target]"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(text: "With ID", id: "my-button"))

        assert_selector "button#my-button", text: "With ID"
      end

      def test_accepts_id_attribute_on_link
        render_inline(Component.new(text: "Link ID", url: "/path", id: "my-link"))

        assert_selector "a#my-link[href='/path']", text: "Link ID"
      end

      def test_renders_success_scheme
        render_inline(Component.new(text: "Success", style: :success))

        assert_selector "button", text: "Success"
      end

      def test_renders_warning_scheme
        render_inline(Component.new(text: "Warning", style: :warning))

        assert_selector "button", text: "Warning"
      end

      def test_renders_icon_only_button
        render_inline(Component.new(icon: "search", icon_only: true))

        assert_selector "button"
        refute_selector "button span"
      end

      def test_renders_button_with_icon_and_label
        render_inline(Component.new(text: "Search", icon: "search"))

        assert_selector "button", text: "Search"
      end

      def test_renders_loading_button
        render_inline(Component.new(text: "Save", loading: true))

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
          Component.new(text: "Click", url: "javascript:alert('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_data_url
        error = assert_raises(ArgumentError) do
          Component.new(text: "Click", url: "data:text/html,<script>alert('xss')</script>")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_vbscript_url
        error = assert_raises(ArgumentError) do
          Component.new(text: "Click", url: "vbscript:msgbox('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_allows_safe_urls
        render_inline(Component.new(text: "Click", url: "https://example.com"))
        assert_selector "a[href='https://example.com']", text: "Click"
      end

      def test_allows_relative_urls
        render_inline(Component.new(text: "Click", url: "/path/to/page"))
        assert_selector "a[href='/path/to/page']", text: "Click"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(text: "Click", onclick: "alert('xss')"))
        refute_selector "button[onclick]"
      end

      def test_default_type_is_button
        render_inline(Component.new(text: "Click me"))

        assert_selector "button[type='button']", text: "Click me"
      end

      def test_renders_submit_type_button
        render_inline(Component.new(text: "Submit", type: "submit"))

        assert_selector "button[type='submit']", text: "Submit"
      end

      def test_renders_reset_type_button
        render_inline(Component.new(text: "Reset", type: "reset"))

        assert_selector "button[type='reset']", text: "Reset"
      end

      def test_link_does_not_have_type_attribute
        render_inline(Component.new(text: "Link", url: "/path", type: "submit"))

        assert_selector "a[href='/path']", text: "Link"
        refute_selector "a[type]"
      end

      def test_renders_button_with_cursor_pointer_class
        render_inline(Component.new(text: "Click me"))

        assert_selector "button.cursor-pointer"
      end

      def test_renders_link_with_cursor_pointer_class
        render_inline(Component.new(text: "Link", url: "/path"))

        assert_selector "a.cursor-pointer"
      end

      def test_submit_button_with_different_styles
        render_inline(Component.new(text: "Submit Primary", type: "submit", style: :primary))
        assert_selector "button[type='submit']", text: "Submit Primary"

        render_inline(Component.new(text: "Submit Success", type: "submit", style: :success))
        assert_selector "button[type='submit']", text: "Submit Success"

        render_inline(Component.new(text: "Submit Warning", type: "submit", style: :warning))
        assert_selector "button[type='submit']", text: "Submit Warning"
      end

      def test_submit_button_with_different_sizes
        render_inline(Component.new(text: "Submit Small", type: "submit", size: :sm))
        assert_selector "button[type='submit']", text: "Submit Small"
        assert_includes page.native.to_html, "px-3"
        assert_includes page.native.to_html, "py-1.5"
        assert_includes page.native.to_html, "text-xs"

        render_inline(Component.new(text: "Submit Large", type: "submit", size: :lg))
        assert_selector "button[type='submit']", text: "Submit Large"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      def test_submit_button_with_icon
        render_inline(Component.new(text: "Submit", type: "submit", icon: "check"))
        assert_selector "button[type='submit']", text: "Submit"
      end

      def test_submit_button_with_loading_state
        render_inline(Component.new(text: "Submitting", type: "submit", loading: true))
        assert_selector "button[type='submit'][disabled]"
        assert_selector "button svg.animate-spin"
        assert_selector "button", text: "Loading"
      end

      def test_submit_button_with_name_and_value
        render_inline(Component.new(text: "Publish", type: "submit", name: "action", value: "publish"))
        assert_selector "button[type='submit'][name='action'][value='publish']", text: "Publish"
      end

      def test_submit_button_with_custom_classes
        render_inline(Component.new(text: "Submit", type: "submit", class: "w-full"))
        assert_selector "button[type='submit'].w-full", text: "Submit"
      end

      def test_submit_button_disabled
        render_inline(Component.new(text: "Submit", type: "submit", disabled: true))
        assert_selector "button[type='submit'][disabled]", text: "Submit"
      end

      def test_submit_button_with_data_attributes
        render_inline(Component.new(text: "Submit", type: "submit", data: { confirm: "Are you sure?" }))
        assert_selector "button[type='submit'][data-confirm='Are you sure?']", text: "Submit"
      end

      def test_submit_button_with_aria_label
        render_inline(Component.new(text: "Submit", type: "submit", aria: { label: "Submit form" }))
        assert_selector "button[type='submit'][aria-label='Submit form']", text: "Submit"
      end
    end
  end
end
