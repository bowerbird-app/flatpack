# frozen_string_literal: true

require "test_helper"

class PickerErrorSlotTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "remote search shows the error slot and recovers on the next query" do
    visit "/demo/picker#load-error"

    within "#picker-demo-error-fallback" do
      assert_text "Unable to load items"
      assert_no_text "Homepage Hero"

      fill_in "picker_query_picker-demo-error-fallback", with: "hero"

      assert_text "Homepage Hero"
      assert_no_text "Unable to load items"
      assert_selector "[data-flat-pack--picker-target='errorState']", text: "Unable to load items", visible: :hidden
    end

    within "#picker-demo-error-slot" do
      assert_text "Nothing came back"
      assert_text "Search for hero to try again."
      assert_no_text "Nothing matched"
      assert_selector "[data-flat-pack-picker-error-slot='true']"

      fill_in "picker_query_picker-demo-error-slot", with: "hero"

      assert_text "Homepage Hero"
      assert_no_text "Nothing came back"
      assert_no_text "Nothing matched"
      assert_selector "[data-flat-pack-picker-error-slot='true']", visible: :hidden
    end
  end
end
