# frozen_string_literal: true

require "test_helper"

class ThemePrimaryButtonPreviewTest < ActionDispatch::IntegrationTest
  test "rounded preview uses html and body data-theme=rounded with a primary button" do
    get theme_preview_path(theme: "rounded")

    assert_response :success
    assert_includes response.body, "<html"
    assert_includes response.body, "<body"
    assert_includes response.body, 'data-theme="rounded"'
    assert_includes response.body, 'data-flat-pack-preview="theme-primary-button"'
    assert_includes response.body, "bg-[var(--button-primary-background-color)]"
    assert_includes response.body, 'data-flat-pack-preview="theme-page-nav"'
    assert_includes response.body, "flat-pack--page-nav#back"
    assert_includes response.body, "rounded-[var(--button-border-radius)]"
  end

  test "unknown theme preview is not found" do
    get "/themes/previews/sunrise"

    assert_response :not_found
  end
end
