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
          assert_includes rendered_content, "px-[var(--chat-message-padding-x)]"
          assert_includes rendered_content, "py-[var(--chat-message-padding-y)]"
          assert_includes rendered_content, "rounded-[var(--chat-message-radius)]"
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
          assert_includes rendered_content, "rounded-[var(--chat-message-radius)]"
          assert_includes rendered_content, "data-flat-pack--chat-message-actions-side-value=\"left\""
          assert_includes rendered_content, "duration-[var(--duration-fast)]"
          refute_includes rendered_content, "duration-150"
          assert_text "10:12 AM"
          refute_text "Edit"
          refute_text "Delete"
        end

        def test_default_output_omits_timestamp_reveal
          render_inline(Component.new(state: :sent, timestamp: Time.zone.parse("2026-11-10 14:30:00"))) do
            "Incoming"
          end

          html = rendered_content
          refute_includes html, "fp-chat-timestamp-reveal"
          refute_includes html, "tabindex"
          refute_text "2:30 PM"
        end

        def test_reveal_timestamp_keeps_time_readable
          render_inline(Component.new(
            state: :sent,
            timestamp: Time.zone.parse("2026-11-10 14:30:00"),
            reveal_timestamp: true
          )) do
            "Incoming"
          end

          html = rendered_content
          assert_includes html, "fp-chat-timestamp-reveal"
          assert_text "2:30 PM"
          refute_includes html, "display:none"
          refute_includes html, "visibility:hidden"
          refute_includes html, "aria-hidden"
        end

        def test_renders_attachment_slot_without_with_prefix
          render_inline(Component.new(state: :sent)) do |message|
            message.attachment { "Attachment" }
            "Incoming with attachment"
          end

          assert_text "Incoming with attachment"
          assert_text "Attachment"
        end

        def test_renders_media_attachment_slot_without_with_prefix
          render_inline(Component.new(state: :sent)) do |message|
            message.media_attachment { "Media" }
            "Incoming with media"
          end

          assert_text "Incoming with media"
          assert_text "Media"
        end
      end
    end
  end
end
