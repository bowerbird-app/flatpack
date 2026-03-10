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
            message.with_meta { "Meta" }
            "Body"
          end

          assert_text "Body"
          assert_text "Meta"
        end
      end
    end
  end
end
