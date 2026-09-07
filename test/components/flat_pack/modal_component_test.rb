# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Modal
    class ComponentTest < ViewComponent::TestCase
      def test_dialog_wrapper_uses_overlay_pad
        render_inline(Component.new(id: "invite-modal", title: "Invite member")) do |modal|
          modal.body { "Invite a collaborator to this workspace." }
        end

        html = page.native.to_html

        assert_includes html, "fp-overlay-pad"
        assert_includes html, "data-controller=\"flat-pack--modal\""
        assert_includes html, "overflow-y-auto"
        assert_includes html, "flat-pack-modal__body"
        assert_includes html, "fp-hit-target"
      end
    end
  end
end
