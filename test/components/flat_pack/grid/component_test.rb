# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Grid
    class ComponentTest < ViewComponent::TestCase
      def test_renders_grid_with_default_settings
        render_inline(Component.new) do
          "Grid content"
        end

        assert_selector "div.grid"
        assert_text "Grid content"
      end

      def test_renders_auto_responsive_grid_by_default
        render_inline(Component.new) do
          "Content"
        end

        assert_selector "div.grid-cols-1"
        assert_selector "div.sm\\:grid-cols-2"
        assert_selector "div.lg\\:grid-cols-3"
        assert_selector "div.xl\\:grid-cols-4"
      end

      def test_renders_grid_with_specific_columns
        render_inline(Component.new(cols: 3)) do
          "Content"
        end

        assert_selector "div.grid-cols-1"
        assert_selector "div.md\\:grid-cols-2"
        assert_selector "div.lg\\:grid-cols-3"
      end

      def test_renders_grid_with_medium_gap
        render_inline(Component.new(gap: :md)) do
          "Content"
        end

        assert_selector "div.gap-4"
      end

      def test_renders_grid_with_small_gap
        render_inline(Component.new(gap: :sm)) do
          "Content"
        end

        assert_selector "div.gap-2"
      end

      def test_renders_grid_with_large_gap
        render_inline(Component.new(gap: :lg)) do
          "Content"
        end

        assert_selector "div.gap-6"
      end

      def test_renders_grid_with_stretch_alignment
        render_inline(Component.new(align: :stretch)) do
          "Content"
        end

        assert_selector "div.items-stretch"
      end

      def test_renders_grid_with_start_alignment
        render_inline(Component.new(align: :start)) do
          "Content"
        end

        assert_selector "div.items-start"
      end

      def test_renders_grid_with_center_alignment
        render_inline(Component.new(align: :center)) do
          "Content"
        end

        assert_selector "div.items-center"
      end

      def test_raises_error_for_invalid_cols
        assert_raises(ArgumentError) do
          Component.new(cols: :invalid)
        end
      end

      def test_raises_error_for_invalid_gap
        assert_raises(ArgumentError) do
          Component.new(gap: :invalid)
        end
      end

      def test_raises_error_for_invalid_align
        assert_raises(ArgumentError) do
          Component.new(align: :invalid)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(class: "custom-class")) do
          "Content"
        end

        assert_selector "div.grid.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {controller: "custom"})) do
          "Content"
        end

        assert_selector "div[data-controller='custom']"
      end
    end
  end
end
