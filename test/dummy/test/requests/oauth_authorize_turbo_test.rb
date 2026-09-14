# frozen_string_literal: true

require "test_helper"
require "devise/test/integration_helpers"
require "digest"
require "securerandom"
require "base64"

class OauthAuthorizeTurboTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    skip "Recording Studio OAuth not in this bundle" unless defined?(RecordingStudioOauth)

    @user = User.find_or_create_by!(email: "oauth-turbo@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end

    workspace = Workspace.find_or_create_by!(name: "OAuth Turbo Workspace")
    @workspace_root = RecordingStudio.root_recording_for(workspace)
    grant_or_bootstrap_access!(recording: @workspace_root, actor: @user, role: :admin)

    @access = RecordingStudioAccessible.access_recordings_for_actor(
      recording: @workspace_root,
      actor: @user
    ).first
    raise "missing access recording" if @access.blank?

    @client = RecordingStudioOauth::OauthClient.find_or_create_by!(name: "Turbo Redirect App") do |client|
      client.redirect_uris = ["https://chatgpt.com/connector/oauth/test-callback"]
      client.confidential = false
      client.api_key = "public"
    end

    sign_in @user
  end

  teardown do
    Current.actor = nil if defined?(Current)
  end

  test "authorize consent form disables Turbo so OAuth redirects leave the host" do
    verifier = Base64.urlsafe_encode64(SecureRandom.random_bytes(32), padding: false)
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)

    get "/recording_studio_oauth/oauth/authorize", params: {
      response_type: "code",
      client_id: @client.client_id,
      redirect_uri: @client.redirect_uris.first,
      code_challenge: challenge,
      code_challenge_method: "S256",
      access_recording_id: @access.id,
      state: "oauth-turbo-state"
    }

    assert_response :success
    assert_includes response.body, 'data-turbo="false"'
    assert_match(/data-turbo="false"|data-turbo='false'/, response.body)
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
end
