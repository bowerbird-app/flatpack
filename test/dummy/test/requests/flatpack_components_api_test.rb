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
    meta = payload.fetch("meta")

    assert_equal records.size, meta.fetch("count")
    assert_equal FlatPack::VERSION, meta.fetch("gem_version")
    assert_equal "public", meta.fetch("publicity").fetch("scope")
    excludes = meta.fetch("publicity").fetch("excludes")
    assert_includes excludes, "FlatPack::BaseComponent"
    assert_includes excludes, "FlatPack::Shared::*"
    assert_includes excludes, "FlatPack::FormField::Component"
    assert(records.any? { |row| row.fetch("name") == "Button::Component" })
    records.each do |row|
      assert_equal %w[name class description category], row.keys
    end
  end

  test "authenticated show Button includes parameters and empty slots" do
    get "/recording_studio_api/api/v1/flatpack/components/Button--Component", headers: authorization_headers

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "Button::Component", payload.fetch("name")
    style = payload.fetch("parameters").find { |parameter| parameter.fetch("name") == "style" }
    text = payload.fetch("parameters").find { |parameter| parameter.fetch("name") == "text" }
    system_arguments = payload.fetch("parameters").find { |parameter| parameter.fetch("name") == "system_arguments" }

    assert style
    assert_equal "default", style.fetch("default")
    assert text.key?("default")
    assert_nil text.fetch("default")
    refute system_arguments.key?("default")
    assert_equal [], payload.fetch("slots")
  end

  test "authenticated show Card includes public slot names" do
    get "/recording_studio_api/api/v1/flatpack/components/Card--Component", headers: authorization_headers

    assert_response :success
    payload = JSON.parse(response.body)
    slots = payload.fetch("slots")

    assert_equal "Card::Component", payload.fetch("name")
    assert_equal(
      [
        {"name" => "body", "collection" => false},
        {"name" => "footer", "collection" => false},
        {"name" => "header", "collection" => false},
        {"name" => "media", "collection" => false}
      ],
      slots
    )
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

    assert_equal Dummy::FLATPACK_COMPOSE_WORKFLOW, suffix_text
    assert_compose_workflow suffix_text

    instructions = RecordingStudioMcp::Instructions.text
    assert_includes instructions, suffix_text
  end

  test "OpenAPI catalog descriptions include the compose workflow" do
    document = RecordingStudioApi::Services::OpenapiDocument.call
    paths = document.fetch(:paths)
    list = paths.fetch("/recording_studio_api/api/v1/flatpack/components").fetch("get")
    show = paths.fetch("/recording_studio_api/api/v1/flatpack/components/{name}").fetch("get")
    list_description = operation_description(list)
    show_description = operation_description(show)

    assert_includes list_description, "Skinny public catalog listing"
    assert_includes show_description, "One public component plus initialize parameters"
    assert_includes list_description, Dummy::FLATPACK_COMPOSE_WORKFLOW
    assert_includes show_description, Dummy::FLATPACK_COMPOSE_WORKFLOW
    assert_compose_workflow list_description
    assert_compose_workflow show_description
  end

  test "MCP catalog tool descriptions include the compose workflow" do
    skip "Recording Studio MCP not in this bundle" unless defined?(RecordingStudioMcp)

    surface = RecordingStudioMcp::ToolSurface.for(api: "public")

    %w[flatpack_components flatpack_component].each do |name|
      description = RecordingStudioMcp::Tools.endpoint_tool(surface.endpoint_for(name)).fetch(:description)

      assert_includes description, Dummy::FLATPACK_COMPOSE_WORKFLOW
      assert_compose_workflow description
    end
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

  def operation_description(operation)
    operation[:description] || operation.fetch("description")
  end

  def assert_compose_workflow(text)
    haystack = text.to_s
    lowered = haystack.downcase

    assert_includes haystack, "catalog"
    assert_includes haystack, "not a recordings tree"
    assert_includes haystack, "flatpack_components"
    assert_includes haystack, "flatpack_component"
    assert_includes haystack, "before writing any screen ERB"
    assert_includes haystack, "FlatPack::"
    assert_includes haystack, "custom HTML"
    assert_includes haystack, "Tailwind"
    assert_includes haystack, "invented"
    assert_includes haystack, "required params"
    assert_includes haystack, "enums"
    assert_includes lowered, "do not invent a second design system"
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
