# frozen_string_literal: true

return unless defined?(RecordingStudioMcp)

RecordingStudioMcp.configure do |config|
  config.oauth_protected_resource_path = "/.well-known/oauth-protected-resource"
  config.oauth_engine_mount_path = "/recording_studio_oauth"
  config.instructions_suffix = <<~TEXT.squish
    This host is a FlatPack component catalog, not a recordings tree.
    Call tool flatpack_components to list components, then flatpack_component
    with a name for full params, before writing any screen ERB.
    Build UI only with public catalog FlatPack ViewComponents
    (FlatPack::…::Component). Do not use custom HTML, Tailwind utility dumps,
    or invented component names. Honor each component’s required params,
    types, and allowed values from the detail payload. Prefer composing
    catalog components the way FlatPack dummy and docs do; do not invent a
    second design system.
  TEXT
end
