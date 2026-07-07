# frozen_string_literal: true

module FlatPack
  module Notification
    class Component < FlatPack::BaseComponent
      def initialize(
        see_all_href:, notifications: [],
        unread_count: 0,
        trigger_id: nil,
        placement: :bottom,
        bell_label: "Notifications",
        empty_message: "No recent notifications",
        timestamp_tooltip_placement: :left,
        **system_arguments
      )
        super(**system_arguments)

        @notifications = Array(notifications)
        @unread_count = unread_count
        @see_all_href = FlatPack::AttributeSanitizer.validate_href!(see_all_href)
        @trigger_id = trigger_id.presence || generated_trigger_id
        @popover_id = "#{@trigger_id}-popover"
        @placement = placement.to_sym
        @bell_label = bell_label.to_s
        @empty_message = empty_message.to_s
        @timestamp_tooltip_placement = timestamp_tooltip_placement.to_sym

        validate_placement!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_trigger,
            render_popover
          ])
        end
      end

      private

      def render_trigger
        content_tag(
          :button,
          type: "button",
          id: @trigger_id,
          class: trigger_classes,
          aria: {
            label: accessible_label,
            haspopup: "dialog",
            controls: @popover_id
          }
        ) do
          safe_join([
            render_bell_icon,
            content_tag(:span, @bell_label, class: "sr-only"),
            render_badge
          ].compact)
        end
      end

      def render_bell_icon
        render FlatPack::Shared::IconComponent.new(
          name: "bell",
          size: :lg,
          class: "h-5 w-5"
        )
      end

      def render_badge
        return unless unread?

        content_tag(
          :span,
          badge_text,
          class: badge_classes,
          aria: {hidden: "true"}
        )
      end

      def render_popover
        render FlatPack::Popover::Component.new(
          trigger_id: @trigger_id,
          placement: @placement,
          id: @popover_id,
          class: "w-80 max-w-[calc(100vw-2rem)] !p-0 overflow-hidden"
        ) do |popover|
          popover.content do
            safe_join([
              render_notification_panel,
              render_footer
            ])
          end
        end
      end

      def render_notification_panel
        content_tag(:div, class: "max-h-96 overflow-y-auto") do
          if @notifications.empty?
            render_empty_state
          else
            render_notification_list
          end
        end
      end

      def render_notification_list
        render FlatPack::List::Component.new(spacing: :dense, divider: true) do
          safe_join(@notifications.map { |notification| render_notification_item(notification) })
        end
      end

      def render_notification_item(notification)
        render FlatPack::List::Item.new(
          icon: notification_icon(notification),
          href: notification_value(notification, :href),
          hover: true,
          active: unread_notification?(notification),
          class: "mb-0",
          trailing: render_timestamp(notification_value(notification, :time))
        ) do
          render_notification_content(notification)
        end
      end

      def render_notification_content(notification)
        content_tag(:div, class: "space-y-0.5 text-left") do
          safe_join([
            content_tag(
              :div,
              notification_value(notification, :title).presence || "Notification",
              class: "truncate text-sm font-medium text-[var(--surface-content-color)]"
            ),
            render_notification_body(notification_value(notification, :body))
          ].compact)
        end
      end

      def render_notification_body(body)
        return if body.blank?

        content_tag(
          :div,
          body,
          class: "line-clamp-2 text-xs text-[var(--surface-muted-content-color)]"
        )
      end

      def render_timestamp(timestamp)
        return if timestamp.blank?

        render FlatPack::Timestamp::Component.new(
          timestamp: timestamp,
          tooltip_placement: @timestamp_tooltip_placement,
          fallback_text: "",
          class_name: "text-xs text-[var(--surface-muted-content-color)] whitespace-nowrap"
        )
      end

      def render_footer
        content_tag(
          :div,
          class: "sticky bottom-0 border-t border-[var(--surface-border-color)] bg-[var(--popover-background-color)]"
        ) do
          link_to(
            "See all notifications",
            @see_all_href,
            class: "block px-3 py-3 text-center text-sm font-medium text-[var(--color-primary)] transition-colors hover:bg-[var(--surface-muted-background-color)] focus:outline-none focus:ring-2 focus:ring-inset focus:ring-[var(--color-primary)]"
          )
        end
      end

      def render_empty_state
        content_tag(
          :div,
          @empty_message,
          class: "px-4 py-6 text-center text-sm text-[var(--surface-muted-content-color)]"
        )
      end

      def unread_count
        @unread_count.to_i
      end

      def unread?
        unread_count.positive?
      end

      def badge_text
        return nil unless unread?

        (unread_count > 9) ? "9+" : unread_count.to_s
      end

      def accessible_label
        return @bell_label unless unread?

        if unread_count > 9
          "#{@bell_label}, 9 or more unread"
        else
          "#{@bell_label}, #{unread_count} unread"
        end
      end

      def wrapper_attributes
        merge_attributes(class: "relative inline-flex")
      end

      def trigger_classes
        merge_class_names(
          "relative inline-flex h-10 w-10 items-center justify-center rounded-full",
          "text-[var(--surface-muted-content-color)]",
          "transition-colors",
          "hover:bg-[var(--surface-muted-background-color)]",
          "hover:text-[var(--surface-content-color)]",
          "focus:outline-none",
          "focus:ring-2",
          "focus:ring-[var(--color-primary)]",
          "focus:ring-offset-2",
          "focus:ring-offset-[var(--surface-background-color)]"
        )
      end

      def badge_classes
        merge_class_names(
          "absolute -right-1 -top-1",
          "inline-flex h-5 min-w-5 items-center justify-center",
          "rounded-full bg-red-600 px-1",
          "text-xs font-semibold leading-none text-white",
          "ring-2 ring-[var(--surface-background-color)]"
        )
      end

      def generated_trigger_id
        "flat-pack-notification-#{object_id}"
      end

      def validate_placement!
        return if FlatPack::Popover::Component::PLACEMENTS.key?(@placement)

        valid = FlatPack::Popover::Component::PLACEMENTS.keys.join(", ")
        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{valid}"
      end

      def notification_value(notification, key)
        return unless notification.respond_to?(:[])

        notification[key] || notification[key.to_s]
      end

      def unread_notification?(notification)
        ActiveModel::Type::Boolean.new.cast(notification_value(notification, :unread))
      end

      def notification_icon(notification)
        icon = notification_value(notification, :icon)
        return if icon.respond_to?(:blank?) && icon.blank?

        icon
      end

      def merge_class_names(*class_names)
        TailwindMerge::Merger.new.merge(class_names.compact.join(" "))
      end
    end
  end
end
