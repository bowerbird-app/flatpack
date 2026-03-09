# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Header
      class ComponentTest < ViewComponent::TestCase
        def test_renders_title_and_subtitle
          render_inline(Component.new(title: "Design Team", subtitle: "14 members"))

          assert_text "Design Team"
          assert_text "14 members"
        end

        def test_renders_back_button_when_back_href_present
          render_inline(Component.new(title: "Design Team", back_href: "/chat-groups", back_label: "Back to chat groups"))

          assert_selector "a[href='/chat-groups']"
          assert_text "Back to chat groups"
        end

        def test_renders_back_button_tooltip_when_provided
          render_inline(Component.new(
            title: "Design Team",
            back_href: "/chat-groups",
            back_label: nil,
            back_tooltip: "Back to chat groups"
          ))

          assert_selector "a[href='/chat-groups'][title='Back to chat groups']"
          assert_selector "a[href='/chat-groups'][aria-label='Back to chat groups']"
          assert_no_selector "a[href='/chat-groups'] span", text: "<"
        end

        def test_renders_single_person_avatar
          render_inline(Component.new(
            title: "Alicia Chen",
            person_avatar: {name: "Alicia Chen", size: :sm}
          ))

          assert_text "AC"
          assert_no_text "+"
        end

        def test_renders_person_avatar_online_status
          render_inline(Component.new(
            title: "Alicia Chen",
            person_avatar: {name: "Alicia Chen", size: :sm, status: :online}
          ))

          assert_includes page.native.to_html, "bg-[var(--avatar-status-online-color)]"
        end

        def test_renders_group_avatars_with_overflow
          render_inline(Component.new(
            title: "Design Team",
            group_avatars: [
              {name: "Alex Rivera", initials: "AR"},
              {name: "Mina Cho", initials: "MC"},
              {name: "Sam Lee", initials: "SL"},
              {name: "Jo Kim", initials: "JK"}
            ],
            group_max: 2
          ))

          assert_text "AR"
          assert_text "MC"
          assert_text "+2"
        end

        def test_prefers_group_mode_when_avatar_mode_group
          render_inline(Component.new(
            title: "Design Team",
            avatar_mode: :group,
            person_avatar: {name: "Alicia Chen", size: :sm},
            group_avatars: [{name: "Alex Rivera", initials: "AR"}]
          ))

          assert_text "AR"
          assert_no_text "AC"
        end

        def test_renders_right_slot_content
          render_inline(Component.new(title: "Design Team")) do |header|
            header.right do
              "Actions"
            end
          end

          assert_text "Actions"
        end

        def test_renders_clickable_content_when_content_url_present
          render_inline(Component.new(
            title: "Design Team",
            subtitle: "8 members",
            group_avatars: [{name: "Alex Rivera", initials: "AR"}],
            content_url: "/chat-groups/design-team/settings"
          ))

          assert_selector "a[href='/chat-groups/design-team/settings']", text: "Design Team"
          assert_selector "a[href='/chat-groups/design-team/settings']", text: "AR"
        end

        def test_does_not_render_content_link_when_content_url_absent
          render_inline(Component.new(title: "Design Team", subtitle: "8 members"))

          assert_no_selector "a", text: "Design Team"
        end

        def test_validates_avatar_mode
          assert_raises ArgumentError do
            Component.new(title: "Design Team", avatar_mode: :invalid)
          end
        end

        def test_validates_group_avatars_array
          assert_raises ArgumentError do
            Component.new(title: "Design Team", group_avatars: "invalid")
          end
        end

        def test_validates_content_url
          assert_raises ArgumentError do
            Component.new(title: "Design Team", content_url: "javascript:alert(1)")
          end
        end
      end
    end
  end
end
