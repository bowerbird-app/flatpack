# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Stack
    class ComponentTest < ViewComponent::TestCase
      def test_renders_a_vertical_flex_stack_with_defaults
        render_inline(Component.new) do
          "Stack content"
        end

        assert_selector "div.flex.flex-col.items-stretch"
        assert_includes page.find("div.flex")[:class], "gap-[var(--stack-gap-md)]"
        assert_text "Stack content"
      end

      def test_renders_a_small_gap
        render_inline(Component.new(gap: :sm)) { "Content" }

        assert_includes page.find("div.flex")[:class], "gap-[var(--stack-gap-sm)]"
      end

      def test_renders_a_large_gap
        render_inline(Component.new(gap: :lg)) { "Content" }

        assert_includes page.find("div.flex")[:class], "gap-[var(--stack-gap-lg)]"
      end

      def test_renders_start_alignment
        render_inline(Component.new(align: :start)) { "Content" }

        assert_selector "div.items-start"
      end

      def test_renders_center_alignment
        render_inline(Component.new(align: :center)) { "Content" }

        assert_selector "div.items-center"
      end

      def test_raises_error_for_invalid_gap
        error = assert_raises(ArgumentError) { Component.new(gap: :invalid) }
        assert_match(/Invalid gap/, error.message)
      end

      def test_raises_error_for_invalid_align
        error = assert_raises(ArgumentError) { Component.new(align: :invalid) }
        assert_match(/Invalid align/, error.message)
      end

      def test_accepts_custom_classes
        render_inline(Component.new(class: "custom-class")) { "Content" }

        assert_selector "div.flex.flex-col.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {controller: "custom"})) { "Content" }

        assert_selector "div[data-controller='custom']"
      end
    end
  end
end
