# frozen_string_literal: true

module Dummy
  FLATPACK_COMPOSE_WORKFLOW = <<~TEXT.squish.freeze
    This host is a FlatPack component catalog, not a recordings tree.
    Call flatpack_components to list, then flatpack_component with name for full params, before writing any screen ERB.
    Build UI only with public catalog FlatPack::…::Component. Do not use custom HTML, Tailwind utility dumps, or invented component names.
    Honor required params, types, enums, and known defaults from the detail payload.
    Prefer composing via the APIs and slots the detail payload describes, for example Card body or header when present. Do not invent a second design system.
    Show may include examples copied from component docs. Host helpers may appear as written.
  TEXT
end

return unless defined?(RecordingStudioApi)

RecordingStudioApi.configure do |config|
  config.openapi_title = "FlatPack Component Catalog"
  config.openapi_description = "Bearer JSON for public FlatPack ViewComponents. No Workspace, Folder, or Page tree API."
  config.documentation_enabled = true
  config.documentation_access = :public
  config.layout_name = "recording_studio/default_layout"
  config.admin_layout_name = "recording_studio/default_layout"
  config.rate_limit_oauth_enabled = false if config.respond_to?(:rate_limit_oauth_enabled=)
  config.rate_limit_api_pre_auth_enabled = false if config.respond_to?(:rate_limit_api_pre_auth_enabled=)
  config.rate_limit_api_enabled = false if config.respond_to?(:rate_limit_api_enabled=)
  config.api_request_logging_enabled = false if config.respond_to?(:api_request_logging_enabled=)
  config.api_management_authorization_required = false if config.respond_to?(:api_management_authorization_required=)
end

# Public API normally mirrors every RecordingStudio.recordable_type. This host is
# catalog-only: force the public resource list to the recordable registry (empty)
# plus register_endpoint routes. Access-point checks stay capability-based so
# Workspace can still host OAuth / API client credentials.
module Dummy
  module PublicApiRegistryOnly
    def api_recordable_types(api: :public)
      definition = configuration.fetch_api(api)
      return definition.recordable_registry.to_h.keys.map(&:to_s) if definition.equal?(configuration.public_api)

      super
    end

    def api_access_point_recordable_types(api: :public)
      definition = configuration.fetch_api(api)
      return super unless definition.equal?(configuration.public_api)
      return [] unless defined?(RecordingStudio) && RecordingStudio.respond_to?(:configuration)

      Array(RecordingStudio.configuration.recordable_types).map(&:to_s).uniq.select do |recordable_type|
        api_access_point_recordable_type?(recordable_type, api: api)
      end
    end

    def api_access_point_recordable_type?(recordable_type, api: :public)
      type_name = recordable_type.to_s
      return false if type_name.blank?
      return false unless defined?(RecordingStudio) && RecordingStudio.respond_to?(:capability_enabled?)

      RecordingStudio.capability_enabled?(:accessible, for: type_name) &&
        RecordingStudio.capability_enabled?(:api_access_point, for: type_name)
    end
  end
end

RecordingStudioApi.singleton_class.prepend(Dummy::PublicApiRegistryOnly)

RecordingStudioApi.register_endpoint(
  :flatpack_components,
  http_verb: :get,
  path: "flatpack/components",
  handler: ->(_context) { FlatPack::ComponentCatalog.list },
  openapi: {
    summary: "List public FlatPack components",
    description: "Skinny public catalog listing. #{Dummy::FLATPACK_COMPOSE_WORKFLOW}"
  }
)

RecordingStudioApi.register_endpoint(
  :flatpack_component,
  http_verb: :get,
  path: "flatpack/components/:name",
  handler: ->(context) {
    payload = FlatPack::ComponentCatalog.show(context.params[:name])
    raise RecordingStudioApi::NotFoundError, "Unknown component" if payload.nil?

    payload
  },
  openapi: {
    summary: "Show a FlatPack component",
    description: "One public component plus initialize parameters. #{Dummy::FLATPACK_COMPOSE_WORKFLOW}"
  }
)
