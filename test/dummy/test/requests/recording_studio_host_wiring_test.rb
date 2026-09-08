# frozen_string_literal: true

require "test_helper"

class RecordingStudioHostWiringTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers if defined?(Devise::Test::IntegrationHelpers)
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

  test "studio requires authentication" do
    skip "Recording Studio Users not in this bundle" unless defined?(RecordingStudioUser)

    get "/studio"
    assert_response :redirect
  end

  test "users auth after sign in path is studio" do
    skip "Recording Studio Users not in this bundle" unless defined?(RecordingStudioUser)

    controller = RecordingStudioUser::Auth::SessionsController.new
    def controller.main_app
      Rails.application.routes.url_helpers
    end

    def controller.stored_location_for(_resource)
      nil
    end

    assert_equal "/studio", controller.after_sign_in_path_for(User.new)
  end

  test "studio shows connected apps empty state when signed in" do
    skip "Recording Studio OAuth not in this bundle" unless defined?(RecordingStudioOauth)

    user = User.find_or_create_by!(email: "studio-empty@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end
    sign_in user

    get "/studio"
    assert_response :success
    assert_match(/Nothing connected yet/, response.body)
    assert_match(/Registered apps/, response.body)
    assert_match(%r{/admin/screens/oauth_clients}, response.body)
  end
end
