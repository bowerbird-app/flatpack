# frozen_string_literal: true

require "test_helper"

class RecordingStudioHostWiringTest < ActionDispatch::IntegrationTest
  test "public demo stays open without login" do
    get "/demo/buttons"
    assert_response :success
  end

  test "root demo stays open without login" do
    get "/"
    assert_response :success
  end

  test "mcp unauthenticated returns unauthorized" do
    skip "Recording Studio MCP not in this bundle" unless defined?(RecordingStudioMcp)

    post "/recording_studio_mcp",
      params: {jsonrpc: "2.0", id: 1, method: "initialize"}.to_json,
      headers: {"Content-Type" => "application/json", "Accept" => "application/json"}

    assert_response :unauthorized
  end

  test "users sign in page loads" do
    skip "Recording Studio Users not in this bundle" unless defined?(RecordingStudioUser)

    get "/users/sign_in"
    assert_response :success
  end

  test "admin requires authentication" do
    skip "Recording Studio Admin not in this bundle" unless defined?(RecordingStudioAdmin)

    get "/admin"
    assert_response :redirect
  end
end
