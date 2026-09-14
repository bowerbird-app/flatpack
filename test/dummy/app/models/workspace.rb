# frozen_string_literal: true

class Workspace < ApplicationRecord
  if defined?(RecordingStudio)
    recording_studio_recordable label: "Workspace", root: true
    validates :name, presence: true
    RecordingStudio.enable_capability(:accessible, on: self) if defined?(RecordingStudioAccessible)
    RecordingStudio.enable_capability(:api_access_point, on: self) if defined?(RecordingStudioApi)
  end
end
