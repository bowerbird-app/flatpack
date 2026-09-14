# frozen_string_literal: true

class Page < ApplicationRecord
  if defined?(RecordingStudio)
    recording_studio_recordable label: "Page", root: false, allowed_parent_types: ["Workspace", "Folder"]
  end
end
