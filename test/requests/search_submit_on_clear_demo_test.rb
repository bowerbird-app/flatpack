# frozen_string_literal: true

require "test_helper"

class SearchSubmitOnClearDemoTest < ActionDispatch::IntegrationTest
  test "search demo renders submit on clear only when the flag is on" do
    get "/demo/search", params: {q: "lamps"}

    assert_response :success
    assert_select "#submit-on-clear-on[data-flat-pack--search-input-submit-on-clear-value=true]"
    assert_select "#submit-on-clear-off-form #submit-on-clear-off"
    assert_select "#submit-on-clear-off[data-flat-pack--search-input-submit-on-clear-value]", count: 0
  end
end
