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

      def test_image_item_reserves_aspect_ratio_and_lazy_loads
        render_inline(Component.new) do |masonry|
          masonry.with_image(src: "https://example.com/harbour.jpg", alt: "Harbour at dusk", width: 400, height: 600)
        end

        assert_selector "img.fp-masonry__image[src='https://example.com/harbour.jpg'][alt='Harbour at dusk']"
        assert_selector "img[width='400'][height='600'][loading='lazy'][decoding='async']"
        assert_includes page.native.to_html, "aspect-ratio: 400 / 600"
      end

      def test_image_item_optional_link_and_caption
        render_inline(Component.new) do |masonry|
          masonry.with_image(
            src: "https://example.com/cliff.jpg",
            alt: "Sea cliff",
            width: 600,
            height: 400,
            href: "https://example.com/photos/cliff",
            caption: "Sea cliff"
          )
        end

        assert_selector "figure.fp-masonry__figure"
        assert_selector "a.fp-masonry__link[href='https://example.com/photos/cliff'] img[alt='Sea cliff']"
        assert_selector "figcaption", text: "Sea cliff"
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

      def test_rejects_unsafe_image_src
        error = assert_raises(ArgumentError) do
          Image.new(src: "javascript:alert(1)", alt: "Bad", width: 100, height: 100)
        end
        assert_match(/Invalid src/, error.message)
      end

      def test_rejects_non_string_alt
        error = assert_raises(ArgumentError) do
          Image.new(src: "https://example.com/a.jpg", alt: nil, width: 100, height: 100)
        end
        assert_match(/alt must be a String/, error.message)
      end

      def test_rejects_non_positive_dimensions
        error = assert_raises(ArgumentError) do
          Image.new(src: "https://example.com/a.jpg", alt: "A", width: 0, height: 100)
        end
        assert_match(/width must be a positive integer/, error.message)
      end

      def test_rejects_unsafe_image_href
        error = assert_raises(ArgumentError) do
          Image.new(src: "https://example.com/a.jpg", alt: "A", width: 100, height: 100, href: "javascript:alert(1)")
        end
        assert_match(/Invalid href/, error.message)
      end

      def test_allows_empty_alt_for_decorative_images
        render_inline(Image.new(src: "https://example.com/a.jpg", alt: "", width: 80, height: 80))

        assert_selector "img[alt=''][src='https://example.com/a.jpg']"
      end
    end
  end
end
