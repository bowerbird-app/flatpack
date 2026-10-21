# frozen_string_literal: true

require "test_helper"

class PagesBackdropDemoTest < ActionDispatch::IntegrationTest
  test "backdrop demo shows a hero, a card, and a full page" do
    get "/demo/backdrop"

    assert_response :success
    assert_includes response.body, "fp-backdrop"
    assert_includes response.body, "/images/hero-packaging.jpg"
    assert_includes response.body, "/images/hero-stool.jpg"
    assert_includes response.body, "/images/hero-subscription-box.webp"
    assert_includes response.body, "Pack the morning"
    assert_includes response.body, "On the bench"
    assert_includes response.body, "The whole window"
    assert_includes response.body, 'href="/demo/backdrop/full"'
    assert_includes response.body, 'href="#backdrop-card-example"'
  end

  test "full page backdrop has no sidebar shell" do
    get "/demo/backdrop/full"

    assert_response :success
    assert_includes response.body, "fp-backdrop"
    assert_includes response.body, "/images/hero-subscription-box.webp"
    assert_includes response.body, "The whole window"
    assert_includes response.body, 'href="/demo/backdrop"'
    refute_includes response.body, "flat-pack--sidebar-layout"
  end

  test "sidebar includes backdrop" do
    get "/demo/backdrop"

    assert_response :success
    assert_includes response.body, 'href="/demo/backdrop"'
    assert_includes response.body, "Backdrop"
  end
end
