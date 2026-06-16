# frozen_string_literal: true

require "test_helper"

class PagesModalFilterDemoTest < ActionDispatch::IntegrationTest
  test "modal filter demo renders dedicated modal-only content" do
    get "/demo/modal_filter"

    assert_response :success
    assert_includes response.body, "Modal Filter"
    assert_includes response.body, "filter_body"
    assert_includes response.body, "modal-filter-table-frame"
    assert_includes response.body, "modal-filter-table-controls"
    assert_includes response.body, "modal_status"
  end
end
