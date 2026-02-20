# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ChipGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_wrapper_div
        render_inline(Component.new) do
          "Content"
        end

        assert_selector "div", text: "Content"
      end

      def test_applies_wrap_classes_by_default
        render_inline(Component.new) do
          "Content"
        end

        assert_includes page.native.to_html, "flex-wrap"
      end

      def test_applies_no_wrap_classes
        render_inline(Component.new(wrap: false)) do
          "Content"
        end

        refute_includes page.native.to_html, "flex-wrap"
      end

      def test_has_flex_and_gap_classes
        render_inline(Component.new) do
          "Content"
        end

        assert_includes page.native.to_html, "flex"
        assert_includes page.native.to_html, "items-center"
        assert_includes page.native.to_html, "gap-2"
      end

      def test_renders_content
        render_inline(Component.new) do
          "Test Content"
        end

        assert_selector "div", text: "Test Content"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class")) do
          "Content"
        end

        assert_selector "div.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "chip-group"})) do
          "Content"
        end

        assert_selector "div[data-testid='chip-group']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(aria: {label: "Chip group"})) do
          "Content"
        end

        assert_selector "div[aria-label='Chip group']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(id: "my-chip-group")) do
          "Content"
        end

        assert_selector "div#my-chip-group"
      end
    end
  end
end
