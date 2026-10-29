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

      def test_default_block_content_does_not_wrap_items
        render_inline(Component.new) do
          "<p>Direct child</p>".html_safe
        end

        assert_selector "div.grid > p", text: "Direct child"
        refute_selector "div.grid > div > p"
      end

      def test_item_slot_wraps_content_without_span_classes
        render_inline(Component.new) do |grid|
          grid.with_item(class: "host-cell") { "Plain cell" }
        end

        assert_selector "div.grid > div.fp-grid__item.host-cell", text: "Plain cell"
        html = page.native.to_html
        refute_includes html, "col-span-"
      end

      def test_four_column_preset_emits_a_base_template_below_md
        render_inline(Component.new(cols: 4)) do |grid|
          grid.with_item(span: :full) { "Full width" }
        end

        html = page.native.to_html
        assert_includes html, "grid-cols-2"
        assert_includes html, "lg:grid-cols-4"
        assert_includes html, "col-span-full"
        refute_includes html, "grid-cols-1"
        refute_includes html, "md:grid-cols-2"
      end

      def test_item_span_integer_applies_at_every_breakpoint
        render_inline(Component.new(cols: 4)) do |grid|
          grid.with_item(span: 2) { "Wide" }
        end

        html = page.native.to_html
        assert_includes html, "col-span-2"
        refute_includes html, "md:col-span-2"
        refute_includes html, "lg:col-span-2"
      end

      def test_item_span_hash_maps_breakpoints
        render_inline(Component.new(cols: 12)) do |grid|
          grid.with_item(span: {base: 1, md: 2, lg: 8}) { "Hero" }
        end

        html = page.native.to_html
        assert_includes html, "col-span-1"
        assert_includes html, "md:col-span-2"
        assert_includes html, "lg:col-span-8"
        refute_includes html, "sm:col-span-"
        refute_includes html, "xl:col-span-"
      end

      def test_item_span_full
        render_inline(Component.new) do |grid|
          grid.with_item(span: :full) { "Full width" }
        end

        assert_includes page.native.to_html, "col-span-full"
      end

      def test_item_span_full_in_hash
        render_inline(Component.new) do |grid|
          grid.with_item(span: {base: :full, lg: 6}) { "Stacked then half" }
        end

        html = page.native.to_html
        assert_includes html, "col-span-full"
        assert_includes html, "lg:col-span-6"
      end

      def test_grid_item_can_render_inside_default_content
        view = vc_test_controller.view_context

        render_inline(Component.new(cols: 4)) do
          view.render(Item.new(span: 3)) { "Nested" }
        end

        assert_includes page.native.to_html, "col-span-3"
        assert_text "Nested"
      end

      def test_rejects_invalid_span
        error = assert_raises(ArgumentError) { Item.new(span: 13) }
        assert_match(/Invalid span/, error.message)
      end

      def test_rejects_invalid_span_breakpoint
        error = assert_raises(ArgumentError) { Item.new(span: {tablet: 2}) }
        assert_match(/Invalid span breakpoints/, error.message)
      end
    end
  end
end
