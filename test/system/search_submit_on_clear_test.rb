# frozen_string_literal: true

require "test_helper"
require "uri"
require "rack/utils"

class SearchSubmitOnClearTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "clearing a flagged search submits the GET form with an empty q" do
    visit "/demo/search?q=lamps#submit-on-clear"

    within "#submit-on-clear-on-form" do
      assert_field "q", with: "lamps"
      find("button[aria-label='Clear search']").click
    end

    assert_text "Showing every page."
    assert_equal "", query_param("q")
    within "#submit-on-clear-on-form" do
      assert_field "q", with: ""
    end
  end

  test "clearing without the flag does not submit" do
    visit "/demo/search?q=lamps#submit-on-clear"

    within "#submit-on-clear-off-form" do
      assert_field "stay", with: "lamps"
      find("button[aria-label='Clear search']").click
      assert_field "stay", with: ""
    end

    assert_equal "lamps", query_param("q")
    assert_nil query_param("stay")
    assert_text "Showing matches for lamps."
  end

  private

  def query_param(name)
    query = URI.parse(page.current_url).query
    return nil if query.blank?

    Rack::Utils.parse_query(query)[name]
  end
end
