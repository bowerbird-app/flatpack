# frozen_string_literal: true

require "test_helper"

class LocalTimeDemoTest < ActionDispatch::IntegrationTest
  test "local time demo page renders examples and fallback content" do
    get local_time_demo_path

    assert_response :success
    assert_includes response.body, "Local Time Demo"
    assert_includes response.body, "Local Time"
    assert_includes response.body, "Relative Time"
    assert_includes response.body, "Invalid / Missing Datetime"
    assert_includes response.body, "Fallback text should remain"
    assert_includes response.body, "Custom title should not be overwritten"
    assert_includes response.body, "class=\"local-time relative-time\""
  end
end

