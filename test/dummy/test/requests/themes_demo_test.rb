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
end
