# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"

class AdminOauthAppsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    skip "Recording Studio Admin/OAuth not in this bundle" unless defined?(RecordingStudioAdmin) && defined?(RecordingStudioOauth)

    @user = User.find_or_create_by!(email: "admin-oauth-apps@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end

    @admin_root = AdminRoot.find_or_create_by!(name: "Admin")
    @admin_root_recording = RecordingStudio.root_recording_for(@admin_root)

    workspace = Workspace.find_or_create_by!(name: "Admin OAuth Workspace")
    @workspace_root = RecordingStudio.root_recording_for(workspace)

    grant_or_bootstrap_access!(recording: @admin_root_recording, actor: @user, role: :admin)
    grant_or_bootstrap_access!(recording: @workspace_root, actor: @user, role: :admin)

    RecordingStudioOauth::OauthClient.find_or_create_by!(name: "Seed MCP App") do |client|
      client.redirect_uris = ["http://127.0.0.1/callback"]
      client.confidential = false
      client.api_key = "public"
    end

    sign_in @user
    switch_to_root!(@workspace_root)
  end

  teardown do
    Current.actor = nil if defined?(Current)
  end

  test "oauth_apps is forbidden while current root is a workspace" do
    get "/admin/sections/oauth_apps"

    assert_response :forbidden
    assert_empty response.body
  end

  test "oauth_apps renders after switching to Admin root" do
    switch_to_root!(@admin_root_recording)

    get "/admin/sections/oauth_apps"

    assert_response :success
    assert_includes response.body, "Registered apps"
    assert_includes response.body, "Active connections"
    assert_includes response.body, "View apps"
  end

  test "root switcher lists Admin alongside workspaces" do
    get "/recording_studio_root_switchable/v1/root_switch", params: {scope: "all_workspaces"}

    assert_response :success
    assert_includes response.body, "Admin"
    assert_includes response.body, @workspace_root.recordable.name
  end

  test "studio Registered apps switches to Admin and opens oauth clients" do
    get "/studio"

    assert_response :success
    assert_includes response.body, "Registered apps"
    assert_includes response.body, @admin_root_recording.id.to_s
    assert_includes response.body, StudioController::REGISTERED_APPS_PATH

    patch recording_studio_root_switchable.root_switch_path(scope: "all_workspaces"), params: {
      root_switch: {
        root_recording_id: @admin_root_recording.id,
        return_to: StudioController::REGISTERED_APPS_PATH
      }
    }

    assert_redirected_to StudioController::REGISTERED_APPS_PATH
    follow_redirect!

    assert_response :success
    assert_includes response.body, "Registered apps"
    assert_includes response.body, "New app"
  end

  private

  def grant_or_bootstrap_access!(recording:, actor:, role:)
    existing = RecordingStudioAccessible.access_recordings_for_actor(
      recording: recording,
      actor: actor
    ).first
    return existing if existing.present?

    result = RecordingStudioAccessible.grant_access(
      recording: recording,
      actor: actor,
      role: role,
      manager_actor: actor
    )
    return result.value if result.success?

    bootstrap = RecordingStudioAccessible.bootstrap_owner_access!(
      recording: recording,
      actor: actor
    )
    raise bootstrap.error if bootstrap.failure?

    bootstrap.value
  end

  def switch_to_root!(root_recording)
    patch recording_studio_root_switchable.root_switch_path(scope: "all_workspaces"), params: {
      root_switch: {
        root_recording_id: root_recording.id,
        return_to: "/"
      }
    }
    follow_redirect! if response.redirect?
  end
end
