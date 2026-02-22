# frozen_string_literal: true

require "test_helper"

class PagesPaginationInfiniteTest < ActionDispatch::IntegrationTest
  test "pagination infinite page loads when dummy_data table is missing" do
    original = DummyDatum.method(:table_exists?)
    DummyDatum.define_singleton_method(:table_exists?) { false }

    begin
      get demo_pagination_infinite_path
    ensure
      DummyDatum.define_singleton_method(:table_exists?, original)
    end

    assert_response :success
    assert_includes response.body, "Infinite Scroll Pagination"
  end

  test "pagination infinite xhr cards response loads when dummy_data table is missing" do
    original = DummyDatum.method(:table_exists?)
    DummyDatum.define_singleton_method(:table_exists?) { false }

    begin
      get demo_pagination_infinite_path,
        params: {page: 2, view: "cards"},
        headers: {"X-Requested-With" => "XMLHttpRequest"}
    ensure
      DummyDatum.define_singleton_method(:table_exists?, original)
    end

    assert_response :success
    assert_includes response.body, "data-pagination-content"
  end
end