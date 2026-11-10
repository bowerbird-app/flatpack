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
          assert_includes rendered_content, "px-[var(--chat-message-padding-x)]"
          assert_includes rendered_content, "py-[var(--chat-message-padding-y)]"
          assert_includes rendered_content, "rounded-[var(--chat-message-radius)]"
        end

        def test_renders_reveal_actions_when_enabled
          render_inline(Component.new(state: :read, reveal_actions: true, timestamp: Time.zone.parse("2026-02-26 10:18:00"))) do
            "Slide me"
          end

          assert_includes rendered_content, "flat-pack--chat-message-actions"
          assert_includes rendered_content, "rounded-[var(--chat-message-radius)]"
          assert_includes rendered_content, "duration-[var(--duration-fast)]"
          refute_includes rendered_content, "duration-150"
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

        def test_default_output_omits_timestamp_reveal
          render_inline(Component.new(state: :sent, timestamp: Time.zone.parse("2026-11-10 14:30:00"))) do
            "Outgoing"
          end

          html = rendered_content
          refute_includes html, "fp-chat-timestamp-reveal"
          refute_includes html, "flat-pack--chat-timestamp-reveal"
          refute_includes html, "fp-chat-timestamp"
          refute_includes html, "tabindex"
          refute_text "2:30 PM"
        end

        def test_reveal_timestamp_keeps_time_readable
          render_inline(Component.new(
            state: :sent,
            timestamp: Time.zone.parse("2026-11-10 14:30:00"),
            reveal_timestamp: true
          )) do
            "Outgoing"
          end

          html = rendered_content
          assert_includes html, "fp-chat-timestamp-reveal"
          assert_includes html, "flat-pack--chat-timestamp-reveal"
          assert_includes html, "fp-chat-timestamp"
          assert_includes html, 'tabindex="0"'
          assert_text "2:30 PM"
          refute_includes html, "display:none"
          refute_includes html, "display: none"
          refute_includes html, "visibility:hidden"
          refute_includes html, "visibility: hidden"
          refute_includes html, "aria-hidden"
        end

        def test_reveal_actions_skips_timestamp_reveal_controller
          render_inline(Component.new(
            state: :sent,
            reveal_actions: true,
            reveal_timestamp: true,
            timestamp: Time.zone.parse("2026-11-10 14:30:00")
          )) do
            "Outgoing"
          end

          refute_includes rendered_content, "flat-pack--chat-timestamp-reveal"
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
