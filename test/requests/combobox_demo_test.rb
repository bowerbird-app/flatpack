# frozen_string_literal: true

require "test_helper"

class ComboboxDemoTest < ActionDispatch::IntegrationTest
  test "combobox demo includes local and async fields" do
    get "/demo/forms/combobox"

    assert_response :success
    assert_includes response.body, "Filter and select"
    assert_includes response.body, "Type to fetch"
    assert_includes response.body, "data-flat-pack--combobox-search-mode-value=\"remote\""
    assert_includes response.body, "data-flat-pack--combobox-search-endpoint-value=\"/demo/forms/combobox/options\""
    assert_includes response.body, "spellcheck=\"false\""
    assert_includes response.body, "data-flat-pack--combobox-min-search-length-value=\"3\""
    assert_includes response.body, "data-flat-pack--combobox-debounce-value=\"300\""
  end

  test "combobox options endpoint returns matching json" do
    get "/demo/forms/combobox/options", params: {q: "mel"}, as: :json

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal(
      [{"label" => "Federation Square", "value" => "fed-square", "subtitle" => "Melbourne VIC"}],
      payload["items"]
    )
  end

  test "combobox options endpoint is empty without a query" do
    get "/demo/forms/combobox/options", as: :json

    assert_response :success
    assert_equal [], JSON.parse(response.body)["items"]
  end
end
