# frozen_string_literal: true

require "test_helper"

class PickerEmptySlotTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "local search shows the empty slot and restores results" do
    visit "/demo/picker#empty-results"

    within "#picker-demo-empty-local" do
      assert_selector "[data-flat-pack-picker-empty-slot='true']", visible: :hidden
      assert_text "Homepage Hero"
      assert_no_button "Add an asset"

      fill_in "picker_query_picker-demo-empty-local", with: "zzzz-no-match"

      assert_button "Add an asset"
      assert_selector "button[data-picker-empty-action='add']", text: "Add an asset"
      assert_text "Nothing in the drawer"
      assert_no_text "Homepage Hero"

      fill_in "picker_query_picker-demo-empty-local", with: "Hero"

      assert_text "Homepage Hero"
      assert_no_button "Add an asset"
      assert_selector "[data-flat-pack-picker-empty-slot='true'] button[data-picker-empty-action='add']", visible: :hidden
    end
  end

  test "remote search shows the same empty slot without replacing it" do
    visit "/demo/picker#empty-results"

    within "#picker-demo-empty-remote" do
      assert_text "Homepage Hero"
      assert_selector "[data-flat-pack-picker-empty-slot='true']", visible: :hidden

      fill_in "picker_query_picker-demo-empty-remote", with: "zzzz-no-match"

      assert_button "Add an asset"
      assert_selector "button[data-picker-empty-action='add']", text: "Add an asset"
      assert_text "Nothing in the drawer"
      assert_no_text "Homepage Hero"

      fill_in "picker_query_picker-demo-empty-remote", with: "Hero"

      assert_text "Homepage Hero"
      assert_no_button "Add an asset"
      assert_selector "[data-flat-pack-picker-empty-slot='true'] button[data-picker-empty-action='add']", visible: :hidden
    end
  end
end
