# frozen_string_literal: true

module FlatPack
  module ModalHelper
    # Renders a navigable modal screen. The turbo-frame id is derived from `modal_id`
    # so it matches `FlatPack::Modal::Component` with `navigable: true`.
    def flat_pack_modal_screen(modal_id:, title:, **system_arguments, &block)
      render FlatPack::Modal::Screen.new(modal_id: modal_id, title: title, **system_arguments), &block
    end
  end
end
