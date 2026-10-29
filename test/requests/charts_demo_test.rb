# frozen_string_literal: true

require "test_helper"

class ChartsDemoTest < ActionDispatch::IntegrationTest
  test "charts overview page renders integer ticks example" do
    get "/demo/charts"

    assert_response :success
    assert_includes response.body, "Integer ticks"
    assert_includes response.body, "Jobs per day"
    assert_includes response.body, "data-flat-pack--chart-integer-ticks-value=\"true\""
    assert_includes response.body, "integer_ticks: true"
  end
end
