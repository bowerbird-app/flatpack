# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Modal
    class ScreenTest < ViewComponent::TestCase
      def test_renders_matching_turbo_frame_and_title
        render_inline(Screen.new(modal_id: "gallery-editor", title: "Edit image")) do
          "Caption field"
        end

        assert_selector "turbo-frame#gallery-editor-screen"
        assert_selector "[data-fp-screen][data-title='Edit image']"
        assert_text "Caption field"
        assert_equal Component.screen_frame_id("gallery-editor"), "gallery-editor-screen"
      end

      def test_renders_header_actions_and_footer_slots
        render_inline(Screen.new(modal_id: "gallery-editor", title: "Edit image")) do |screen|
          screen.header_actions { "Preview" }
          screen.footer { "Save" }
          "Body"
        end

        assert_selector "[data-fp-screen-header-actions]", text: "Preview"
        assert_selector "[data-fp-screen-footer]", text: "Save"
        assert_text "Body"
      end

      def test_helper_is_defined
        assert_includes FlatPack::ModalHelper.instance_methods, :flat_pack_modal_screen
      end

      def test_requires_modal_id_and_title
        assert_raises(ArgumentError) { Screen.new(title: "Gallery") }
        assert_raises(ArgumentError) { Screen.new(modal_id: "gallery-editor") }
      end
    end
  end
end
