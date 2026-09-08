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
        assert_selector "[data-controller='flat-pack--modal'][data-action*='keydown.tab->flat-pack--modal#handleKeydown']"
        assert_selector "[data-flat-pack--modal-target='dialog'][tabindex='-1'][role='dialog']"
        assert_includes html, "overflow-y-auto"
        assert_includes html, "flat-pack-modal__body"
        assert_includes html, "fp-hit-target"
      end

      def test_tab_trap_stays_wired_when_escape_close_is_disabled
        render_inline(Component.new(id: "locked-modal", title: "Locked", close_on_escape: false)) do |modal|
          modal.body { "Tab still cycles inside the dialog." }
        end

        assert_selector "[data-controller='flat-pack--modal'][data-action='keydown.tab->flat-pack--modal#handleKeydown']"
        refute_selector "[data-action*='keydown.esc']"
      end
    end
  end
end
