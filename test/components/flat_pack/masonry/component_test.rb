# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Masonry
    class ComponentTest < ViewComponent::TestCase
      def test_renders_columns_order_by_default
        render_inline(Component.new) { "Brick" }

        assert_selector "div.fp-masonry.fp-masonry--columns"
        refute_selector "[data-controller='flat-pack--masonry']"
        assert_text "Brick"
      end

      def test_default_columns_and_gap
        render_inline(Component.new) { "Brick" }

        html = page.native.to_html
        assert_includes html, "columns-2"
        assert_includes html, "md:columns-3"
        assert_includes html, "lg:columns-4"
        assert_includes html, "gap-4"
        assert_includes html, "--fp-masonry-gap: 1rem"
      end

      def test_integer_columns_apply_at_every_breakpoint
        render_inline(Component.new(columns: 3)) { "Brick" }

        html = page.native.to_html
        assert_includes html, "columns-3"
        refute_includes html, "md:columns-3"
        refute_includes html, "lg:columns-4"
      end

      def test_hash_columns_map_breakpoints
        render_inline(Component.new(columns: {base: 2, sm: 3, xl: 5})) { "Brick" }

        html = page.native.to_html
        assert_includes html, "columns-2"
        assert_includes html, "sm:columns-3"
        assert_includes html, "xl:columns-5"
        refute_includes html, "md:columns-3"
      end

      def test_small_and_large_gaps
        render_inline(Component.new(gap: :sm)) { "Brick" }
        assert_includes page.native.to_html, "gap-2"
        assert_includes page.native.to_html, "--fp-masonry-gap: 0.5rem"

        render_inline(Component.new(gap: :lg)) { "Brick" }
        assert_includes page.native.to_html, "gap-6"
        assert_includes page.native.to_html, "--fp-masonry-gap: 1.5rem"
      end

      def test_rows_order_adds_controller_and_grid_classes
        render_inline(Component.new(order: :rows, columns: {base: 2, md: 3, lg: 4})) { "Brick" }

        assert_selector "div.fp-masonry.fp-masonry--rows[data-controller='flat-pack--masonry']"
        html = page.native.to_html
        assert_includes html, "columns-2"
        assert_includes html, "md:columns-3"
        assert_includes html, "lg:columns-4"
        assert_includes html, "grid-cols-2"
        assert_includes html, "md:grid-cols-3"
        assert_includes html, "lg:grid-cols-4"
      end

      def test_item_slot_wraps_arbitrary_content
        render_inline(Component.new) do |masonry|
          masonry.with_item { "Harbour wall" }
        end

        assert_selector ".fp-masonry__item[data-flat-pack--masonry-target='item']", text: "Harbour wall"
      end

      def test_item_holds_media_and_a_filename
        view = vc_test_controller.view_context

        render_inline(Component.new) do |masonry|
          masonry.with_item do
            view.safe_join([
              view.render(FlatPack::Media::Component.new(src: "https://example.com/harbour.jpg", alt: "Harbour at dusk", width: 1120, height: 1400)) do |media|
                media.with_item(placement: :bottom_left, inset: :sm) { "JPG · 1120×1400 · 4:5" }
              end,
              view.tag.span("harbour.jpg")
            ])
          end
        end

        assert_selector ".fp-masonry__item img[alt='Harbour at dusk'][loading='lazy']"
        assert_selector ".fp-masonry__item [data-fp-placement='bottom_left']", text: "JPG · 1120×1400 · 4:5"
        assert_selector ".fp-masonry__item span", text: "harbour.jpg"
        refute_selector ".fp-masonry__image"
        refute_selector "figure.fp-masonry__figure"
      end

      def test_has_no_image_helper
        refute FlatPack::Masonry.const_defined?(:Image, false)
        refute_includes Component.instance_methods, :with_image
      end

      def test_accepts_custom_classes_and_data
        render_inline(Component.new(class: "custom-masonry", data: {testid: "photos"})) { "Brick" }

        assert_selector "div.fp-masonry.custom-masonry[data-testid='photos']"
      end

      def test_rejects_invalid_order
        error = assert_raises(ArgumentError) { Component.new(order: :diagonal) }
        assert_match(/Invalid order/, error.message)
      end

      def test_rejects_invalid_gap
        error = assert_raises(ArgumentError) { Component.new(gap: :xl) }
        assert_match(/Invalid gap/, error.message)
      end

      def test_rejects_invalid_column_count
        error = assert_raises(ArgumentError) { Component.new(columns: 9) }
        assert_match(/Invalid columns/, error.message)
      end

      def test_rejects_invalid_column_breakpoint
        error = assert_raises(ArgumentError) { Component.new(columns: {tablet: 3}) }
        assert_match(/Invalid columns breakpoints/, error.message)
      end
    end
  end
end
