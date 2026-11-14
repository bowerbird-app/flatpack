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
    assert_includes response.body, "Not in the list?"
    assert_includes response.body, "data-flat-pack--combobox-search-params-value="
    assert_includes response.body, "map-pin"
    assert_includes response.body, "Add a place"
    assert_includes response.body, "id=\"place-lookup\""
  end

  test "combobox options endpoint returns matching json" do
    get "/demo/forms/combobox/options", params: {q: "mel"}, as: :json

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal(
      [{
        "label" => "Federation Square",
        "value" => "fed-square",
        "subtitle" => "Melbourne VIC",
        "data" => {"city" => "melbourne", "region" => "any"}
      }],
      payload["items"]
    )
  end

  test "combobox options endpoint keeps the region search param on each item" do
    get "/demo/forms/combobox/options", params: {q: "syd", region: "au"}, as: :json

    assert_response :success
    item = JSON.parse(response.body).fetch("items").first

    assert_equal "opera-house", item["value"]
    assert_equal({"city" => "sydney", "region" => "au"}, item["data"])
  end

  test "combobox options endpoint fails for the err query" do
    get "/demo/forms/combobox/options", params: {q: "err"}, as: :json

    assert_response :bad_gateway
  end

  test "combobox options endpoint is empty without a query" do
    get "/demo/forms/combobox/options", as: :json

    assert_response :success
    assert_equal [], JSON.parse(response.body)["items"]
  end
end
