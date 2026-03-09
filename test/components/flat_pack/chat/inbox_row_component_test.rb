# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module InboxRow
      class ComponentTest < ViewComponent::TestCase
        def test_renders_chat_group_name_and_preview
          render_inline(Component.new(
            chat_group_name: "Design Team",
            latest_sender: "Mina",
            latest_preview: "Can you review this?",
            latest_at: Time.zone.parse("2026-02-27 10:12:00")
          ))

          assert_text "Design Team"
          assert_text "Mina: Can you review this?"
          assert_text "10:12 AM"
        end

        def test_renders_unread_badge_when_positive
          render_inline(Component.new(chat_group_name: "Design Team", unread_count: 4))

          assert_text "4"
        end

        def test_hides_unread_badge_when_zero
          render_inline(Component.new(chat_group_name: "Design Team", unread_count: 0))

          assert_no_selector "span", text: "0"
        end

        def test_renders_link_arguments_with_turbo_frame_and_active_aria
          render_inline(Component.new(
            chat_group_name: "Design Team",
            href: "/demo/chat/demo?chat_group_id=1",
            turbo_frame: "chat-demo-panel",
            active: true
          ))

          assert_selector "a[href='/demo/chat/demo?chat_group_id=1'][data-turbo-frame='chat-demo-panel'][aria-current='page']"
        end

        def test_renders_avatar_group_data_attributes
          render_inline(Component.new(
            chat_group_name: "Design Team",
            avatar_items: [{name: "Mina Cho", initials: "MC"}]
          ))

          assert_selector "[data-chat-group-inbox-avatar='true']"
          assert_selector "[data-max-visible-avatars='2']"
        end

        def test_limits_avatar_display_to_one_avatar_plus_overflow_for_larger_groups
          render_inline(Component.new(
            chat_group_name: "Design Team",
            avatar_items: [
              {name: "Mina Cho"},
              {name: "Sam Lee"},
              {name: "Jo Kim"}
            ]
          ))

          assert_selector "[data-chat-group-inbox-avatar='true'] span", text: "MC"
          assert_selector "[data-chat-group-inbox-avatar='true'] span", text: "+2"
          assert_no_selector "[data-chat-group-inbox-avatar='true'] span", text: "SL"
        end

        def test_requires_chat_group_name
          assert_raises ArgumentError do
            Component.new(chat_group_name: "   ")
          end
        end
      end
    end
  end
end
