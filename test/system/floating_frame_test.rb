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

  private

  def launcher
    find("button[aria-label='Open notes']")
  end

  def active_label
    page.evaluate_script("document.activeElement && document.activeElement.getAttribute('aria-label')")
  end
end
