# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module MessageRecord
      class ComponentTest < ViewComponent::TestCase
        def test_renders_incoming_record_by_default
          record = message_record_class.new(
            id: 41,
            sender_name: "Mina Cho",
            body: "Can you review this before lunch?",
            state: "sent",
            created_at: Time.current
          )

          render_inline(Component.new(record: record))

          assert_text "Mina Cho"
          assert_text "Can you review this before lunch?"
          assert_selector "div[data-pagination-cursor='41'][data-flat-pack-chat-record='true'][data-flat-pack-chat-record-sender='Mina Cho'][data-flat-pack-chat-record-direction='incoming']"
          assert_selector "div[data-chat-message-state='sent']"
        end

        def test_renders_outgoing_when_sender_name_is_you
          record = message_record_class.new(
            sender_name: "You",
            body: "Reviewed and approved.",
            state: "read",
            created_at: Time.current
          )

          render_inline(Component.new(record: record))

          assert_text "Reviewed and approved."
          assert_selector "div[data-chat-message-state='read']"
          assert_no_text "You"
        end

        def test_allows_direction_override
          record = message_record_class.new(
            sender_name: "Mina",
            body: "Treat this as outgoing.",
            state: "sent",
            created_at: Time.current
          )

          render_inline(Component.new(record: record, direction: :outgoing, show_name: true))

          assert_text "Mina"
          assert_text "Treat this as outgoing."
        end

        def test_reveal_actions_defaults_to_disabled
          record = message_record_class.new(
            sender_name: "You",
            body: "No reveal by default.",
            state: "sent",
            created_at: Time.current
          )

          render_inline(Component.new(record: record))

          refute_includes rendered_content, "flat-pack--chat-message-actions"
        end

        def test_reveal_actions_renders_for_outgoing_when_enabled
          created_at = Time.zone.parse("2026-02-25 17:07:00")
          record = message_record_class.new(
            sender_name: "You",
            body: "Reveal actions for outgoing.",
            state: "sent",
            created_at: created_at
          )

          render_inline(Component.new(record: record, reveal_actions: true))

          assert_includes rendered_content, "flat-pack--chat-message-actions"
          assert_includes rendered_content, "data-flat-pack--chat-message-actions-side-value=\"right\""
          assert_text "Edit"
          assert_text "Delete"
          assert_text "5:07 PM"
        end

        def test_reveal_actions_renders_for_incoming_without_action_buttons
          created_at = Time.zone.parse("2026-02-25 16:47:00")
          record = message_record_class.new(
            sender_name: "Mina",
            body: "Incoming should not reveal.",
            state: "sent",
            created_at: created_at
          )

          render_inline(Component.new(record: record, reveal_actions: true))

          assert_includes rendered_content, "flat-pack--chat-message-actions"
          assert_includes rendered_content, "data-flat-pack--chat-message-actions-side-value=\"left\""
          assert_text "4:47 PM"
          refute_text "Edit"
          refute_text "Delete"
        end

        def test_uses_default_state_for_invalid_record_state
          record = message_record_class.new(
            sender_name: "Mina",
            body: "Fallback state",
            state: "unknown_state",
            created_at: Time.current
          )

          render_inline(Component.new(record: record))

          assert_selector "div[data-chat-message-state='sent']"
        end

        def test_requires_body_or_attachments
          record = message_record_class.new(sender_name: "Mina", body: nil)

          assert_raises ArgumentError do
            Component.new(record: record)
          end
        end

        def test_allows_attachments_without_body
          attachments = [
            {type: :image, name: "hero-1.png", thumbnail_url: "https://picsum.photos/seed/hero-1/480/280"}
          ]

          render_inline(Component.new(sender_name: "Mina", body: nil, attachments: attachments))

          assert_selector "img[alt='hero-1.png']"
          assert_no_selector "div.px-4.py-2"
        end

        def test_renders_text_bubble_and_image_attachment_separately
          attachments = [
            {type: :image, name: "hero-2.png", thumbnail_url: "https://picsum.photos/seed/hero-2/480/280"}
          ]

          render_inline(Component.new(sender_name: "You", body: "Looks good", attachments: attachments))

          assert_text "Looks good"
          assert_selector "img[alt='hero-2.png']"
          assert_no_selector "div.px-4.py-2 img"
        end

        def test_renders_multi_image_attachments_as_image_deck
          attachments = [
            {type: :image, name: "hero-1.png", thumbnail_url: "https://picsum.photos/seed/hero-1/480/280"},
            {type: :image, name: "hero-2.png", thumbnail_url: "https://picsum.photos/seed/hero-2/480/280"},
            {type: :image, name: "hero-3.png", thumbnail_url: "https://picsum.photos/seed/hero-3/480/280"},
            {type: :image, name: "hero-4.png", thumbnail_url: "https://picsum.photos/seed/hero-4/480/280"}
          ]

          render_inline(Component.new(sender_name: "You", body: nil, attachments: attachments, direction: :outgoing))

          assert_selector "div[data-flat-pack-chat-image-deck='true']"
          assert_selector "div[data-flat-pack--chat-image-deck-target='card']", count: 3
          assert_text "+1"
        end

        def test_requires_sender_name
          record = message_record_class.new(sender_name: nil, body: "Hello")

          assert_raises ArgumentError do
            Component.new(record: record)
          end
        end

        def test_does_not_render_meta_markup_as_message_text
          record = message_record_class.new(
            id: 55,
            sender_name: "You",
            body: "Got it",
            state: "sent",
            created_at: Time.current
          )

          render_inline(Component.new(record: record))

          assert_text "Got it"
          assert_includes rendered_content, "class=\"flex items-center gap-1.5 text-xs\""
          refute_includes rendered_content, "&lt;div class=\"flex items-center gap-1.5 text-xs\"&gt;"
        end

        def message_record_class
          Struct.new(:id, :sender_name, :body, :state, :created_at, keyword_init: true)
        end
      end
    end
  end
end
