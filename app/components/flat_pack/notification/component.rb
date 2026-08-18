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
        empty_text: "No recent notifications",
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
        @empty_text = empty_text.to_s
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
        render FlatPack::List::Component.new(spacing: :dense, divider: true, data: list_data_attributes) do
          safe_join(render_notification_rows)
        end
      end

      def render_notification_rows
        @notifications.each_with_index.flat_map do |notification, index|
          if rollup_notification?(notification)
            [
              render_rollup_parent(notification, index),
              render_rollup_children(notification, index)
            ]
          else
            [render_notification_item(notification)]
          end
        end
      end

      def render_rollup_parent(notification, index)
        unread_children_count = rollup_unread_children_count(notification)

        content_tag(:li, role: "listitem", class: rollup_parent_item_classes(notification)) do
          content_tag(
            :button,
            type: "button",
            class: rollup_parent_button_classes,
            aria: {
              expanded: "false",
              controls: rollup_children_id(index)
            },
            data: {
              "flat-pack--notification-rollup-target": "trigger",
              action: "click->flat-pack--notification-rollup#toggle keydown.enter->flat-pack--notification-rollup#toggle keydown.space->flat-pack--notification-rollup#toggle"
            }
          ) do
            safe_join([
              render_rollup_parent_icon(notification, unread_children_count: unread_children_count, suppress_unread_indicator: true),
              content_tag(:div, render_notification_content(notification), class: "min-w-0 flex-1"),
              content_tag(:span, rollup_trailing_content(notification), class: "flex-shrink-0 ml-2")
            ].compact)
          end
        end
      end

      def render_rollup_children(notification, index)
        children = notification_children(notification)

        content_tag(:li, role: "listitem", class: "py-0 hidden", data: {"flat-pack--notification-rollup-target": "row"}) do
          content_tag(
            :div,
            id: rollup_children_id(index),
            hidden: true,
            data: {"flat-pack--notification-rollup-target": "content"}
          ) do
            render FlatPack::List::Component.new(spacing: :dense, divider: false) do
              safe_join(children.map { |child| render_notification_item(child, nested: true) })
            end
          end
        end
      end

      def render_notification_item(notification, nested: false)
        return render_nested_notification_item(notification) if nested

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

      def render_nested_notification_item(notification)
        href = nested_notification_href(notification)

        content_tag(:li, role: "listitem", class: nested_notification_item_classes(notification)) do
          if href.present?
            link_to href, class: nested_notification_link_classes do
              render_nested_notification_inner(notification)
            end
          else
            render_nested_notification_inner(notification)
          end
        end
      end

      def nested_notification_inner_classes
        "flex w-full items-start"
      end

      def render_nested_notification_inner(notification)
        content_tag(:div, class: nested_notification_inner_classes) do
          safe_join([
            render_rollup_parent_icon(notification),
            content_tag(:div, render_notification_content(notification), class: "min-w-0 flex-1"),
            render_nested_notification_trailing(notification)
          ].compact)
        end
      end

      def render_nested_notification_trailing(notification)
        trailing = render_timestamp(notification_value(notification, :time))
        return if trailing.blank?

        content_tag(:span, trailing, class: "flex-shrink-0 ml-2")
      end

      def nested_notification_href(notification)
        href = notification_value(notification, :href)
        return if href.blank?

        FlatPack::AttributeSanitizer.validate_href!(href)
      end

      def nested_notification_link_classes
        "flat-pack-list-item-link flex w-full items-start focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-(--button-focus-ring-color)"
      end

      def nested_notification_item_classes(notification)
        merge_class_names(
          "mb-0 pl-4 flex items-start py-2 px-3 text-[var(--surface-content-color)] transition-colors hover:bg-[var(--list-item-hover-background-color)]",
          ("bg-[var(--list-item-active-background-color)]" if unread_notification?(notification))
        )
      end

      def rollup_parent_item_classes(notification)
        merge_class_names(
          "mb-0",
          "cursor-pointer",
          "flex items-start py-2 px-3",
          "text-[var(--surface-content-color)]",
          "transition-colors hover:bg-[var(--list-item-hover-background-color)]",
          ("bg-[var(--list-item-active-background-color)]" if unread_notification?(notification))
        )
      end

      def rollup_parent_button_classes
        "cursor-pointer flex w-full items-start text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-(--button-focus-ring-color)"
      end

      def render_rollup_parent_icon(notification, unread_children_count: 0, suppress_unread_indicator: false)
        icon = notification_icon(notification, decorate_unread: !suppress_unread_indicator)
        return if icon.nil?

        content_tag(:span, class: "relative flex-shrink-0 mr-2 text-[var(--surface-muted-content-color)]") do
          safe_join([
            if icon.is_a?(String) && icon.start_with?("<svg")
              icon.html_safe
            else
              render FlatPack::Shared::IconComponent.new(name: icon, size: :md)
            end,
            render_rollup_parent_counter_badge(unread_children_count)
          ].compact)
        end
      end

      def render_rollup_parent_counter_badge(count)
        return unless count.positive?

        content_tag(
          :span,
          rollup_counter_text(count),
          class: "fp-rollup-counter-badge absolute -right-1 -top-1 inline-flex h-4 min-w-4 items-center justify-center rounded-full bg-[var(--color-danger-background-color)] px-1 text-[10px] font-semibold leading-none text-[var(--color-danger-text-color)] ring-2 ring-[var(--surface-background-color)]",
          aria: {hidden: "true"}
        )
      end

      def rollup_counter_text(count)
        return "9+" if count > 9

        count.to_s
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
          shorten_timestamp: true,
          class: "text-xs text-[var(--surface-muted-content-color)] whitespace-nowrap"
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
            class: "block rounded-b-[var(--popover-radius)] px-3 py-3 text-center text-sm font-medium text-[var(--color-primary)] transition-colors hover:bg-[var(--surface-muted-background-color)] focus:outline-none focus:ring-2 focus:ring-inset focus:ring-[var(--color-primary)]"
          )
        end
      end

      def render_empty_state
        content_tag(
          :div,
          @empty_text,
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
          "focus:ring-2 focus:ring-inset",
          "focus:ring-[var(--color-primary)]",
          "focus:ring-offset-2",
          "focus:ring-offset-[var(--surface-background-color)]"
        )
      end

      def badge_classes
        merge_class_names(
          "absolute -right-1 -top-1",
          "inline-flex h-5 min-w-5 items-center justify-center",
          "rounded-full bg-[var(--color-danger-background-color)] px-1",
          "text-xs font-semibold leading-none text-[var(--color-danger-text-color)]",
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

      def notification_icon(notification, decorate_unread: true)
        icon = notification_value(notification, :icon)
        return if icon.respond_to?(:blank?) && icon.blank?

        return icon unless decorate_unread && unread_notification?(notification)

        return add_red_dot_to_svg(icon) if svg_markup?(icon)

        render FlatPack::Shared::IconComponent.new(name: icon, size: :md, class: "fp-red-dot")
      end

      def rollup_notification?(notification)
        ActiveModel::Type::Boolean.new.cast(notification_value(notification, :rollup)) && notification_children(notification).any?
      end

      def notification_children(notification)
        Array(notification_value(notification, :children)).select { |child| child.respond_to?(:[]) }
      end

      def rollup_unread_children_count(notification)
        notification_children(notification).count { |child| unread_notification?(child) }
      end

      def rollup_children_id(index)
        "#{@trigger_id}-rollup-#{index}-children"
      end

      def rollup_trailing_content(notification)
        safe_join([
          render_timestamp(notification_value(notification, :time)),
          render_rollup_caret
        ].compact)
      end

      def render_rollup_caret
        render FlatPack::Shared::IconComponent.new(
          name: "chevron-down",
          size: :sm,
          class: "ml-1 transition-transform duration-200",
          data: {"flat-pack--notification-rollup-target": "icon"}
        )
      end

      def list_data_attributes
        return {} unless @notifications.any? { |notification| rollup_notification?(notification) }

        {controller: "flat-pack--notification-rollup"}
      end

      def svg_markup?(icon)
        icon.is_a?(String) && icon.strip.start_with?("<svg")
      end

      def add_red_dot_to_svg(icon)
        svg = icon.dup

        if svg.match?(/\sclass\s*=\s*"/)
          svg.sub(/\sclass\s*=\s*"([^"]*)"/, ' class="\\1 fp-red-dot"')
        else
          svg.sub("<svg", '<svg class="fp-red-dot"')
        end
      end

      def merge_class_names(*class_names)
        TailwindMerge::Merger.new.merge(class_names.compact.join(" "))
      end
    end
  end
end
