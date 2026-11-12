# frozen_string_literal: true

require "test_helper"

class FloatingFrameTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "the first open loads the iframe and later opens keep its state" do
    PagesController.floating_frame_page_hits = 0
    visit "/demo/floating_frame"

    assert_no_selector ".fp-floating-frame__mount iframe"
    assert_equal 0, PagesController.floating_frame_page_hits
    assert_equal "false", launcher[:"aria-expanded"]

    launcher.click

    assert_selector ".fp-floating-frame__panel[aria-hidden='false']"
    assert_nil find(".fp-floating-frame__panel")["aria-modal"]
    assert_equal "true", launcher[:"aria-expanded"]
    assert_equal "Close", active_label
    within_frame(find(".fp-floating-frame__mount iframe")) do
      assert_text "Notes"
      fill_in "Scratch", with: "kept"
    end
    assert_equal 1, PagesController.floating_frame_page_hits

    find("button[aria-label='Close']").click

    assert_equal "false", launcher[:"aria-expanded"]
    assert_equal "Open notes", active_label
    assert_selector ".fp-floating-frame__mount iframe", visible: :all

    launcher.click

    within_frame(find(".fp-floating-frame__mount iframe")) do
      assert_field "Scratch", with: "kept"
    end
    assert_equal 1, PagesController.floating_frame_page_hits
  end

  test "escape closes the panel and restores focus to the launcher" do
    visit "/demo/floating_frame"
    launcher.click
    assert_selector "button[aria-label='Close']"

    find("button[aria-label='Close']").send_keys(:escape)

    assert_equal "false", launcher[:"aria-expanded"]
    assert_equal "Open notes", active_label
    assert_selector ".fp-floating-frame__mount iframe", visible: :all
  end

  test "escape inside the framed page closes the panel and restores focus" do
    visit "/demo/floating_frame"
    launcher.click

    within_frame(find(".fp-floating-frame__mount iframe")) do
      find("#scratch").send_keys(:escape)
    end

    assert_equal "false", launcher[:"aria-expanded"]
    assert_equal "Open notes", active_label
  end

  test "clicking outside closes the panel without focusing the launcher" do
    visit "/demo/floating_frame"
    launcher.click
    assert_selector "button[aria-label='Close']:focus"
    assert_equal "Close", active_label

    find("h1", text: "Floating frame").click

    assert_equal "false", launcher[:"aria-expanded"]
    refute_equal launcher[:id], active_id
  end

  test "focus sentinels are absent from 640px up and after close" do
    with_window(640, 900) do
      visit "/demo/floating_frame"
      launcher.click

      assert_nil find(".fp-floating-frame__panel")["aria-modal"]
      assert_no_selector "[data-flat-pack-floating-frame-sentinel]", visible: :all

      find("button[aria-label='Close']").click
      assert_no_selector "[data-flat-pack-floating-frame-sentinel]", visible: :all
    end

    with_window(390, 844) do
      launcher.click
      assert_selector "[data-flat-pack-floating-frame-sentinel]", visible: :all, count: 2

      find("button[aria-label='Close']").click
      assert_no_selector "[data-flat-pack-floating-frame-sentinel]", visible: :all
    end
  end

  test "a narrow open panel is modal and wraps tab inside it" do
    with_window(390, 844) do
      visit "/demo/floating_frame"
      launcher.click

      panel = find(".fp-floating-frame__panel[aria-hidden='false']")
      assert_equal "true", panel["aria-modal"]

      within_frame(find(".fp-floating-frame__mount iframe")) do
        field = find("#scratch")
        field.click
        field.send_keys(:tab)
      end

      assert_equal "Close", active_label
      assert page.evaluate_script(<<~JS)
        document.querySelector(".fp-floating-frame__panel").contains(document.activeElement)
      JS
    end
  end

  test "a narrow opaque frame cannot tab out of the panel" do
    with_window(390, 844) do
      visit "/demo/floating_frame"
      launcher.click
      assert_selector ".fp-floating-frame__panel[aria-modal='true']"

      opaque = page.evaluate_async_script(<<~JS)
        const done = arguments[0]
        const frame = document.querySelector(".fp-floating-frame__mount iframe")
        const fresh = document.createElement("iframe")
        fresh.setAttribute("sandbox", "")
        fresh.title = frame.title
        frame.replaceWith(fresh)
        fresh.addEventListener("load", function() {
          done(fresh.contentDocument === null)
        }, { once: true })
        fresh.src = frame.getAttribute("src")
      JS
      assert opaque, "expected the strict sandbox to hide the frame document"

      frame = find(".fp-floating-frame__mount iframe")
      page.driver.browser.switch_to.frame(frame.native)
      page.driver.browser.execute_script(<<~JS)
        const nodes = document.querySelectorAll("a[href], button, input, select, textarea")
        const last = nodes[nodes.length - 1]
        if (last) last.focus()
      JS
      page.driver.browser.action.send_keys(:tab).perform
      page.driver.browser.switch_to.default_content

      assert_equal "Close", active_label
      assert page.evaluate_script(<<~JS)
        document.querySelector(".fp-floating-frame__panel").contains(document.activeElement)
      JS
    end
  end

  private

  def with_window(width, height)
    original = page.current_window.size
    page.current_window.resize_to(width, height)
    yield
  ensure
    page.current_window.resize_to(original[0], original[1]) if original
  end

  def active_id
    page.evaluate_script("document.activeElement && document.activeElement.id")
  end

  def launcher
    find("button[aria-label='Open notes']")
  end

  def active_label
    page.evaluate_script("document.activeElement && document.activeElement.getAttribute('aria-label')")
  end
end
