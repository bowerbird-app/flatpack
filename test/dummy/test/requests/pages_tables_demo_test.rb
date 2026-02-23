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
  end
end
