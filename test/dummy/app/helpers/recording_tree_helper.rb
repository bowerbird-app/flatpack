# frozen_string_literal: true

module RecordingTreeHelper
  def build_recording_tree_nodes(tree, recordings, recording_children, viewer_roles_by_recording_id: {})
    recordings.each do |recording|
      children = Array(recording_children[recording.id])
      meta = viewer_roles_by_recording_id[recording.id]

      tree.node(
        label: recording_tree_label(recording),
        icon: recording_tree_icon(recording),
        expanded: children.any?,
        meta: meta.present? ? "your role: #{meta}" : nil
      ) do |branch|
        build_recording_tree_nodes(
          branch,
          children,
          recording_children,
          viewer_roles_by_recording_id: viewer_roles_by_recording_id
        )
      end
    end
  end

  def recording_tree_icon(recording)
    case recording.recordable_type.to_s.demodulize
    when "Access", "AccessBoundary"
      :lock
    when "Workspace"
      :home
    when "Folder"
      :folder
    when "Page"
      "document-text"
    when "AdminRoot"
      :dashboard
    when "SiteSetting"
      :settings
    when "ApiClient", "ApiCredential", "ApiAccessToken"
      :key
    else
      :box
    end
  end

  def recording_tree_label(recording)
    type = recording.recordable_type.to_s.demodulize
    "#{type}: #{recording_tree_identifier(recording)}"
  end

  def recording_tree_identifier(recording)
    recordable = recording.recordable
    return "missing recordable" if recordable.nil?

    if access_like?(recording)
      return access_tree_identifier(recordable)
    end

    %i[name title email label slug identifier].each do |attribute|
      next unless recordable.respond_to?(attribute)

      value = recordable.public_send(attribute)
      return value if value.present?
    end

    "##{recordable.id}"
  end

  private

  def access_like?(recording)
    type = recording.recordable_type.to_s.demodulize
    type == "Access" || type == "AccessBoundary"
  end

  def access_tree_identifier(recordable)
    role = recordable.try(:role).presence || recordable.try(:minimum_role).presence
    actor = recordable.try(:actor)
    actor_label =
      if actor.respond_to?(:email) && actor.email.present?
        actor.email
      elsif actor.respond_to?(:name) && actor.name.present?
        actor.name
      elsif actor
        actor.class.name.demodulize
      end

    parts = []
    parts << role.to_s.humanize if role.present?
    parts << "for #{actor_label}" if actor_label.present?
    return parts.join(" ") if parts.any?

    "##{recordable.id}"
  end
end
