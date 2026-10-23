# frozen_string_literal: true

require "test_helper"

class PageNavRegistryDemoTest < ActionDispatch::IntegrationTest
  test "the sidebar page draws the group beside the title" do
    get "/demo/page_nav_registry"

    assert_response :success
    assert_select "#page-nav-registry-header h1", text: "Press kit"
    assert_select "#page-nav-registry-header .fp-button-group-menu a[data-fp-style=secondary]", text: "New press kit"
    assert_select "#page-nav-registry-header a[data-fp-style=secondary]", text: "Share"
    assert_select "#page-nav-registry-header .fp-button-group__overflow a.fp-menu-row[data-fp-style=danger]", text: "Delete", count: 1
    assert_select "#page-nav-registry-header .fp-button-group-menu__panel a.fp-menu-row[data-fp-style=danger]", text: "Delete", count: 1
    assert_select "#page-nav-registry-header .fp-button-group-menu__row > a[data-fp-style=danger]", count: 0
    assert_select "#page-nav-registry-header .fp-button-group-menu__row > a", count: 2
    assert_select "#page-nav-registry-header .fp-button-group-menu__panel a.fp-menu-row", count: 3
    assert_equal ["New press kit", "Share", "Publish", "More"], page_nav_row_labels
    assert_select "#page-nav-registry-header .fp-button-group-menu__trigger[aria-label=Menu]"
    assert_select "header.fp-top-nav .fp-button-group-menu", count: 0
    assert_select ".fp-page-nav", count: 0
    assert_select "#page-nav-registry-header .fp-button-group__overflow > .fp-button-dropdown__trigger[aria-label=More]", count: 1
    assert_select "#publishable_quick_actions_demo", text: "Publish", count: 1
    assert_select ".fp-button-group-menu__row #publishable_quick_actions_demo", count: 1
    assert_select ".fp-button-group-menu__panel .fp-menu-row", text: "Publish", count: 1
    assert_equal ["New press kit", "Share", "Delete", "Publish"], page_nav_labels
  end

  test "the page shell draws a solid group beside the title" do
    get "/demo/page_nav_registry?shell=page"

    assert_response :success
    assert_select "#page-nav-registry-shell[data-fp-page-layout-width=default]"
    assert_select "#page-nav-registry-header h1", text: "Press kit"
    assert_select "#page-nav-registry-shell .fp-layout-column #page-nav-registry-header .fp-button-group-menu a[data-fp-style=primary]", text: "New press kit"
    assert_select "#page-nav-registry-header a[data-fp-style=secondary]", text: "Share"
    assert_select "#page-nav-registry-header .fp-button-group__overflow a.fp-menu-row[data-fp-style=danger]", text: "Delete", count: 1
    assert_select "#page-nav-registry-header .fp-button-group-menu__row > a", count: 2
    assert_select "#page-nav-registry-header .fp-button-group-menu__panel a.fp-menu-row", count: 3
    assert_equal ["New press kit", "Share", "Publish", "More"], page_nav_row_labels
    assert_select "header.fp-top-nav .fp-button-group-menu", count: 0
    assert_select ".fp-page-nav", count: 0
    assert_select ".fp-button-group-menu__row #publishable_quick_actions_demo", text: "Publish", count: 1
    assert_select ".fp-button-group-menu__panel .fp-menu-row", text: "Publish", count: 1
    assert_equal ["New press kit", "Share", "Delete", "Publish"], page_nav_labels
    refute_includes response.body, "flat-pack--sidebar-layout"
  end

  private

  def page_nav_labels
    panel = css_select("#page-nav-registry-header .fp-button-group-menu__panel").first
    panel.css("> *").map { |node| node.text.squish }
  end

  def page_nav_row_labels
    row = css_select("#page-nav-registry-header .fp-button-group-menu__row").first
    row.element_children.map do |node|
      if node["class"].to_s.include?("fp-button-group__overflow")
        trigger = node.at_css(".fp-button-dropdown__trigger")
        trigger.text.squish.presence || trigger["aria-label"]
      else
        node.text.squish
      end
    end
  end
end
