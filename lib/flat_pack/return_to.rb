# frozen_string_literal: true

module FlatPack
  module ReturnTo
    extend ActiveSupport::Concern

    def self.origin_url(controller)
      raw = controller.params[:return_to]
      return if raw.blank?

      controller.url_from(raw)
    end

    def flat_pack_return_to
      ReturnTo.origin_url(self)
    end

    def redirect_to_return_to(fallback:)
      raise ArgumentError, "fallback is required" if fallback.blank?

      redirect_to(flat_pack_return_to.presence || fallback)
    end
  end
end
