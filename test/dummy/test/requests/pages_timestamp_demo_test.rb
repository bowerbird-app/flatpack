# frozen_string_literal: true

require "test_helper"
require "time"

class PagesTimestampDemoTest < ActionDispatch::IntegrationTest
  test "timestamp page renders relative and fallback examples" do
    get demo_timestamp_path

    assert_response :success
    assert_includes response.body, "Timestamp Component"
    assert_includes response.body, "Relative Time Labels"
    assert_includes response.body, "Fixed UTC date (2016-01-01 00:00 +0000 GMT)"
    assert_includes response.body, "class_name example"
    assert_includes response.body, "text-green-600"
    assert_includes response.body, "text-xs"
    assert_includes response.body, "2016-01-01T00:00:00Z"
    assert_includes response.body, "UTC (+0) To Local Time Example"
    assert_includes response.body, "Original timestamp (+0, 7 hours in future):"

    iso_match = response.body.match(/data-timestamp-timezone-demo-iso-value=\"([^\"]+)\"/)
    refute_nil iso_match

    demo_time_utc = Time.iso8601(iso_match[1])
    delta_seconds = demo_time_utc - Time.current.utc

    assert_operator delta_seconds, :>=, 6.hours
    assert_operator delta_seconds, :<=, 8.hours
    assert_includes response.body, "(UTC)"
    assert_includes response.body, "data-controller=\"timestamp-timezone-demo\""
    assert_includes response.body, "Fallback Rendering"
    assert_includes response.body, "data-controller=\"flat-pack--timestamp\""
    assert_includes response.body, "Unavailable"
  end
end
