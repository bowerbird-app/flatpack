# frozen_string_literal: true

require "test_helper"

class LocaleSwitchingTest < ActionDispatch::IntegrationTest
  test "catalog html exposes the current locale and kit copy payload" do
    get "/"

    assert_response :success
    assert_select "html[lang=?]", "en"
    assert_select "html[data-fp-copy]"
    assert_includes response.body, "Skip to content"
  end

  test "French dummy translations render when the locale is fr" do
    if defined?(RecordingStudioInternationalization)
      cookies[:recording_studio_locale] = "fr"
      get "/"
      assert_select "html[lang=?]", "fr"
    else
      I18n.with_locale(:fr) { get "/" }
    end

    assert_response :success
    assert_includes response.body, "Aller au contenu"
    refute_includes response.body, "Skip to content"
  end

  test "language selector sits in the top nav with English and Français, left of the theme control" do
    skip "recording_studio_internationalization is a dummy-host gem" unless defined?(RecordingStudioInternationalization)

    get "/"

    assert_response :success
    assert_select "header.fp-top-nav form.dummy-language-selector", count: 1
    assert_select "form.dummy-language-selector", count: 1
    assert_select "header.fp-top-nav select[name=locale] option[value=en]", text: "English"
    assert_select "header.fp-top-nav select[name=locale] option[value=fr]", text: "Français"

    nav = response.body[/<header\b[^>]*\bfp-top-nav\b.*?<\/header>/m]
    assert nav, "catalog top nav is missing"
    locale_at = nav.index("dummy-language-selector")
    theme_at = nav.index(">Theme<") || nav.index("Theme")
    assert locale_at, "language selector is not in the top nav"
    assert theme_at, "theme control is not in the top nav"
    assert_operator locale_at, :<, theme_at, "language selector should sit immediately left of the theme control"
  end

  test "switching the top nav selector to French changes FlatPack copy" do
    skip "recording_studio_internationalization is a dummy-host gem" unless defined?(RecordingStudioInternationalization)

    patch "/recording_studio_internationalization/locale", params: {locale: "fr", return_to: "/"}

    assert_response :see_other
    follow_redirect!

    assert_select "html[lang=?]", "fr"
    assert_includes response.body, "Aller au contenu"
    refute_includes response.body, "Skip to content"
    assert_select "header.fp-top-nav select[name=locale] option[value=fr][selected]"
  end

  test "phone search toggle is a small collapsed control" do
    get "/"

    assert_response :success
    assert_select "header.fp-top-nav .fp-search--collapsible[data-fp-size=sm] .fp-search__toggle", count: 1
  end

  test "floating shell uses a labeled view menu instead of a second hamburger" do
    get "/", params: {floating: "1"}

    assert_response :success
    assert_select "header.fp-top-nav .fp-button-group-menu__trigger", text: "View", count: 1
    assert_select "header.fp-top-nav .fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value=chevron-down]", count: 1
    assert_select "header.fp-top-nav .fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value=bars-3]", count: 0
  end
end
