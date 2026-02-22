# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Pagination
    class ComponentTest < ViewComponent::TestCase
      def test_renders_pagination_with_valid_pagy
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "nav[aria-label='Pagination']"
      end

      def test_renders_prev_button_when_prev_exists
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "a[aria-label='Previous page']"
      end

      def test_renders_disabled_prev_button_when_no_prev
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "[aria-label='Previous page'][aria-disabled='true']"
      end

      def test_renders_next_button_when_next_exists
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "a[aria-label='Next page']"
      end

      def test_renders_disabled_next_button_when_no_next
        pagy = MockPagy.new(page: 5, pages: 5, prev: 4, next_page: nil, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "[aria-label='Next page'][aria-disabled='true']"
      end

      def test_renders_page_numbers_in_normal_size
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy, size: :normal))

        assert_selector "a[aria-label='Page 1']"
        assert_selector "[aria-label='Page 2'][aria-current='page']"
        assert_selector "a[aria-label='Page 3']"
      end

      def test_does_not_render_page_numbers_in_compact_size
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy, size: :compact))

        refute_selector "a[aria-label='Page 1']"
        refute_selector "a[aria-label='Page 3']"
      end

      def test_highlights_current_page
        pagy = MockPagy.new(page: 3, pages: 5, prev: 2, next_page: 4, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "[aria-label='Page 3'][aria-current='page']"
        assert_includes page.native.to_html, "bg-primary"
      end

      def test_returns_nil_when_single_page_and_not_compact
        pagy = MockPagy.new(page: 1, pages: 1, prev: nil, next_page: nil, series: [1])
        render_inline(Component.new(pagy: pagy))

        assert_empty page.native.to_html.strip
      end

      def test_renders_when_single_page_and_compact
        pagy = MockPagy.new(page: 1, pages: 1, prev: nil, next_page: nil, series: [1])
        render_inline(Component.new(pagy: pagy, size: :compact))

        assert_selector "nav[aria-label='Pagination']"
      end

      def test_renders_gap_for_string_in_series
        pagy = MockPagy.new(page: 5, pages: 10, prev: 4, next_page: 6, series: [1, "gap", 4, 5, 6, "gap", 10])
        render_inline(Component.new(pagy: pagy))

        assert_selector "span", text: "…", count: 2
      end

      def test_renders_gap_for_symbol_in_series
        pagy = MockPagy.new(page: 5, pages: 10, prev: 4, next_page: 6, series: [1, :gap, 4, 5, 6, :gap, 10])
        render_inline(Component.new(pagy: pagy))

        assert_selector "span", text: "…", count: 2
      end

      def test_raises_error_for_invalid_pagy
        error = assert_raises(ArgumentError) do
          Component.new(pagy: {})
        end
        assert_match(/pagy must be a Pagy instance/, error.message)
      end

      def test_raises_error_for_invalid_size
        pagy = MockPagy.new(page: 1, pages: 5)
        error = assert_raises(ArgumentError) do
          Component.new(pagy: pagy, size: :invalid)
        end
        assert_match(/Invalid size: invalid/, error.message)
      end

      def test_accepts_normal_size
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy, size: :normal))

        assert_selector "nav"
      end

      def test_accepts_compact_size
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy, size: :compact))

        assert_selector "nav"
      end

      def test_applies_correct_classes_to_container
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        assert_selector "nav.flex.items-center.justify-center"
      end

      def test_page_buttons_have_correct_classes
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        html = page.native.to_html
        assert_includes html, "min-w-[2.25rem]"
        assert_includes html, "rounded-sm"
      end

      def test_disabled_buttons_have_correct_styles
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy))

        html = page.native.to_html
        assert_includes html, "cursor-not-allowed"
        assert_includes html, "opacity-50"
      end

      def test_merges_custom_classes
        pagy = MockPagy.new(page: 1, pages: 5, prev: nil, next_page: 2, series: [1, 2, 3, 4, 5])
        render_inline(Component.new(pagy: pagy, class: "custom-pagination"))

        assert_selector "nav.custom-pagination"
      end
    end
  end
end
