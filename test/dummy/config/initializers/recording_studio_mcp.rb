# frozen_string_literal: true

return unless defined?(RecordingStudioMcp)

RecordingStudioMcp.configure do |config|
  config.oauth_engine_mount_path = "/recording_studio_oauth"
  config.instructions_suffix = Dummy::FLATPACK_COMPOSE_WORKFLOW
end
