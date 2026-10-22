# frozen_string_literal: true

require "test_helper"

class PageNavRegistryDemoTest < ActionDispatch::IntegrationTest
  test "the sidebar shell shows the nav the view registered" do
    get "/demo/page_nav_registry"

    assert_response :success
    assert_select "h1", text: "Press kit"
    assert_select "[data-fp-page-nav=top_nav] a[data-fp-style=secondary]", text: "New press kit"
    assert_select "[data-fp-page-nav=top_nav] a[data-fp-style=ghost]", text: "Share"
    assert_select "[data-fp-page-nav=top_nav] a[data-fp-style=danger]", text: "Delete"
    assert_select "header.fp-top-nav [data-fp-page-nav=menu] a[data-fp-style=secondary]", text: "New press kit"
    assert_select "[data-fp-page-nav=menu] a[data-fp-style=ghost]", text: "Share"
    assert_select "[data-fp-page-nav=menu] a[data-fp-style=danger]", text: "Delete"
    assert_select "[data-flat-pack--top-nav-target=panel]"
    assert_select "button[aria-label=More]", count: 0
    assert_select "#publishable_quick_actions_demo", count: 1
    assert_select "[data-fp-page-nav=menu] #publishable_quick_actions_demo", count: 0
  end

  test "the page shell shows solid header nav" do
    get "/demo/page_nav_registry?shell=page"

    assert_response :success
    assert_select "#page-nav-registry-shell[data-fp-page-layout-width=default]"
    assert_select "[data-fp-page-nav=header] a[data-fp-style=primary]", text: "New press kit"
    assert_select "[data-fp-page-nav=header] a[data-fp-style=secondary]", text: "Share"
    assert_select "[data-fp-page-nav=header] a[data-fp-style=danger]", text: "Delete"
    assert_select "header.fp-top-nav [data-fp-page-nav=menu] a[data-fp-style=ghost]", text: "Share"
    assert_select "[data-fp-page-nav=menu] a[data-fp-style=danger]", text: "Delete"
    assert_select ".fp-page-nav-nav", count: 0
    assert_select ".fp-page-nav--floating", count: 0
    assert_select "#publishable_quick_actions_demo", count: 1
    refute_includes response.body, "flat-pack--sidebar-layout"
  end
end
