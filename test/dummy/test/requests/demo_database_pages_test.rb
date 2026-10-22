# frozen_string_literal: true

require "test_helper"

class DemoDatabasePagesTest < ActionDispatch::IntegrationTest
  test "database demo pages render their working components" do
    DummyDatum.find_or_create_by!(email: "avery.stone@example.com") do |row|
      row.name = "Avery Stone"
      row.status = "active"
      row.category = "engineering"
      row.views_count = 12
      row.position = (DummyDatum.maximum(:position) || 0) + 1
      row.published_at = Time.current
    end

    get "/demo/collection_editor"
    assert_response :success
    assert_includes response.body, "Alice Chen"
    assert_includes response.body, "Project collaborators"

    get "/demo/modal_filter", params: {modal_category: "Technology"}
    assert_response :success
    assert_includes response.body, "Modal Filter"
    assert_includes response.body, "Backlog grooming"
    assert_includes response.body, "Design QA"

    get "/demo/tables/basic"
    assert_response :success
    assert_includes response.body, "Basic Table"
    assert_includes response.body, "Backlog grooming"
    assert_includes response.body, "API integration"

    get "/demo/tables/sortable", params: {sort: "name", direction: "desc"}
    assert_response :success
    assert_includes response.body, "Sortable Table"
    assert_includes response.body, "Retrospective prep"
    assert_operator response.body.index("Retrospective prep"), :<, response.body.index("Backlog grooming")

    get "/demo/tables/draggable"
    assert_response :success
    assert_includes response.body, "Backlog grooming"

    get "/demo/pagination_infinite"
    assert_response :success
    assert_includes response.body, "Infinite Scroll"
    assert_includes response.body, "Avery Stone"

    get "/demo/grid/movable_cards"
    assert_response :success
    assert_includes response.body, "Weekly roadmap"

    get "/demo/comments"
    assert_response :success
    assert_includes response.body, "Alice Johnson"

    get "/demo/chat/demo"
    assert_response :success
    assert_includes response.body, "Mina Cho"

    get "/demo/articles"
    assert_response :success
    assert_includes response.body, "New Article"

    get "/users/sign_in"
    assert_response :success
    assert_includes response.body, "Continue with email"
  end

  test "table demos fall back when the demo tables are missing" do
    original_rows = DemoTableRow.method(:table_exists?)
    original_data = DummyDatum.method(:table_exists?)
    DemoTableRow.define_singleton_method(:table_exists?) { false }
    DummyDatum.define_singleton_method(:table_exists?) { false }

    begin
      get "/demo/modal_filter"
      assert_response :success
      assert_includes response.body, "Modal Filter"
      assert_includes response.body, "User 1"
      assert_not_includes response.body, "Backlog grooming"

      get "/demo/tables/basic"
      assert_response :success
      assert_includes response.body, "View User 1"
      assert_not_includes response.body, "Backlog grooming"

      get "/demo/tables/sortable"
      assert_response :success
      assert_includes response.body, "User 1"
      assert_not_includes response.body, "Backlog grooming"

      get "/demo/pagination_infinite"
      assert_response :success
      assert_includes response.body, "Demo User 1"
      assert_not_includes response.body, "Avery Stone"
    ensure
      DemoTableRow.define_singleton_method(:table_exists?, original_rows)
      DummyDatum.define_singleton_method(:table_exists?, original_data)
    end
  end

  test "only a missing table or a dead connection is treated as demo database downtime" do
    refused = ActiveRecord::ConnectionNotEstablished.new("connection refused")
    missing = ActiveRecord::StatementInvalid.new('PG::UndefinedTable: relation "articles" does not exist')
    other = ActiveRecord::StatementInvalid.new("PG::UniqueViolation: duplicate key value")

    assert DemoDatabase.handled?(refused)
    assert DemoDatabase.handled?(missing)
    assert_not DemoDatabase.handled?(other)
  end
end
