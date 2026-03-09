# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module ReceivedMessage
      class ComponentTest < ViewComponent::TestCase
        def test_renders_incoming_message
          render_inline(Component.new(state: :sent)) do
            "Incoming"
          end

          assert_selector "div[data-chat-message-state='sent']", text: "Incoming"
          assert_includes rendered_content, "justify-start"
        end

        def test_renders_meta_slot
          render_inline(Component.new(state: :sent)) do |message|
            message.meta { "10:12 AM" }
            "Incoming with meta"
          end

          assert_text "Incoming with meta"
          assert_text "10:12 AM"
        end

        def test_renders_reveal_timestamp_for_incoming_when_enabled
          render_inline(Component.new(state: :sent, reveal_actions: true, timestamp: Time.zone.parse("2026-02-26 10:12:00"))) do
            "Incoming reveal"
          end

          assert_includes rendered_content, "flat-pack--chat-message-actions"
          assert_includes rendered_content, "data-flat-pack--chat-message-actions-side-value=\"left\""
          assert_text "10:12 AM"
          refute_text "Edit"
          refute_text "Delete"
        end
      end
    end
  end
end
