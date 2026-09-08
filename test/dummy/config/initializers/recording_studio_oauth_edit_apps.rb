# frozen_string_literal: true

return unless defined?(RecordingStudioOauth) && defined?(RecordingStudioAdmin)

# Host overlay: edit name + redirect URLs on Registered apps.
# recording_studio_oauth v0.1.0 only ships new/create/show/revoke.

module RecordingStudioOauth
  module Admin
    def edit_oauth_client_path(client)
      Engine.routes.url_helpers.edit_admin_oauth_client_path(client, script_name: engine_mount_path)
    end
    module_function :edit_oauth_client_path
  end
end

module DummyOauthClientEditActions
  extend ActiveSupport::Concern

  UPDATED_NOTICE = "App updated."

  included do
    before_action :authorize_edit_resource!, only: %i[edit update]
  end

  def edit
    @oauth_client = RecordingStudioOauth::OauthClient.find(params[:id])
    return head :forbidden if @oauth_client.revoked?
  end

  def update
    @oauth_client = RecordingStudioOauth::OauthClient.find(params[:id])
    return head :forbidden if @oauth_client.revoked?

    saved = perform_recording_studio_admin_action!(
      "oauth_clients",
      :edit,
      @oauth_client,
      audit_action: :update
    ) { update_oauth_client_saved? }

    if saved
      redirect_to oauth_clients_admin_screen_path, notice: UPDATED_NOTICE
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def authorize_edit_resource!
    RecordingStudioAdmin.authorize_resource!(
      key: "oauth_clients",
      action: :edit,
      context: recording_studio_admin_context,
      record: RecordingStudioOauth::OauthClient.find(params[:id])
    )
  rescue RecordingStudioAdmin::AuthorizationFailed, RecordingStudioAdmin::DefinitionNotFound
    head :forbidden
  end

  def update_oauth_client_saved?
    result = UpdateOauthClient.call(
      client: @oauth_client,
      name: oauth_client_update_params[:name],
      redirect_uris: UpdateOauthClient.redirect_uris_from_lines(oauth_client_update_params[:redirect_uris])
    )
    return true if result.success?

    @oauth_client.errors.add(:base, result.error) if @oauth_client.errors.empty?
    false
  end

  def oauth_client_update_params
    params.fetch(:oauth_client, {}).permit(:name, :redirect_uris)
  end
end

Rails.application.config.to_prepare do
  controller = RecordingStudioOauth::Admin::OauthClientsController
  unless controller.included_modules.include?(DummyOauthClientEditActions)
    controller.include(DummyOauthClientEditActions)
  end

  resource = RecordingStudioOauth::Admin::OauthClientsResource
  unless resource.action_for(:edit)
    resource.action(
      :edit,
      text: "Edit",
      method: :get,
      url: ->(row, _context) { RecordingStudioOauth::Admin.edit_oauth_client_path(row) },
      required_role: :view,
      visible_if: ->(row, _context) { row.revoked_at.nil? },
      blast_radius: :site
    )
  end

  table = RecordingStudioOauth::Admin::OauthClientsScreen.table_value
  next unless table
  next if table.actions.any? { |action| action.respond_to?(:name) && action.name == :edit }

  edit_action = RecordingStudioAdmin::RowActionDefinition.new(
    :edit,
    "Edit",
    ->(row, _context) { RecordingStudioOauth::Admin.edit_oauth_client_path(row) },
    nil,
    :get,
    nil,
    false,
    ->(row, _context) { row.revoked_at.nil? },
    RecordingStudioAdmin::BlastRadius.normalize(:site, owner: "Table action :edit")
  )
  table.actions.unshift(edit_action)
end
