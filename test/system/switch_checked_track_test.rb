# frozen_string_literal: true

require "test_helper"

class SwitchCheckedTrackTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "clicking a checked switch clears the track and the switch role" do
    visit "/demo/forms/switch"
    freeze_motion

    assert_predicate switch_input, :checked?
    assert_equal "true", accessible_checked
    assert_equal resolved_token("--switch-track-checked-background-color"), track_color

    click_switch

    refute_predicate switch_input, :checked?
    assert_equal "false", accessible_checked
    assert_equal resolved_token("--switch-track-background-color"), track_color

    click_switch

    assert_predicate switch_input, :checked?
    assert_equal "true", accessible_checked
    assert_equal resolved_token("--switch-track-checked-background-color"), track_color
  end

  private

  def switch_input
    find("input[name='autosave_toggle'][role='switch']", visible: :all)
  end

  def click_switch
    switch_input.find(:xpath, "./parent::label").click
  end

  def freeze_motion
    page.execute_script(<<~JS)
      const sheet = document.createElement("style")
      sheet.textContent = "*, *::before, *::after { transition: none !important; animation: none !important; }"
      document.head.appendChild(sheet)
    JS
  end

  def track_color
    page.evaluate_script(<<~JS)
      (() => {
        const input = document.querySelector("input[name='autosave_toggle']")
        return getComputedStyle(input.nextElementSibling).backgroundColor
      })()
    JS
  end

  def resolved_token(name)
    page.evaluate_script(<<~JS, name)
      (() => {
        const specified = getComputedStyle(document.documentElement).getPropertyValue(arguments[0]).trim()
        const probe = document.createElement("div")
        probe.style.backgroundColor = specified
        probe.hidden = true
        document.body.appendChild(probe)
        const color = getComputedStyle(probe).backgroundColor
        probe.remove()
        return color
      })()
    JS
  end

  def accessible_checked
    browser = page.driver.browser
    document = browser.execute_cdp("DOM.getDocument", depth: 0)
    node = browser.execute_cdp(
      "DOM.querySelector",
      nodeId: document.dig("root", "nodeId"),
      selector: "input[name='autosave_toggle']"
    )
    tree = browser.execute_cdp(
      "Accessibility.getPartialAXTree",
      nodeId: node.fetch("nodeId"),
      fetchRelatives: false
    )
    checked = tree.dig("nodes", 0, "properties")&.find { |property| property["name"] == "checked" }

    checked.dig("value", "value")
  end
end
