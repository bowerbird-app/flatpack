# frozen_string_literal: true

require "test_helper"

class PagesOverlayDemoTest < ActionDispatch::IntegrationTest
  test "overlay demo places nine spots and a badge, icon, and button" do
    get "/demo/overlay"

    assert_response :success
    assert_includes response.body, "fp-overlay"
    assert_includes response.body, "/images/hero-stool.jpg"
    assert_includes response.body, "/images/hero-packaging.jpg"
    assert_includes response.body, 'data-fp-placement="top_left"'
    assert_includes response.body, 'data-fp-placement="center"'
    assert_includes response.body, 'data-fp-placement="bottom_right"'
    assert_includes response.body, 'data-fp-inset="sm"'
    assert_includes response.body, 'data-fp-inset="md"'
    assert_includes response.body, 'data-fp-inset="lg"'
    assert_includes response.body, "Top left"
    assert_includes response.body, "Bottom right"
    assert_includes response.body, ">New<"
    assert_includes response.body, ">Share<"
    assert_includes response.body, 'data-flat-pack--icon-name-value="heart"'
  end

  test "sidebar includes overlay" do
    get "/demo/overlay"

    assert_response :success
    assert_includes response.body, 'href="/demo/overlay"'
    assert_includes response.body, "Overlay"
  end
end
