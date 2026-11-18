# frozen_string_literal: true

require "test_helper"

class HeroiconsServerRenderTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "red dot bell is in the HTML and the heroicons script is not requested" do
    visit "/demo/red_dot"

    assert_heroicon "bell", selector: "svg.fp-red-dot"
    assert_selector "svg.fp-red-dot circle.fp-red-dot-indicator"

    urls = page.evaluate_script("performance.getEntriesByType('resource').map((entry) => entry.name)")
    refute urls.any? { |url| url.to_s.include?("heroicons") }, urls.grep(/heroicon/i).inspect
  end
end
