# frozen_string_literal: true

require "test_helper"

class IconPickerTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "search filters the grid and the keyboard picks an icon" do
    visit "/demo/forms/icon_picker"

    assert_equal 0, grid_buttons

    find("#icon-field").send_keys(:arrow_down)

    assert_selector "#icon-field_panel:not(.hidden)"
    assert_operator grid_buttons, :>, 100

    search = find("#icon-field_panel input")
    search.send_keys("zzzz-nope")
    assert_text "No icons found"

    page.execute_script(<<~JS, search.native)
      arguments[0].value = ""
      arguments[0].dispatchEvent(new Event("input", { bubbles: true }))
    JS
    search.send_keys("arrow")
    assert_selector "#icon-field_panel [data-icon-name='arrow-right']"
    assert_selector "#icon-field_panel [data-icon-name='star']", visible: :hidden

    search.send_keys(:arrow_down)
    chosen = page.evaluate_script("document.activeElement?.getAttribute('data-icon-name')")
    assert chosen.present?
    assert_includes chosen, "arrow"
    page.driver.browser.switch_to.active_element.send_keys(:enter)

    assert_equal "false", find("#icon-field")["aria-expanded"]
    assert_equal chosen, find("#icon-field_value", visible: :all).value
    assert_equal "icon-field", page.evaluate_script("document.activeElement?.id")
  end

  test "the open panel escapes a modal table cell" do
    visit "/demo/forms/icon_picker"
    find("[data-modal-id='icon-picker-rows']").click
    assert_selector "#icon-picker-rows[aria-hidden='false']"

    find("#icon-cell-inbox").click
    assert_selector "#icon-cell-inbox_panel:not(.hidden)"

    box = page.evaluate_script(<<~JS)
      (() => {
        const panel = document.querySelector("#icon-cell-inbox_panel")
        const cell = document.querySelector("#icon-cell-inbox")
        const rect = panel.getBoundingClientRect()
        const cellRect = cell.getBoundingClientRect()
        return {
          parentIsBody: panel.parentElement === document.body,
          position: getComputedStyle(panel).position,
          top: rect.top,
          left: rect.left,
          right: rect.right,
          bottom: rect.bottom,
          width: rect.width,
          cellWidth: cellRect.width,
          viewportWidth: window.innerWidth,
          viewportHeight: window.innerHeight
        }
      })()
    JS

    assert box["parentIsBody"]
    assert_equal "fixed", box["position"]
    assert_operator box["top"], :>=, 0
    assert_operator box["left"], :>=, 0
    assert_operator box["right"], :<=, box["viewportWidth"] + 1
    assert_operator box["bottom"], :<=, box["viewportHeight"] + 1
    assert_operator box["width"], :>, box["cellWidth"]
    assert_operator box["width"], :>=, 280
  end

  private

  def grid_buttons
    page.evaluate_script("document.querySelectorAll('#icon-field_panel [data-icon-name]').length")
  end
end
