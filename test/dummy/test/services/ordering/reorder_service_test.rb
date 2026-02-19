# frozen_string_literal: true

require "test_helper"

module Ordering
  class ReorderServiceTest < ActiveSupport::TestCase
    def setup
      @list_key = "service-test-#{SecureRandom.hex(4)}"
      @rows = [
        DemoTableRow.create!(list_key: @list_key, name: "One", status: "active", priority: "high", position: 1),
        DemoTableRow.create!(list_key: @list_key, name: "Two", status: "active", priority: "medium", position: 2),
        DemoTableRow.create!(list_key: @list_key, name: "Three", status: "pending", priority: "low", position: 3)
      ]
    end

    def test_reorders_rows_with_dense_integer_strategy
      relation = DemoTableRow.where(list_key: @list_key)

      result = ReorderService.call(
        relation: relation,
        strategy: "dense_integer",
        items: [
          {id: @rows[2].id, position: 1},
          {id: @rows[0].id, position: 2},
          {id: @rows[1].id, position: 3}
        ],
        version: relation.maximum(:updated_at).to_f.to_s
      )

      assert_equal true, result[:ok]
      assert_equal [@rows[2].id, @rows[0].id, @rows[1].id], relation.order(:position).pluck(:id)
    end

    def test_returns_conflict_for_stale_version
      relation = DemoTableRow.where(list_key: @list_key)

      result = ReorderService.call(
        relation: relation,
        strategy: "dense_integer",
        items: [
          {id: @rows[1].id, position: 1},
          {id: @rows[0].id, position: 2},
          {id: @rows[2].id, position: 3}
        ],
        version: "0"
      )

      assert_equal false, result[:ok]
      assert_equal :conflict, result[:status]
      assert_match(/stale/i, result[:error])
    end
  end
end
