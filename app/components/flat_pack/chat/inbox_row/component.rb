# frozen_string_literal: true

module FlatPack
  module Chat
    module InboxRow
      class Component < FlatPack::BaseComponent
        def initialize(
          chat_group_name:,
          avatar_items: [],
          latest_sender: nil,
          latest_preview: nil,
          latest_at: nil,
          unread_count: 0,
          href: nil,
          active: false,
          turbo_frame: nil,
          max_visible_avatars: 2,
          hover: true,
          **system_arguments
        )
          super(**system_arguments)
          @chat_group_name = chat_group_name.to_s.strip
          @avatar_items = normalize_avatar_items(avatar_items)
          @latest_sender = latest_sender.to_s.strip.presence
          @latest_preview = latest_preview.to_s.strip.presence
          @latest_at = latest_at
          @unread_count = normalize_unread_count(unread_count)
          @href = href
          @active = active
          @turbo_frame = turbo_frame
          @max_visible_avatars = max_visible_avatars
          @hover = hover

          validate_chat_group_name!
        end

        def call
          render FlatPack::List::Item.new(**list_item_arguments) do
            safe_join([
              content_tag(:p, @chat_group_name, class: "truncate text-sm font-medium text-(--surface-content-color)"),
              content_tag(:p, subtitle_text, class: "truncate text-xs text-(--surface-muted-content-color)")
            ])
          end
        end

        private

        def list_item_arguments
          {
            leading: leading_avatar,
            trailing: trailing_content,
            href: @href,
            hover: @hover,
            active: @active,
            link_arguments: link_arguments,
            class: "overflow-hidden"
          }.merge(@system_arguments)
        end

        def leading_avatar
          render FlatPack::AvatarGroup::Component.new(
            items: @avatar_items,
            max: avatar_group_max,
            size: :xs,
            overlap: :sm,
            data: {
              chat_group_inbox_avatar: true,
              max_visible_avatars: @max_visible_avatars
            }
          )
        end

        def trailing_content
          content_tag(:div, class: "min-w-13 flex flex-col items-end gap-1") do
            safe_join([
              content_tag(:span, time_label, class: "text-xs text-(--surface-muted-content-color)"),
              unread_badge
            ].compact)
          end
        end

        def unread_badge
          return unless @unread_count.positive?

          render FlatPack::Badge::Component.new(text: @unread_count.to_s, style: :info, size: :sm)
        end

        def time_label
          return @latest_at.strftime("%-l:%M %p") if @latest_at.respond_to?(:strftime)

          @latest_at.to_s
        end

        def subtitle_text
          [@latest_sender, @latest_preview].compact.join(": ")
        end

        def avatar_group_max
          return @max_visible_avatars if @avatar_items.length <= @max_visible_avatars

          [@max_visible_avatars - 1, 1].max
        end

        def link_arguments
          link_data = {}
          link_data[:turbo_frame] = @turbo_frame if @turbo_frame.present?

          {
            data: link_data,
            aria: {
              current: (@active ? "page" : nil)
            }
          }
        end

        def normalize_avatar_items(value)
          return [] unless value.is_a?(Array)

          value
        end

        def normalize_unread_count(value)
          parsed = value.is_a?(String) ? Integer(value, 10) : Integer(value)
          [parsed, 0].max
        rescue ArgumentError, TypeError
          0
        end

        def validate_chat_group_name!
          return if @chat_group_name.present?

          raise ArgumentError, "chat_group_name is required"
        end
      end
    end
  end
end
