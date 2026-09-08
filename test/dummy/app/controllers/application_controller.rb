# frozen_string_literal: true

class ApplicationController < ActionController::Base
  if defined?(RecordingStudio::RootSwitchable::ControllerSupport)
    include RecordingStudio::RootSwitchable::ControllerSupport
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :resolve_layout

  before_action :authenticate_user!, unless: :public_catalog_request?
  before_action :set_current_actor

  private

  # FlatPack component demos stay open. Recording Studio, Admin, OAuth Connect,
  # Users profile screens, API, and MCP stay gated by their own auth.
  def public_catalog_request?
    return true if devise_controller?

    path = request.path
    return true if path == "/" || path == "/up"
    return true if path.start_with?(
      "/demo",
      "/themes",
      "/pages/hero",
      "/mobile",
      "/flat_pack",
      "/assets",
      "/rails/active_storage",
      "/cable"
    )

    false
  end

  def resolve_layout
    return "application" if public_catalog_request?
    return "application" if devise_controller?
    return "application" unless defined?(RecordingStudio)

    "recording_studio/default_layout"
  end

  def set_current_actor
    Current.actor = current_user if defined?(Current)
  end
end
