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
  end

  test "language selector is present when the internationalization gem is loaded" do
    skip "recording_studio_internationalization is a dummy-host gem" unless defined?(RecordingStudioInternationalization)

    get "/"

    assert_response :success
    assert_match(/Français|locale/i, response.body)
  end
end
