# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Pagination
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_numbers_as_labels_not_query_strings
        pagy = MockPagy.new(page: 2, pages: 5, prev: 1, next_page: 3, series: [1, 2, 3, :gap, 5])

        render_inline(Component.new(pagy: pagy))

        assert_selector "a[href='?page=1']", text: "1"
        assert_selector "span", text: "2"
        assert_selector "a[href='?page=3']", text: "3"
        assert_no_selector "a", text: "?page=1"
        assert_no_selector "a", text: "?page=3"
      end

      def test_renders_icon_buttons_for_prev_and_next
        pagy = MockPagy.new(page: 2, pages: 3, prev: 1, next_page: 3, series: [1, 2, 3])

        render_inline(Component.new(pagy: pagy))

        assert_selector "a[href='?page=1'][aria-label='Previous page'] svg"
        assert_selector "a[href='?page=3'][aria-label='Next page'] svg"
      end
    end
  end
end
