# frozen_string_literal: true

require "test_helper"

class PagesListReorderTest < ActionDispatch::IntegrationTest
  test "accepts a single moved list item payload" do
    patch demo_list_reorder_path, params: {
      moving_recording_id: "2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11",
      target_position: 2
    }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal true, payload["ok"]
    assert_equal "2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11", payload["item"]["id"]
    assert_equal 2, payload["item"]["position"]
  end

  test "accepts put requests for the same payload" do
    put demo_list_reorder_path, params: {
      moving_recording_id: "44d7b3a8-9a16-4f34-8c7a-9f0c8cb2f3f2",
      target_position: 1
    }

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal true, payload["ok"]
    assert_equal "PUT", payload["method"]
    assert_equal "44d7b3a8-9a16-4f34-8c7a-9f0c8cb2f3f2", payload["item"]["id"]
    assert_equal 1, payload["item"]["position"]
  end

  test "rejects malformed payloads" do
    patch demo_list_reorder_path, params: {}

    assert_response :unprocessable_entity

    payload = JSON.parse(response.body)
    assert_equal false, payload["ok"]
    assert_match(/invalid list reorder payload/i, payload["error"])
  end
end
