# frozen_string_literal: true

require "test_helper"

class DemoDatabasePagesTest < ActionDispatch::IntegrationTest
  test "database demo pages render their working components" do
    get "/demo/collection_editor"
    assert_response :success
    assert_includes response.body, "Alice Chen"
    assert_includes response.body, "Project collaborators"

    get "/demo/modal_filter", params: {modal_category: "Technology"}
    assert_response :success
    assert_includes response.body, "Modal Filter"

    get "/demo/tables/basic"
    assert_response :success
    assert_includes response.body, "Basic Table"

    get "/demo/tables/sortable", params: {sort: "name", direction: "desc"}
    assert_response :success
    assert_includes response.body, "Sortable Table"
    assert_includes response.body, "User 9"

    get "/demo/tables/draggable"
    assert_response :success
    assert_includes response.body, "Backlog grooming"

    get "/demo/pagination_infinite", params: {page: 2}
    assert_response :success
    assert_includes response.body, "Infinite Scroll"

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
end
