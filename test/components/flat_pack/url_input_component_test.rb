# frozen_string_literal: true

require "test_helper"

module FlatPack
  module UrlInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_url_input_with_name
        render_inline(Component.new(name: "website"))

        assert_selector "input[type='url'][name='website']"
      end

      def test_renders_with_safe_value
        render_inline(Component.new(name: "website", value: "https://example.com"))

        assert_selector "input[value='https://example.com']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "website", placeholder: "https://example.com"))

        assert_selector "input[placeholder='https://example.com']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "website", label: "Website URL"))

        assert_selector "label", text: "Website URL"
        assert_selector "input[type='url']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "website", label: "Website", id: "user-website"))

        assert_selector "label[for='user-website']"
        assert_selector "input#user-website"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "website", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "website", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "website", error: "URL is invalid"))

        assert_selector "p", text: "URL is invalid"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "website", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-destructive)]"
      end

      def test_sanitizes_javascript_url
        render_inline(Component.new(name: "website", value: "javascript:alert('xss')"))

        # Value should be nil/empty after sanitization
        refute_selector "input[value='javascript:alert(\\'xss\\')']"
      end

      def test_sanitizes_data_url
        render_inline(Component.new(name: "website", value: "data:text/html,<script>alert('xss')</script>"))

        # Value should be nil/empty after sanitization
        html = page.native.to_html
        refute_includes html, "data:text/html"
      end

      def test_sanitizes_vbscript_url
        render_inline(Component.new(name: "website", value: "vbscript:msgbox('xss')"))

        # Value should be nil/empty after sanitization
        refute_selector "input[value*='vbscript']"
      end

      def test_allows_https_urls
        render_inline(Component.new(name: "website", value: "https://example.com"))

        assert_selector "input[value='https://example.com']"
      end

      def test_allows_http_urls
        render_inline(Component.new(name: "website", value: "http://example.com"))

        assert_selector "input[value='http://example.com']"
      end

      def test_allows_relative_urls
        render_inline(Component.new(name: "website", value: "/path/to/page"))

        assert_selector "input[value='/path/to/page']"
      end

      def test_allows_mailto_urls
        render_inline(Component.new(name: "website", value: "mailto:user@example.com"))

        assert_selector "input[value='mailto:user@example.com']"
      end

      def test_allows_tel_urls
        render_inline(Component.new(name: "website", value: "tel:+1234567890"))

        assert_selector "input[value='tel:+1234567890']"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "website", class: "custom-url-class"))

        assert_selector "input.custom-url-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "website", data: { validate: "url" }))

        assert_selector "input[data-validate='url']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "website", aria: { label: "Company website" }))

        assert_selector "input[aria-label='Company website']"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "website"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "website"))

        assert_selector "div.flat-pack-input-wrapper"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new(name: nil)
        end
      end

      def test_raises_error_with_empty_name
        assert_raises(ArgumentError) do
          Component.new(name: "")
        end
      end

      def test_sanitizes_dangerous_onclick_attribute
        render_inline(Component.new(name: "website", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "website",
          value: "https://example.com",
          placeholder: "https://",
          disabled: false,
          required: true,
          label: "Website",
          class: "custom"
        ))

        assert_selector "label", text: "Website"
        assert_selector "input[type='url'][name='website']"
        assert_selector "input[value='https://example.com']"
        assert_selector "input[placeholder='https://']"
        assert_selector "input[required]"
        assert_selector "input.custom"
      end
    end
  end
end
