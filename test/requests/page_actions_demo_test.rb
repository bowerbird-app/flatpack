# frozen_string_literal: true

require "test_helper"

class PageActionsDemoTest < ActionDispatch::IntegrationTest
  test "the sidebar shell shows the actions the view registered" do
    get "/demo/page_actions"

    assert_response :success
    assert_select "h1", text: "Press kit"
    assert_select "[data-fp-page-actions=top_nav] a[data-fp-style=secondary]", text: "New press kit"
    assert_select "[data-fp-page-actions=top_nav] a[data-fp-style=ghost]", text: "Share"
    assert_select "[data-fp-page-actions=top_nav] a[data-fp-style=danger]", text: "Delete"
    assert_select "[data-fp-page-actions=mobile] a[data-fp-style=primary]", text: "New press kit"
    assert_select "[data-fp-page-actions=mobile] button[aria-label=More]"
  end

  test "the page shell shows solid header actions" do
    get "/demo/page_actions?shell=page"

    assert_response :success
    assert_select "#page-actions-shell[data-fp-page-layout-width=default]"
    assert_select "[data-fp-page-actions=header] a[data-fp-style=primary]", text: "New press kit"
    assert_select "[data-fp-page-actions=header] a[data-fp-style=secondary]", text: "Share"
    assert_select "[data-fp-page-actions=header] a[data-fp-style=danger]", text: "Delete"
    assert_select "[data-fp-page-actions=mobile] [role=menu] a", text: "Share"
    refute_includes response.body, "flat-pack--sidebar-layout"
  end
end
