# frozen_string_literal: true

module FlatPack
  module LightboxHelper
    def flat_pack_lightbox_trigger(group:, index: 0, **system_arguments, &block)
      render(FlatPack::Lightbox::Trigger.new(group: group, index: index, **system_arguments), &block)
    end
  end
end
