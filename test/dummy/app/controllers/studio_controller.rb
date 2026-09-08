# frozen_string_literal: true

class StudioController < ApplicationController
  REGISTERED_APPS_PATH = "/admin/screens/oauth_clients"

  def index
    @admin_root_recording = admin_root_recording
    @registered_apps_path = REGISTERED_APPS_PATH

    return unless defined?(RecordingStudioOauth)

    @authorizations = RecordingStudioOauth::OauthAuthorization
      .includes(:oauth_client, :access_recording)
      .where(manager_actor: current_user)
      .order(created_at: :desc)
  end

  helper_method :connected_app_status

  private

  def admin_root_recording
    return unless defined?(AdminRoot) && defined?(RecordingStudio)

    admin_root = AdminRoot.find_by(name: "Admin")
    return unless admin_root

    RecordingStudio.root_recording_for(admin_root)
  end

  def connected_app_status(authorization)
    workspace = authorization.workspace_recording&.recordable
    workspace_name = if workspace.respond_to?(:name) && workspace.name.present?
      workspace.name
    elsif workspace.respond_to?(:title) && workspace.title.present?
      workspace.title
    else
      "this place"
    end
    permission = authorization.role.to_s.humanize
    return "#{permission} on #{workspace_name} · removed" if authorization.revoked_at.present?

    "#{permission} on #{workspace_name}"
  end
end
