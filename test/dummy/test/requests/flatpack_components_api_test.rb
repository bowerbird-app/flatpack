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

  test "tree recordable routes are not registered" do
    get "/recording_studio_api/api/v1/workspaces", headers: authorization_headers
    assert_response :not_found

    get "/recording_studio_api/api/v1/folders", headers: authorization_headers
    assert_response :not_found

    get "/recording_studio_api/api/v1/pages", headers: authorization_headers
    assert_response :not_found
  end

  test "MCP type catalog has no Workspace Folder or Page" do
    skip "Recording Studio MCP not in this bundle" unless defined?(RecordingStudioMcp)

    catalog = RecordingStudioMcp::Catalog.new(api: "public")

    assert_empty catalog.type_names
    assert_empty RecordingStudioApi.api_recordable_types(api: "public")
  end

  test "MCP tool surface lists catalog endpoints without tree tools" do
    skip "Recording Studio MCP not in this bundle" unless defined?(RecordingStudioMcp)

    surface = RecordingStudioMcp::ToolSurface.for(api: "public")
    names = surface.tool_names

    assert surface.endpoints_enabled?
    refute surface.tree_enabled?
    assert_includes names, "flatpack_components"
    assert_includes names, "flatpack_component"
    refute_includes names, "list"
    refute_includes names, "describe"
  end

  test "MCP pin and instructions_suffix guide FlatPack screen building" do
    skip "Recording Studio MCP not in this bundle" unless defined?(RecordingStudioMcp)

    assert_equal "0.3.1", RecordingStudioMcp::VERSION
    assert_equal "0.3.1", Gem.loaded_specs.fetch("recording_studio_mcp").version.to_s

    suffix = RecordingStudioMcp.configuration.instructions_suffix
    suffix_text = suffix.respond_to?(:call) ? suffix.call : suffix.to_s

    assert_includes suffix_text, "FlatPack"
    assert_includes suffix_text, "flatpack_components"
    assert_includes suffix_text, "flatpack_component"

    instructions = RecordingStudioMcp::Instructions.text
    assert_includes instructions, suffix_text
  end

  test "OpenAPI lists the catalog under Endpoints and omits tree resources" do
    document = RecordingStudioApi::Services::OpenapiDocument.call
    paths = document.fetch(:paths)
    list = paths.fetch("/recording_studio_api/api/v1/flatpack/components").fetch("get")

    assert_equal ["Endpoints"], list.fetch(:tags)
    assert paths.key?("/recording_studio_api/api/v1/flatpack/components/{name}")
    refute paths.key?("/recording_studio_api/api/v1/workspaces")
    refute paths.key?("/recording_studio_api/api/v1/folders")
    refute paths.key?("/recording_studio_api/api/v1/pages")
    assert_equal "FlatPack Component Catalog", document.fetch(:info).fetch(:title)
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
