# frozen_string_literal: true

require "test_helper"

class PagesTablesDemoTest < ActionDispatch::IntegrationTest
  test "tables basic page loads when demo_table_rows table is missing" do
    original = DemoTableRow.method(:table_exists?)
    DemoTableRow.define_singleton_method(:table_exists?) { false }

    begin
      get demo_tables_basic_path
    ensure
      DemoTableRow.define_singleton_method(:table_exists?, original)
    end

    assert_response :success
    assert_includes response.body, "Basic Table Demos"
    assert_includes response.body, "Actions"
    assert_includes response.body, "View User 1"
  end

  test "tables basic page renders generic filter and multi-control table sections" do
    get demo_tables_basic_path

    assert_response :success
    assert_includes response.body, "Table with Generic Filter Controls"
    assert_includes response.body, "Single Outer Frame with Multiple Table Controls"
    assert_includes response.body, "basic-table-generic-filter-frame"
    assert_includes response.body, "basic-table-1-panel"
    assert_includes response.body, "basic-table-2-panel"
  end

  test "tables basic generic filter/search controls keep selected state in links and form" do
    get demo_tables_basic_path, params: {
      filter_field: "status",
      filter_value: "pending",
      q: "user 1"
    }

    assert_response :success
    assert_includes response.body, "Filter: Status"
    assert_includes response.body, "Value: Pending"
    assert_includes response.body, 'name="q"'
    assert_includes response.body, 'value="user 1"'
    assert_includes response.body, "filter_field=status"
    assert_includes response.body, "filter_value=pending"
  end

  test "tables basic multi-controls preserve shared query and independent table params" do
    get demo_tables_basic_path, params: {
      table_1_category: "business",
      table_2_status: "active",
      table_multi_q: "user"
    }

    assert_response :success
    assert_includes response.body, 'name="table_multi_q"'
    assert_includes response.body, 'value="user"'
    assert_includes response.body, "table_1_category=business"
    assert_includes response.body, "table_2_status=active"
    assert_includes response.body, 'data-turbo-frame="basic-table-multi-frame"'
  end
end
