# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Quote
    class ComponentTest < ViewComponent::TestCase
      def test_renders_quote_from_text
        render_inline(Component.new(text: "Design is intelligence made visible."))

        assert_selector "figure.fp-quote"
        assert_selector "blockquote", text: "Design is intelligence made visible."
      end

      def test_renders_quote_from_block
        render_inline(Component.new) do
          "Simplicity is the ultimate sophistication."
        end

        assert_selector "blockquote", text: "Simplicity is the ultimate sophistication."
      end

      def test_renders_citation_when_present
        render_inline(Component.new(text: "Good design is honest.", cite: "Dieter Rams"))

        assert_selector "figcaption", text: "— Dieter Rams"
      end

      def test_does_not_render_citation_when_absent
        render_inline(Component.new(text: "Good design is honest."))

        assert_no_selector "figcaption"
      end

      def test_renders_small_size
        render_inline(Component.new(text: "Quote", size: :sm))

        assert_includes page.native.to_html, "text-base"
      end

      def test_renders_medium_size
        render_inline(Component.new(text: "Quote", size: :md))

        assert_includes page.native.to_html, "text-lg"
      end

      def test_renders_large_size
        render_inline(Component.new(text: "Quote", size: :lg))

        assert_includes page.native.to_html, "text-xl"
      end

      def test_raises_error_when_text_and_content_missing
        assert_raises(ArgumentError) do
          render_inline(Component.new)
        end
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(text: "Quote", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_accepts_custom_classes
        render_inline(Component.new(text: "Quote", class: "custom-quote"))

        assert_selector "figure.custom-quote"
      end
    end
  end
end
