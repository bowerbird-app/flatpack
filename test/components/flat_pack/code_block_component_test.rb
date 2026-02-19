# frozen_string_literal: true

require "test_helper"

module FlatPack
  module CodeBlock
    class ComponentTest < ViewComponent::TestCase
      def test_renders_code_block
        render_inline(Component.new(code: "puts 'Hello, world!'"))

        assert_selector "pre"
        assert_selector "code", text: "puts 'Hello, world!'"
      end

      def test_renders_title_when_present
        render_inline(Component.new(code: "puts 'Hello'", title: "Ruby"))

        assert_selector "div", text: "Ruby"
        assert_includes page.native.to_html, "border-b"
      end

      def test_applies_language_class_when_provided
        render_inline(Component.new(code: "const x = 1", language: "javascript"))

        assert_selector "code.language-javascript", text: "const x = 1"
      end

      def test_escapes_html_in_code_content
        render_inline(Component.new(code: "<script>alert('xss')</script>"))

        refute_includes page.native.to_html, "<script>"
        assert_includes page.native.to_html, "&lt;script&gt;alert('xss')&lt;/script&gt;"
      end

      def test_merges_custom_classes
        render_inline(Component.new(code: "puts 1", class: "my-code-block"))

        assert_selector "div.my-code-block"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(code: "puts 1", data: {testid: "code-block"}))

        assert_selector "div[data-testid='code-block']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(code: "puts 1", aria: {label: "Example code"}))

        assert_selector "div[aria-label='Example code']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(code: "puts 1", id: "example-code"))

        assert_selector "div#example-code"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(code: "puts 1", onclick: "alert('xss')"))

        refute_selector "div[onclick]"
      end
    end
  end
end
