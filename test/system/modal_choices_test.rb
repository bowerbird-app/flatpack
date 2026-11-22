# frozen_string_literal: true

require "test_helper"

class ModalChoicesTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "font swatch inside a modal is visible, clickable, and updates the font" do
    visit "/demo/modals"
    find("[data-modal-id='style-choices']").click
    assert_selector "#style-choices[aria-hidden='false']"

    page.evaluate_async_script("const done = arguments[0]; setTimeout(done, 450)")

    dialog = dialog_metrics
    find("#style-font").click
    assert_selector "#style-choices [role='listbox']"

    hit = option_hit("ui-serif")
    assert_operator hit["width"], :>, 0, hit.inspect
    assert_operator hit["height"], :>, 0, hit.inspect
    assert hit["hitOption"], {dialog: dialog, hit: hit}.inspect
    assert_operator(hit["top"], :>, dialog["top"] - 4)
    assert_equal "", dialog["inlineScale"], dialog.inspect
    assert_equal "none", dialog["computedScale"], dialog.inspect

    find("#style-choices [role='option'][data-value='ui-serif']").click

    assert_equal "ui-serif", find("input[name='style[font]']", visible: :all).value
  end

  test "icon picker inside the same modal opens under its trigger" do
    visit "/demo/modals"
    find("[data-modal-id='style-choices']").click
    assert_selector "#style-choices[aria-hidden='false']"
    page.evaluate_async_script("const done = arguments[0]; setTimeout(done, 450)")

    find("#style-icon").click
    assert_selector "#style-icon_panel:not(.hidden)"

    box = page.evaluate_script(<<~JS)
      (() => {
        const panel = document.querySelector("#style-icon_panel")
        const trigger = document.querySelector("#style-icon")
        const rect = panel.getBoundingClientRect()
        const triggerRect = trigger.getBoundingClientRect()
        const heart = panel.querySelector("[data-icon-name='heart']")
        const heartRect = heart.getBoundingClientRect()
        const top = document.elementFromPoint(heartRect.left + 4, heartRect.top + 4)
        return {
          parentIsBody: panel.parentElement === document.body,
          position: getComputedStyle(panel).position,
          top: rect.top,
          left: rect.left,
          width: rect.width,
          height: rect.height,
          triggerBottom: triggerRect.bottom,
          hitHeart: Boolean(top && heart.contains(top))
        }
      })()
    JS

    assert box["parentIsBody"]
    assert_equal "fixed", box["position"]
    assert_operator box["width"], :>, 0
    assert_operator box["height"], :>, 0
    assert_operator box["top"], :>=, box["triggerBottom"] - 2
    assert box["hitHeart"], box.inspect

    find("#style-icon_panel [data-icon-name='heart']").click
    assert_equal "heart", find("#style-icon_value", visible: :all).value
  end

  private

  def dialog_metrics
    page.evaluate_script(<<~JS)
      (() => {
        const dialog = document.querySelector("#style-choices [role='dialog']")
        const rect = dialog.getBoundingClientRect()
        const computed = getComputedStyle(dialog)
        return {
          inlineScale: dialog.style.scale,
          computedScale: computed.scale,
          transform: computed.transform,
          top: rect.top,
          bottom: rect.bottom,
          left: rect.left,
          right: rect.right
        }
      })()
    JS
  end

  def option_hit(value)
    page.evaluate_script(<<~JS, value)
      (() => {
        const option = document.querySelector(`#style-choices [role='option'][data-value='${arguments[0]}']`)
        const rect = option.getBoundingClientRect()
        const x = rect.left + (rect.width / 2)
        const y = rect.top + (rect.height / 2)
        const top = document.elementFromPoint(x, y)
        return {
          width: rect.width,
          height: rect.height,
          top: rect.top,
          left: rect.left,
          x,
          y,
          hitOption: Boolean(top && (top === option || option.contains(top))),
          hitTag: top ? top.tagName : null,
          hitRole: top ? top.getAttribute("role") : null
        }
      })()
    JS
  end
end
