# frozen_string_literal: true

class StudioController < ApplicationController
  def index
    return unless defined?(RecordingStudioOauth)

    @authorizations = RecordingStudioOauth::OauthAuthorization
      .includes(:oauth_client, :access_recording)
      .where(manager_actor: current_user)
      .order(created_at: :desc)
  end

  helper_method :connected_app_status

  private

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
