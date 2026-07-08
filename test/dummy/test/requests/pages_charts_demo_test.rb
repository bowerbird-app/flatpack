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
    assert_includes response.body, "United States"
    assert_includes response.body, ":geochart"
  end

  test "charts page renders stacked chart examples after matching base charts" do
    get demo_charts_path

    assert_response :success
    assert_includes response.body, "Stacked Column Chart"
    assert_includes response.body, "Stacked Bar Chart"
    assert_includes response.body, ":stacked_column"
    assert_includes response.body, ":stacked_bar"
    assert_includes response.body, "Traffic by Device"
    assert_includes response.body, "Quarterly Product Mix"

    column_index = response.body.index("Column Chart")
    stacked_column_index = response.body.index("Stacked Column Chart")
    bar_index = response.body.index("Bar Chart")
    stacked_bar_index = response.body.index("Stacked Bar Chart")

    assert_operator column_index, :<, stacked_column_index
    assert_operator stacked_column_index, :<, bar_index
    assert_operator bar_index, :<, stacked_bar_index
  end
end
