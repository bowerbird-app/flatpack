# frozen_string_literal: true

require "test_helper"

class ComboboxTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)
  Capybara.default_max_wait_time = 5

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "arrow keys reach the empty action and the request keeps search params" do
    visit "/demo/forms/combobox#add-a-place"
    listen_for_combobox_events

    fill_in "place-lookup", with: "zzz"
    assert_selector "[data-demo-combobox='place'] [data-empty-action='true']", text: "Add a place"

    find("#place-lookup").send_keys(:arrow_down, :enter)

    detail = page.evaluate_script("window.__combobox.emptyAction")
    assert_equal "zzz", detail["query"]
    assert_equal "add-place", detail["value"]
    assert_equal "", find("input[name='new_place_id']", visible: :all).value
    assert_equal "zzz", find("#place-lookup").value

    query = page.evaluate_script("window.__combobox.queries.at(-1)")
    assert_includes query, "q=zzz"
    assert_includes query, "region=au"
  end

  test "a current remote response reports items and the chosen row keeps its data" do
    visit "/demo/forms/combobox#add-a-place"
    listen_for_combobox_events

    fill_in "place-lookup", with: "mel"
    assert_selector "[data-demo-combobox='place'] [role='option']", text: "Federation Square"

    detail = page.evaluate_script("window.__combobox.results")
    assert_equal "mel", detail["query"]
    assert_equal "fed-square", detail["items"][0]["value"]
    assert_equal "melbourne", detail["items"][0]["data"]["city"]
    assert_equal "au", detail["items"][0]["data"]["region"]
    assert_equal "fed-square", detail["payload"]["items"][0]["value"]
    assert_nil detail["meta"]

    find("[data-demo-combobox='place'] [role='option']", text: "Federation Square").click

    selected = page.evaluate_script("window.__combobox.selected")
    assert_equal "fed-square", selected["value"]
    assert_equal "Federation Square", selected["label"]
    assert_equal "melbourne", selected["data"]["city"]
    assert_equal "fed-square", find("input[name='new_place_id']", visible: :all).value
  end

  test "a failed search announces the error and still offers the empty action" do
    visit "/demo/forms/combobox#add-a-place"
    listen_for_combobox_events

    fill_in "place-lookup", with: "err"
    assert_selector "[data-demo-combobox='place'] [data-flat-pack--combobox-target='empty']", text: "Search failed"
    assert_selector "[data-demo-combobox='place'] [data-empty-action='true']", text: "Add a place"

    error = page.evaluate_script("window.__combobox.error")
    assert_equal 502, error["status"]
  end

  private

  def listen_for_combobox_events
    page.execute_script(<<~JS)
      window.__combobox = { queries: [], emptyAction: null, results: null, selected: null, error: null }
      const nativeFetch = window.fetch.bind(window)
      window.fetch = function(url, options) {
        window.__combobox.queries.push(String(url))
        return nativeFetch(url, options)
      }
      document.addEventListener("flat-pack:combobox:empty-action", (event) => {
        window.__combobox.emptyAction = event.detail
      })
      document.addEventListener("flat-pack:combobox:results", (event) => {
        window.__combobox.results = event.detail
      })
      document.addEventListener("flat-pack:combobox:selected", (event) => {
        window.__combobox.selected = event.detail
      })
      document.addEventListener("flat-pack:combobox:error", (event) => {
        window.__combobox.error = event.detail
      })
    JS
  end
end
