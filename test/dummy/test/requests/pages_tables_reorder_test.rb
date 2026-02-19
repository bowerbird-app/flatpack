# frozen_string_literal: true

require "test_helper"

class PagesTablesReorderTest < ActionDispatch::IntegrationTest
  def setup
    @list_key = "request-test-#{SecureRandom.hex(4)}"
    @rows = [
      DemoTableRow.create!(list_key: @list_key, name: "Alpha", status: "active", priority: "high", position: 1),
      DemoTableRow.create!(list_key: @list_key, name: "Beta", status: "inactive", priority: "medium", position: 2),
      DemoTableRow.create!(list_key: @list_key, name: "Gamma", status: "pending", priority: "low", position: 3)
    ]
  end

  test "reorders rows via generic contract" do
    version = DemoTableRow.where(list_key: @list_key).maximum(:updated_at).to_f.to_s

    patch demo_tables_reorder_path, params: {
      reorder: {
        resource: "demo_table_rows",
        strategy: "dense_integer",
        scope: {list_key: @list_key},
        version: version,
        items: [
          {id: @rows[2].id, position: 1},
          {id: @rows[0].id, position: 2},
          {id: @rows[1].id, position: 3}
        ]
      }
    }, as: :json

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal true, payload["ok"]
    assert_equal "dense_integer", payload["strategy"]

    ids = DemoTableRow.where(list_key: @list_key).order(:position).pluck(:id)
    assert_equal [@rows[2].id, @rows[0].id, @rows[1].id], ids
  end

  test "returns conflict when version is stale" do
    patch demo_tables_reorder_path, params: {
      reorder: {
        resource: "demo_table_rows",
        strategy: "dense_integer",
        scope: {list_key: @list_key},
        version: "0",
        items: [
          {id: @rows[1].id, position: 1},
          {id: @rows[0].id, position: 2},
          {id: @rows[2].id, position: 3}
        ]
      }
    }, as: :json

    assert_response :conflict

    payload = JSON.parse(response.body)
    assert_equal false, payload["ok"]
    assert_match(/stale/i, payload["error"])
  end
end
