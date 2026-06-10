# frozen_string_literal: true

require "test_helper"

class PagesChartsDemoTest < ActionDispatch::IntegrationTest
  test "charts page renders mini chart table row example" do
    get demo_charts_path

    assert_response :success
    assert_includes response.body, "Mini Chart in Table Row"
    assert_includes response.body, "flat-pack"
    assert_includes response.body, "data-flat-pack--chart-height-value=\"56\""
    assert_includes response.body, "sparkline"
  end
end
