# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Content
    class ComponentTest < ViewComponent::TestCase
      def test_renders_wrapper_around_block
        render_inline(Component.new) { "<p>Body copy</p>".html_safe }

        assert_selector "div.fp-content"
        assert_selector "div.fp-content p", text: "Body copy"
      end

      def test_accepts_custom_classes
        render_inline(Component.new(class: "max-w-4xl")) { "<p>Body copy</p>".html_safe }

        assert_selector "div.fp-content.max-w-4xl"
      end

      def test_raises_when_block_missing
        error = assert_raises(ArgumentError) do
          render_inline(Component.new)
        end

        assert_includes error.message, "content is required"
      end
    end
  end
end
