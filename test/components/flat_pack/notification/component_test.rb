# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Notification
    class ComponentTest < ViewComponent::TestCase
      def test_does_not_render_badge_when_unread_count_is_nil
        render_inline(Component.new(unread_count: nil, see_all_href: "/notifications"))

        refute_selector "span[aria-hidden='true']"
      end

      def test_does_not_render_badge_when_unread_count_is_zero
        render_inline(Component.new(unread_count: 0, see_all_href: "/notifications"))

        refute_selector "span[aria-hidden='true']"
      end

      def test_does_not_render_badge_when_unread_count_is_negative
        render_inline(Component.new(unread_count: -1, see_all_href: "/notifications"))

        refute_selector "span[aria-hidden='true']"
      end

      def test_renders_badge_text_for_single_unread_notification
        render_inline(Component.new(unread_count: 1, see_all_href: "/notifications"))

        assert_selector "span[aria-hidden='true']", text: "1"
      end

      def test_renders_badge_text_for_nine_unread_notifications
        render_inline(Component.new(unread_count: 9, see_all_href: "/notifications"))

        assert_selector "span[aria-hidden='true']", text: "9"
      end

      def test_renders_nine_plus_for_ten_unread_notifications
        render_inline(Component.new(unread_count: 10, see_all_href: "/notifications"))

        assert_selector "span[aria-hidden='true']", text: "9+"
      end

      def test_renders_nine_plus_for_large_unread_counts
        render_inline(Component.new(unread_count: 100, see_all_href: "/notifications"))

        assert_selector "span[aria-hidden='true']", text: "9+"
      end

      def test_renders_button_trigger
        render_inline(Component.new(see_all_href: "/notifications"))

        assert_selector "button[type='button'][aria-haspopup='dialog']"
      end

      def test_uses_provided_trigger_id
        render_inline(Component.new(trigger_id: "notification-trigger", see_all_href: "/notifications"))

        assert_selector "button#notification-trigger"
      end

      def test_generates_trigger_id_when_none_is_provided
        render_inline(Component.new(see_all_href: "/notifications"))

        assert_selector "button[id^='flat-pack-notification-']"
      end

      def test_includes_base_aria_label_when_unread_count_is_zero
        render_inline(Component.new(unread_count: 0, see_all_href: "/notifications"))

        assert_selector "button[aria-label='Notifications']"
      end

      def test_includes_unread_count_in_aria_label
        render_inline(Component.new(unread_count: 3, see_all_href: "/notifications"))

        assert_selector "button[aria-label='Notifications, 3 unread']"
      end

      def test_includes_nine_or_more_in_aria_label_for_large_counts
        render_inline(Component.new(unread_count: 12, see_all_href: "/notifications"))

        assert_selector "button[aria-label='Notifications, 9 or more unread']"
      end

      def test_renders_popover_component
        render_inline(Component.new(trigger_id: "notification-trigger", see_all_href: "/notifications"))

        assert_selector "div[data-controller='flat-pack--popover']"
      end

      def test_popover_has_expected_trigger_id_data_attribute
        render_inline(Component.new(trigger_id: "notification-trigger", see_all_href: "/notifications"))

        assert_selector "div[data-flat-pack--popover-trigger-id-value='notification-trigger']"
      end

      def test_popover_uses_configured_placement
        render_inline(Component.new(trigger_id: "notification-trigger", placement: :left, see_all_href: "/notifications"))

        assert_selector "div[data-flat-pack--popover-placement-value='left']"
      end

      def test_popover_includes_custom_width_and_padding_classes
        render_inline(Component.new(trigger_id: "notification-trigger", see_all_href: "/notifications"))

        html = page.native.to_html

        assert_includes html, "w-80"
        assert_includes html, "max-w-[calc(100vw-2rem)]"
        assert_includes html, "overflow-hidden"
        assert_includes html, "!p-0"
        refute_includes html, "pb-12"
      end

      def test_renders_notification_title
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(title: "New comment")]))

        assert_text "New comment"
      end

      def test_renders_notification_body
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(body: "Marco commented.")]))

        assert_text "Marco commented."
      end

      def test_applies_zero_bottom_margin_to_notification_rows
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification]))

        assert_selector "li.mb-0", text: "New comment"
      end

      def test_does_not_render_icon_column_when_icon_is_blank
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(icon: "")]))

        refute_selector "li span svg"
      end

      def test_left_aligns_notification_title_and_body
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification]))

        assert_selector "li .text-left", text: "New comment"
      end

      def test_renders_linked_notification_item_when_href_is_provided
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(href: "/notifications/1")]))

        assert_selector "li a[href='/notifications/1']"
      end

      def test_renders_non_linked_notification_item_when_href_is_missing
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(href: nil)]))

        assert_selector "li[role='listitem']", text: "New comment"
        refute_selector "li a"
      end

      def test_applies_active_styling_when_notification_is_unread
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(unread: true)]))

        assert_includes page.native.to_html, "bg-[var(--list-item-active-background-color)]"
      end

      def test_renders_empty_state_when_notifications_are_empty
        render_inline(Component.new(see_all_href: "/notifications"))

        assert_text "No recent notifications"
      end

      def test_renders_configured_empty_state
        render_inline(Component.new(see_all_href: "/notifications", empty_message: "Nothing new"))

        assert_text "Nothing new"
      end

      def test_renders_time_element_for_valid_iso8601_timestamp
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "2026-07-03T10:30:00Z")]))

        assert_selector "time[datetime]"
      end

      def test_sets_timestamp_datetime_attribute
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "2026-07-03T10:30:00Z")]))

        assert_selector "time[datetime='2026-07-03T10:30:00Z']"
      end

      def test_uses_timestamp_stimulus_controller
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "2026-07-03T10:30:00Z")]))

        assert_selector "time[data-controller='flat-pack--timestamp']"
      end

      def test_uses_short_timestamp_data_attribute
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "2026-07-03T10:30:00Z")]))

        assert_selector "time[data-flat-pack--timestamp-shorten-timestamp-value='true']"
      end

      def test_uses_timestamp_fallback_behavior_when_timestamp_is_invalid
        render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "not-a-timestamp")]))

        assert_selector "span.flat-pack-timestamp"
      end

      def test_does_not_require_preformatted_relative_timestamp_strings
        travel_to Time.zone.parse("2026-07-03 12:00:00 UTC") do
          render_inline(Component.new(see_all_href: "/notifications", notifications: [notification(time: "2026-07-03T10:30:00Z")]))
        end

        assert_text "2hr ago"
        refute_text "2 hours ago"
      end

      def test_renders_footer_link_text
        render_inline(Component.new(see_all_href: "/notifications"))

        assert_text "See all notifications"
      end

      def test_links_footer_item_to_see_all_href
        render_inline(Component.new(see_all_href: "/notifications"))

        assert_link "See all notifications", href: "/notifications"
      end

      def test_raises_error_when_see_all_href_is_missing
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_when_see_all_href_is_blank
        assert_raises(ArgumentError) do
          Component.new(see_all_href: "")
        end
      end

      def test_raises_error_when_see_all_href_is_unsafe
        assert_raises(ArgumentError) do
          Component.new(see_all_href: "javascript:alert(1)")
        end
      end

      def test_raises_error_for_invalid_placement
        assert_raises(ArgumentError) do
          Component.new(see_all_href: "/notifications", placement: :invalid)
        end
      end

      def test_merges_system_arguments_on_wrapper
        render_inline(Component.new(see_all_href: "/notifications", class: "custom-wrapper", data: {testid: "notifications"}))

        assert_selector "div.custom-wrapper[data-testid='notifications']"
      end

      private

      def notification(**overrides)
        {
          title: "New comment",
          body: "Marco commented on your post.",
          href: "/notifications/1",
          time: nil,
          unread: false,
          icon: :bell
        }.merge(overrides)
      end
    end
  end
end
