# frozen_string_literal: true

require "test_helper"

class BrandThemeDemoTest < ActionDispatch::IntegrationTest
  test "brand theme demo puts a semantic-only theme on body" do
    get "/demo/brand_theme"

    assert_response :success
    assert_includes response.body, 'data-theme="featured-in"'
    assert_includes response.body, "Sign out"
    refute_includes response.body, 'data-controller="flat-pack--theme"'
  end

  test "brand dark theme demo puts featured-in-dark on body" do
    get "/demo/brand_theme/dark"

    assert_response :success
    assert_includes response.body, 'data-theme="featured-in-dark"'
    assert_includes response.body, "Sign out"
    assert_includes response.body, "Theme"
  end
end
