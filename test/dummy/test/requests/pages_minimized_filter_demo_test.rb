# frozen_string_literal: true

require "test_helper"

class PagesMinimizedFilterDemoTest < ActionDispatch::IntegrationTest
  test "minimized filter demo renders dedicated modal-only content" do
    get "/demo/minimized_filter"

    assert_response :success
    assert_includes response.body, "Minimized Filters"
    assert_includes response.body, "filter_body"
    assert_includes response.body, "minimized-filter-table-frame"
    assert_includes response.body, "minimized-filter-table-controls"
    assert_includes response.body, "minimized_status"
  end
end
