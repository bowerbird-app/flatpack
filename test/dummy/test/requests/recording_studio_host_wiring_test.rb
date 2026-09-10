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

  test "studio uses the Recording Studio host sidebar shell" do
    skip "Recording Studio Users not in this bundle" unless defined?(RecordingStudioUser)

    user = User.find_or_create_by!(email: "studio-sidebar@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end
    sign_in user

    get "/studio"
    assert_response :success
    assert_match(/aria-label="Main navigation"/, response.body)
    assert_match(/Connected apps/, response.body)
    assert_match(/Component demos/, response.body)
    assert_match(/Recording tree/, response.body)
    assert_match(%r{href="/studio/recording_tree"}, response.body)
    assert_match(/flatpack-dummy-studio-shell/, response.body)
    assert_match(/data-controller="flat-pack--sidebar-layout"/, response.body)
    refute_match(/My profile/, response.body)
    refute_match(/FlatPack Demo Components/, response.body)
    refute_match(/Search demo pages/, response.body)
  end

  test "recording tree shows access grants and viewer roles" do
    skip "Recording Studio Accessible not in this bundle" unless defined?(RecordingStudioAccessible)

    user = User.find_or_create_by!(email: "recording-tree@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end

    workspace = Workspace.find_or_create_by!(name: "Recording Tree Workspace")
    root = RecordingStudio.root_recording_for(workspace)
    folder = Folder.find_or_create_by!(name: "Tree Folder")
    folder_recording = RecordingStudio::Recording.find_by(
      root_recording: root,
      parent_recording: root,
      recordable: folder,
      trashed_at: nil
    ) || RecordingStudio.record!(
      action: "created",
      recordable: folder,
      root_recording: root,
      parent_recording: root
    ).recording

    Current.actor = user
    access = RecordingStudioAccessible.access_recordings_for_actor(recording: root, actor: user).first
    if access.blank?
      result = RecordingStudioAccessible.grant_access(
        recording: root,
        actor: user,
        role: :admin,
        manager_actor: user
      )
      if result.failure?
        bootstrap = RecordingStudioAccessible.bootstrap_owner_access!(recording: root, actor: user)
        raise bootstrap.error if bootstrap.failure?
      end
    end
    unless RecordingStudioAccessible.access_recordings_for_actor(recording: folder_recording, actor: user).any?
      RecordingStudioAccessible.grant_access(
        recording: folder_recording,
        actor: user,
        role: :edit,
        manager_actor: user
      )
    end

    sign_in user

    get studio_recording_tree_path
    assert_response :success
    assert_match(/Recording tree/, response.body)
    assert_match(/Recording Tree Workspace/, response.body)
    assert_match(/Access:/, response.body)
    assert_match(/recording-tree@example.com/, response.body)
    assert_match(/your role:/, response.body)
    assert_match(/flatpack-dummy-studio-shell/, response.body)
  ensure
    Current.actor = nil if defined?(Current)
  end
end
