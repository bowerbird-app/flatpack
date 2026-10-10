# frozen_string_literal: true

require "test_helper"

class InlineEditsDemoTest < ActionDispatch::IntegrationTest
  test "inline edit demo renders each flavour" do
    get "/demo/inline_edit"

    assert_response :success
    assert_includes response.body, 'data-controller="flat-pack--inline-edit"'
    assert_includes response.body, "Summer field kit"
    assert_includes response.body, "Coast path notes"
    assert_includes response.body, "Pack light"
    assert_includes response.body, "Leave at dawn"
    assert_includes response.body, "Write as you walk"
    assert_includes response.body, "Notebook name"
    assert_includes response.body, "This save will fail"
    assert_includes response.body, "Night watch"
    assert_includes response.body, "flat-pack-richtext-bubble-menu"
    assert_includes response.body, demo_inline_edit_fail_path
    refute_includes response.body, "flat-pack-content-editor-actions"
  end

  test "save endpoint returns a turbo stream" do
    patch "/demo/inline_edit",
      params: {kit: {title: "New kit"}},
      headers: {"Accept" => "text/vnd.turbo-stream.html"}

    assert_response :success
    assert_includes response.media_type, "turbo-stream"
    assert_includes response.body, "Saved: New kit"
  end

  test "fail endpoint is unprocessable" do
    patch "/demo/inline_edit/fail",
      params: {kit: {title: "Nope"}},
      headers: {"Accept" => "text/vnd.turbo-stream.html"}

    assert_response :unprocessable_entity
  end
end
