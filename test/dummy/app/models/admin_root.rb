# frozen_string_literal: true

class AdminRoot < ApplicationRecord
  if defined?(RecordingStudio) && defined?(RecordingStudioAdmin)
    include RecordingStudio::Recordable
    include RecordingStudioAdmin::AllowsAdminSections

    recording_studio_recordable label: "Admin", root: true, shared: false
    RecordingStudio.enable_capability(:accessible, on: self)

    recording_studio_admin_sections do
      section :root
      section :oauth_apps
    end
  end
end
