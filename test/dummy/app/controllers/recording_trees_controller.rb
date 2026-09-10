# frozen_string_literal: true

class RecordingTreesController < ApplicationController
  layout "flat_pack_sidebar"

  def index
    recordings = RecordingStudio::Recording.unscoped
      .includes(:recordable)
      .reorder(created_at: :asc, id: :asc)
      .to_a

    @recording_count = recordings.size
    @recording_children = recordings.group_by(&:parent_recording_id)
    @root_recordings = Array(@recording_children[nil])
    @viewer_roles_by_recording_id = viewer_roles_by_recording_id(recordings)
  end

  private

  def viewer_roles_by_recording_id(recordings)
    return {} unless defined?(RecordingStudioAccessible)
    return {} unless current_user

    recordings.each_with_object({}) do |recording, roles|
      next if access_recordable?(recording)

      role = RecordingStudioAccessible.role_for(actor: current_user, recording: recording)
      roles[recording.id] = role.to_s if role.present?
    end
  end

  def access_recordable?(recording)
    type = recording.recordable_type.to_s
    type.end_with?("Access") || type.end_with?("AccessBoundary")
  end
end
