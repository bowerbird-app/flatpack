# frozen_string_literal: true

require "test_helper"
require "securerandom"

class FlatpackComponentsApiTest < ActionDispatch::IntegrationTest
  setup do
    skip "Recording Studio API not in this bundle" unless defined?(RecordingStudioApi)

    @user = User.find_or_create_by!(email: "catalog-api@example.com") do |record|
      record.password = "Password123!"
      record.password_confirmation = "Password123!"
    end
    Current.actor = @user

    workspace = Workspace.find_or_create_by!(name: "Catalog API Workspace")
    @workspace_root = RecordingStudio.root_recording_for(workspace)
    @access = grant_or_bootstrap_access!(recording: @workspace_root, actor: @user, role: :admin)
    @page_title = "Catalog Getting Started"
    ensure_page!(title: @page_title, root_recording: @workspace_root)
    @access_token = issue_catalog_access_token
  end

  teardown do
    Current.actor = nil if defined?(Current)
  end

  test "authenticated list returns skinny records and meta.count" do
    get "/recording_studio_api/api/v1/flatpack/components", headers: authorization_headers

    assert_response :success
    payload = JSON.parse(response.body)
    records = payload.fetch("records")

    assert_equal records.size, payload.fetch("meta").fetch("count")
    assert(records.any? { |row| row.fetch("name") == "Button::Component" })
    records.each do |row|
      assert_equal %w[name class description category], row.keys
    end
  end

  test "authenticated show Button includes parameters" do
    get "/recording_studio_api/api/v1/flatpack/components/Button--Component", headers: authorization_headers

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "Button::Component", payload.fetch("name")
    assert(payload.fetch("parameters").any? { |parameter| parameter.fetch("name") == "style" })
  end

  test "unauthenticated list is unauthorized" do
    get "/recording_studio_api/api/v1/flatpack/components"

    assert_response :unauthorized
  end

  test "unknown component is not found" do
    get "/recording_studio_api/api/v1/flatpack/components/nope", headers: authorization_headers

    assert_response :not_found
    assert_equal "not_found", JSON.parse(response.body).dig("error", "code")
  end

  test "pages index still lists workspace pages" do
    get "/recording_studio_api/api/v1/pages", headers: authorization_headers

    assert_response :success
    titles = JSON.parse(response.body).fetch("records").map { |row| row["title"] }
    assert_includes titles, @page_title
  end

  test "OpenAPI lists the catalog under Endpoints" do
    document = RecordingStudioApi::Services::OpenapiDocument.call
    list = document.fetch(:paths).fetch("/recording_studio_api/api/v1/flatpack/components").fetch("get")

    assert_equal ["Endpoints"], list.fetch(:tags)
    assert document.fetch(:paths).key?("/recording_studio_api/api/v1/flatpack/components/{name}")
  end

  private

  def authorization_headers
    {"Authorization" => "Bearer #{@access_token}"}
  end

  def issue_catalog_access_token
    provision = RecordingStudioApi::Services::ProvisionApiClient.call(
      access_recording: @access,
      name: "Catalog API client #{SecureRandom.hex(4)}"
    )
    raise provision.error unless provision.success?

    payload = provision.value
    token = RecordingStudioApi::Services::IssueOauthAccessToken.call(
      grant_type: "client_credentials",
      client_id: payload.fetch(:credential).oauth_client_id,
      client_secret: payload.fetch(:token)
    )
    raise token.error unless token.success?

    token.value.fetch(:access_token)
  end

  def ensure_page!(title:, root_recording:)
    page = Page.find_or_create_by!(title: title)
    existing = RecordingStudio::Recording.find_by(recordable: page, root_recording: root_recording, trashed_at: nil)
    return existing if existing.present?

    folder = Folder.find_or_create_by!(name: "Catalog API Folder")
    folder_recording = RecordingStudio::Recording.find_by(recordable: folder, root_recording: root_recording, trashed_at: nil) ||
      RecordingStudio.record!(
        action: "created",
        recordable: folder,
        root_recording: root_recording,
        parent_recording: root_recording
      ).recording

    RecordingStudio.record!(
      action: "created",
      recordable: page,
      root_recording: root_recording,
      parent_recording: folder_recording
    ).recording
  end

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
