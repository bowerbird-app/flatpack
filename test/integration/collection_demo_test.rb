# frozen_string_literal: true

require "test_helper"

class CollectionDemoTest < ActionDispatch::IntegrationTest
  test "collection demo renders the press kit menu and the wrap" do
    get "/demo/collection"

    assert_response :success
    assert_includes response.body, "Press kit"
    assert_includes response.body, "<nav"
    assert_includes response.body, 'aria-label="Press kit"'
    assert_includes response.body, "grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]"
    assert_includes response.body, "--fp-collection-min-item-width: 14rem"
    assert_includes response.body, 'aria-current="page"'
    assert_includes response.body, "fp-button-current"
    assert_includes response.body, "Logos and lockups for print, screen, and social"
    assert_includes response.body, "flex-wrap"
    assert_includes response.body, "Northlight"
    assert_includes response.body, "aria-hidden=\"true\""
  end

  test "buttons demo renders the menu row" do
    get "/demo/buttons"

    assert_response :success
    assert_includes response.body, "Menu row"
    assert_includes response.body, "align: :start"
    assert_includes response.body, 'aria-current="page"'
    assert_includes response.body, "fp-button-current"
  end
end
