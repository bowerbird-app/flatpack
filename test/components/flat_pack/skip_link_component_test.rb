# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SkipLink
    class ComponentTest < ViewComponent::TestCase
      def test_renders_fragment_link
        render_inline(Component.new)

        assert_selector "a.fp-skip-link[href='#main']", text: "Skip to content"
      end

      def test_rejects_non_fragment_href
        error = assert_raises(ArgumentError) { Component.new(href: "/demo") }

        assert_match(/in-page fragment/, error.message)
      end

      def test_blank_text_raises
        error = assert_raises(ArgumentError) { Component.new(text: " ") }

        assert_equal "text is required", error.message
      end
    end
  end
end
