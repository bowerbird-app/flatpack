# frozen_string_literal: true

require "test_helper"

class ButtonDropdownTriggerStateTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "replacing the state node restyles the trigger and keeps the menu open" do
    visit "/demo/buttons/dropdowns#publish-status"

    trigger = find("#publish-status-dropdown .fp-button-dropdown__trigger")
    assert_equal "secondary", trigger["data-fp-style"]
    assert_includes trigger[:class], "fp-button-flat"
    assert_equal "Draft", trigger.text.squish

    trigger.click
    assert_selector "#publish-status-menu[aria-hidden='false']"
    mark_open_menu!

    choose_status("Published")

    trigger = find("#publish-status-dropdown .fp-button-dropdown__trigger")
    assert_equal "trigger", trigger["data-fp-identity"]
    assert_equal "success", trigger["data-fp-style"]
    assert_includes trigger[:class], "fp-button-raised"
    refute_includes trigger[:class], "fp-button-flat"
    assert_equal "Published", trigger.text.squish
    assert_equal "Published", trigger["aria-label"]
    assert_selector "#publish-status-dropdown .fp-button-dropdown__trigger svg[data-flat-pack--icon-name-value='chevron-down']"
    assert_equal "menu", find("#publish-status-menu", visible: :all)["data-fp-identity"]
    assert_equal "false", find("#publish-status-menu")["aria-hidden"]
    assert_equal "true", trigger["aria-expanded"]
    assert_equal "Published", focused_menu_label
    state = find("#publish-status-state", visible: :all)
    assert_equal "success", state["data-style"]
    assert_equal "raised", state["data-press"]
    assert_equal "Published", state["data-label"]

    choose_status("Draft")

    trigger = find("#publish-status-dropdown .fp-button-dropdown__trigger")
    assert_equal "trigger", trigger["data-fp-identity"]
    assert_equal "secondary", trigger["data-fp-style"]
    assert_includes trigger[:class], "fp-button-flat"
    assert_equal "Draft", trigger["aria-label"]
    assert_equal "true", trigger["aria-expanded"]
    assert_equal "Draft", focused_menu_label
  end

  private

  def mark_open_menu!
    page.execute_script(<<~JS)
      document.querySelector("#publish-status-dropdown .fp-button-dropdown__trigger").dataset.fpIdentity = "trigger"
      document.querySelector("#publish-status-menu").dataset.fpIdentity = "menu"
    JS
  end

  def choose_status(label)
    find("#publish-status-menu button[type='submit']", text: label).click
    assert_selector "#publish-status-dropdown .fp-button-dropdown__trigger[aria-label='#{label}']"
  end

  def focused_menu_label
    page.evaluate_script(<<~JS)
      (function () {
        var active = document.activeElement
        var menu = document.querySelector("#publish-status-menu")
        if (!active || !menu || !menu.contains(active)) return ""
        return active.innerText.trim()
      })()
    JS
  end
end
