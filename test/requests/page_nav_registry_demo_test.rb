# frozen_string_literal: true

require "test_helper"

class PageNavRegistryDemoTest < ActionDispatch::IntegrationTest
  test "the sidebar shell shows the nav the view registered" do
    get "/demo/page_nav_registry"

    assert_response :success
    assert_select "h1", text: "Press kit"
    assert_select ".fp-page-nav.fp-page-nav--bar a[data-fp-style=secondary]", text: "New press kit"
    assert_select ".fp-page-nav a[data-fp-style=secondary]", text: "Share"
    assert_select ".fp-page-nav a[data-fp-style=danger]", text: "Delete"
    assert_select ".fp-page-nav .fp-button-group-menu__row a", count: 3
    assert_select ".fp-page-nav .fp-button-group-menu__panel a.fp-menu-row", count: 3
    assert_select ".fp-page-nav .fp-button-group-menu__trigger[aria-label=Menu]"
    assert_select "header.fp-top-nav .fp-page-nav", count: 0
    assert_select ".fp-page-nav-menu", count: 0
    assert_select ".fp-page-nav-nav", count: 0
    assert_select ".fp-page-nav--floating", count: 0
    assert_select "button[aria-label=More]", count: 0
    assert_select "#publishable_quick_actions_demo", text: "Publish", count: 1
    assert_select ".fp-button-group-menu__row #publishable_quick_actions_demo", count: 1
    assert_select ".fp-button-group-menu__panel .fp-menu-row", text: "Publish", count: 1
    assert_select ".fp-page-nav-components", count: 0
    assert_equal ["New press kit", "Share", "Delete", "Publish"], page_nav_labels
  end

  test "the page shell shows solid header nav" do
    get "/demo/page_nav_registry?shell=page"

    assert_response :success
    assert_select "#page-nav-registry-shell[data-fp-page-layout-width=default]"
    assert_select ".fp-page-nav.fp-page-nav--desktop a[data-fp-style=primary]", text: "New press kit"
    assert_select ".fp-page-nav a[data-fp-style=secondary]", text: "Share"
    assert_select ".fp-page-nav a[data-fp-style=danger]", text: "Delete"
    assert_select ".fp-page-nav .fp-button-group-menu__row a", count: 3
    assert_select ".fp-page-nav .fp-button-group-menu__panel a.fp-menu-row", count: 3
    assert_select ".fp-page-nav--bar", count: 0
    assert_select "header.fp-top-nav .fp-page-nav", count: 0
    assert_select ".fp-page-nav-nav", count: 0
    assert_select ".fp-page-nav--floating", count: 0
    assert_select ".fp-page-nav-menu", count: 0
    assert_select ".fp-button-group-menu__row #publishable_quick_actions_demo", text: "Publish", count: 1
    assert_select ".fp-button-group-menu__panel .fp-menu-row", text: "Publish", count: 1
    assert_select ".fp-page-nav-components", count: 0
    assert_equal ["New press kit", "Share", "Delete", "Publish"], page_nav_labels
    refute_includes response.body, "flat-pack--sidebar-layout"
  end

  private

  def page_nav_labels
    panel = css_select(".fp-page-nav .fp-button-group-menu__panel").first
    panel.css("> *").map { |node| node.text.squish }
  end
end
