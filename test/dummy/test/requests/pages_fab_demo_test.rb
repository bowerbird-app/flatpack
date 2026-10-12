# frozen_string_literal: true

require "test_helper"

class PagesFabDemoTest < ActionDispatch::IntegrationTest
  test "fab demo renders single-action, speed-dial, corners, and a modal action" do
    get "/demo/fab"

    assert_response :success
    assert_includes response.body, "fp-fab"
    assert_includes response.body, 'data-controller="flat-pack--fab"'
    assert_includes response.body, 'role="menu"'
    assert_includes response.body, "New note"
    assert_includes response.body, 'data-modal-id="fab-invite"'
    assert_includes response.body, "fp-fab--contained"
    assert_includes response.body, "fp-bottom-nav"
    assert_includes response.body, 'href="/mobile/fab"'
    assert_includes response.body, "Open the phone layout"
    assert_includes response.body, "with_action"
    assert_includes response.body, "layout"
    assert_includes response.body, 'data-fp-size="sm"'
    assert_includes response.body, 'data-fp-style="danger"'
    assert_includes response.body, "Edit title"
    assert_includes response.body, "Trash"
    assert_includes response.body, "Add section"
    assert_includes response.body, "contained-editor"
  end

  test "fab demo honors a corner query" do
    get "/demo/fab", params: {position: "top_left"}

    assert_response :success
    assert_includes response.body, 'id="live-fab"'
    assert_includes response.body, 'data-fp-position="top_left"'
  end

  test "mobile fab sits with the tab bar" do
    get "/mobile/fab"

    assert_response :success
    assert_includes response.body, "fp-fab"
    assert_includes response.body, "fp-bottom-nav"
    assert_includes response.body, 'data-controller="flat-pack--fab"'
  end
end
