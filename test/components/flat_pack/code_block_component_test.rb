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

      def test_applies_default_top_spacing
        render_inline(Component.new(code: "puts 1"))

        assert_selector "div.mt-4"
      end

      def test_can_disable_top_spacing
        render_inline(Component.new(code: "puts 1", separated: false))

        refute_selector "div.mt-4"
      end

      def test_renders_single_snippet_without_tablist
        render_inline(Component.new(
          snippets: [{label: "Ruby", language: "ruby", code: "puts 'Hello, world!'"}]
        ))

        assert_selector "pre"
        assert_selector "code.language-ruby", text: "puts 'Hello, world!'"
        refute_selector "[role='tablist']"
      end

      def test_renders_tabbed_code_block_for_multiple_snippets
        render_inline(Component.new(
          snippets: [
            {label: "Primary", language: "erb", code: "<%= render FlatPack::Button::Component.new(text: \"Primary\") %>"},
            {label: "Secondary", language: "erb", code: "<%= render FlatPack::Button::Component.new(text: \"Secondary\") %>"}
          ]
        ))

        assert_selector "[role='tablist'][aria-label='Code snippets']"
        assert_selector "button[role='tab']", count: 2
        assert_selector "button[role='tab'][aria-selected='true']", text: "Primary"
        assert_selector "button[role='tab'][aria-selected='false']", text: "Secondary"
        assert_selector "[role='tabpanel']", count: 2, visible: :all
        assert_selector "[role='tabpanel'][hidden]", count: 1, visible: :all
      end

      def test_falls_back_to_snippet_when_labels_missing
        render_inline(Component.new(
          snippets: [
            {language: "ruby", code: "puts 1"},
            {code: "puts 2"}
          ]
        ))

        assert_selector "button[role='tab']", text: "RUBY"
        assert_selector "button[role='tab']", text: "Snippet"
      end

      def test_uses_snippets_when_both_code_and_snippets_are_provided
        render_inline(Component.new(
          code: "puts 'fallback'",
          snippets: [{label: "From snippets", code: "puts 'snippets'"}]
        ))

        assert_selector "code", text: "puts 'snippets'"
        refute_selector "code", text: "puts 'fallback'"
      end

      def test_raises_when_code_and_snippets_missing
        assert_raises(ArgumentError) do
          render_inline(Component.new)
        end
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

      def test_applies_wrapping_classes_to_pre
        render_inline(Component.new(code: "a_very_long_line_without_spaces"))

        assert_selector "pre.whitespace-pre-wrap.break-words"
      end

      def test_preserves_newlines_in_code_content
        render_inline(Component.new(code: "line 1\nline 2"))

        assert_includes page.native.to_html, "line 1\nline 2"
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
