# frozen_string_literal: true

require "test_helper"

class PagesChartsDemoTest < ActionDispatch::IntegrationTest
  test "charts page renders mini chart table row example" do
    get demo_charts_path

    assert_response :success
    assert_includes response.body, "Mini Chart in Table Row"
    assert_includes response.body, "flat-pack"
    assert_includes response.body, "Review Load"
    assert_includes response.body, "Queue Mix"
    assert_includes response.body, "data-flat-pack--chart-height-value=\"56\""
    assert_includes response.body, "data-flat-pack--chart-type-value=\"bar\""
    assert_includes response.body, "sparkline"
    assert_includes response.body, "columnWidth"
    assert_includes response.body, "barHeight"
  end

  test "charts page renders geochart example" do
    get demo_charts_path

    assert_response :success
    assert_includes response.body, "Geo Chart"
    assert_includes response.body, "data-flat-pack--chart-type-value=\"geochart\""
    assert_includes response.body, "AU"
    assert_includes response.body, "MY"
    assert_includes response.body, "TH"
    assert_includes response.body, ":geochart"
  end
end
