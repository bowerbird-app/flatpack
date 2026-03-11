# frozen_string_literal: true

module FlatPack
  class CkeditorAssetsController < ActionController::Base
    CKEDITOR_ROOT = FlatPack::Engine.root.join("app/assets/javascripts/flat_pack/ckeditor").expand_path.freeze

    skip_forgery_protection

    def show
      asset_path = safe_asset_path(params[:path])
      return head :not_found unless asset_path

      expires_in 1.year, public: true
      send_file asset_path, disposition: "inline", type: Rack::Mime.mime_type(asset_path.extname, "application/octet-stream")
    end

    private

    def safe_asset_path(requested_path)
      clean_path = requested_asset_path(requested_path)
      return if clean_path.blank?

      asset_path = CKEDITOR_ROOT.join(clean_path).expand_path
      return unless asset_path.to_s.start_with?("#{CKEDITOR_ROOT}/")
      return unless asset_path.file?

      asset_path
    end

    def requested_asset_path(requested_path)
      [requested_path.presence, params[:format].presence].compact.join(".").delete_prefix("/")
    end
  end
end
