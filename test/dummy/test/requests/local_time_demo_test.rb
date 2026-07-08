# frozen_string_literal: true

require "test_helper"

class LocalTimeDemoTest < ActionDispatch::IntegrationTest
  test "local time demo page renders examples and fallback content" do
    get demo_local_time_path

    assert_response :success
    assert_includes response.body, "Local Time Demo"
    assert_includes response.body, "Local Time"
    assert_includes response.body, "Relative Time"
    assert_includes response.body, "Unshortened"
    assert_includes response.body, "Shortened"
    assert_includes response.body, "data-shorten-timestamp=\"true\""
    assert_includes response.body, "Invalid Or Missing Datetime"
    assert_includes response.body, "Fallback text should remain"
    assert_includes response.body, "Custom title should not be overwritten"
    assert_includes response.body, "Render UTC timestamps in local browser time"
    assert_match(/class="[^"]*local-time relative-time/, response.body)
  end
end
