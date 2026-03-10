# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module SentMessage
      class ComponentTest < ViewComponent::TestCase
        def test_renders_outgoing_message
          render_inline(Component.new(state: :sent)) do
            "Outgoing"
          end

          assert_selector "div[data-chat-message-state='sent']", text: "Outgoing"
          assert_includes rendered_content, "justify-end"
        end

        def test_renders_reveal_actions_when_enabled
          render_inline(Component.new(state: :read, reveal_actions: true, timestamp: Time.zone.parse("2026-02-26 10:18:00"))) do
            "Slide me"
          end

          assert_includes rendered_content, "chat-message-actions"
          assert_text "Edit"
          assert_text "Delete"
        end

        def test_supports_meta_slot
          render_inline(Component.new(state: :sent)) do |message|
            message.meta { "Meta" }
            "Body"
          end

          assert_text "Body"
          assert_text "Meta"
        end

        def test_renders_attachment_slot_without_with_prefix
          render_inline(Component.new(state: :sent)) do |message|
            message.attachment { "Attachment" }
            "Outgoing with attachment"
          end

          assert_text "Outgoing with attachment"
          assert_text "Attachment"
        end

        def test_renders_media_attachment_slot_without_with_prefix
          render_inline(Component.new(state: :sent)) do |message|
            message.media_attachment { "Media" }
            "Outgoing with media"
          end

          assert_text "Outgoing with media"
          assert_text "Media"
        end

        def test_renders_actions_slot_without_with_prefix
          render_inline(Component.new(state: :read, reveal_actions: true)) do |message|
            message.actions { "Reply" }
            "Outgoing"
          end

          assert_text "Outgoing"
          assert_text "Reply"
          refute_text "Edit"
          refute_text "Delete"
        end

        def test_does_not_expose_with_prefixed_slot_helpers
          component = Component.new(state: :sent)

          assert_not_respond_to component, :with_attachment
          assert_not_respond_to component, :with_media_attachment
          assert_not_respond_to component, :with_meta
          assert_not_respond_to component, :with_actions
        end
      end
    end
  end
end
