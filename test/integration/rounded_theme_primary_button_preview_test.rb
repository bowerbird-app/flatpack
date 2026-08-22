# frozen_string_literal: true

require "test_helper"

class RoundedThemePrimaryButtonPreviewTest < ActionDispatch::IntegrationTest
  test "rounded preview sets data-theme on html and body and renders a primary button" do
    get theme_preview_path(theme: "rounded")

    assert_response :success
    assert_includes response.body, 'data-theme="rounded"'
    assert_includes response.body, 'data-flat-pack-preview="theme-primary-button"'
    assert_includes response.body, "bg-[var(--button-primary-background-color)]"
    assert_match(/<html[^>]*data-theme="rounded"/, response.body)
    assert_match(/<body[^>]*data-theme="rounded"/, response.body)
  end

  test "rounded theme demo lists the primary-token rebind" do
    get theme_demo_path(theme: "rounded")

    assert_response :success
    assert_includes response.body, 'data-flat-pack-preview="theme-primary-button"'
    assert_includes response.body, "--button-primary-background-color: var(--color-primary)"
    assert_includes response.body, "--color-primary: oklch(0.3211 0 0)"
  end
end
