# frozen_string_literal: true

require "test_helper"

class ThemesDemoTest < ActionDispatch::IntegrationTest
  THEMES = {
    "system" => "System",
    "light" => "Light",
    "dark" => "Dark",
    "ocean" => "Ocean",
    "rounded" => "Rounded"
  }.freeze

  test "themes index loads" do
    get themes_path

    assert_response :success
    assert_includes response.body, "Themes"
    assert_includes response.body, "Theme Variable Reference"
  end

  test "theme demo pages load for each supported theme" do
    THEMES.each do |theme, label|
      get theme_demo_path(theme: theme)

      assert_response :success, "Expected theme #{theme} to load"
      assert_includes response.body, "#{label} Theme Demo"
      assert_includes response.body, "Variables Used By This Theme"
      assert_includes response.body, "#{label} Theme Variables"
    end
  end

  test "invalid theme demo route returns not found" do
    get "/themes/demos/invalid"

    assert_response :not_found
  end

  test "system theme includes explanatory system header" do
    get theme_demo_path(theme: "system")

    assert_response :success
    assert_includes response.body, "System theme tracks the OS preference"
  end

  test "rounded theme demo shows the spacing scale" do
    get theme_demo_path(theme: "rounded")

    assert_response :success
    assert_includes response.body, "shifts --space-2 through --space-6"
    assert_includes response.body, "--space-2: 0.75rem"
    assert_includes response.body, "--dropdown-padding:"
  end

  test "brand theme demo sets data-theme on body" do
    get "/demo/brand_theme/dark"

    assert_response :success
    assert_includes response.body, 'data-theme="featured-in-dark"'
    assert_includes response.body, "Sign out"
  end
end
