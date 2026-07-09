# frozen_string_literal: true

module FlatPack
  module PageNav
    class Component < FlatPack::BaseComponent
      renders_one :right_slot

      def initialize(
        back_icon: "chevron-left",
        back_tooltip: nil,
        # Deprecated: Use back_tooltip instead.
        back_label: "Go back",
        back_style: :secondary,
        back_size: :md,
        secondary_anchor_url: nil,
        secondary_anchor_icon: "chevron-left",
        secondary_anchor_tooltip: nil,
        anchor_url: nil,
        anchor_icon: "x-mark",
        anchor_tooltip: nil,
        # Deprecated: Use anchor_tooltip instead.
        anchor_label: "Close",
        anchor_style: :secondary,
        anchor_size: :md,
        **system_arguments
      )
        super(**system_arguments)

        @back_icon = back_icon
        @back_label = back_tooltip.presence || back_label
        @back_style = back_style
        @back_size = back_size

        @secondary_anchor_url = secondary_anchor_url
        @secondary_anchor_icon = secondary_anchor_icon
        @secondary_anchor_tooltip = secondary_anchor_tooltip
        @secondary_anchor_label = secondary_anchor_tooltip.presence || "Previous page"

        @anchor_url = anchor_url
        @anchor_icon = anchor_icon
        @anchor_label = anchor_tooltip.presence || anchor_label
        @anchor_style = anchor_style
        @anchor_size = anchor_size
      end

      def right_slot(*args, **kwargs, &block)
        return get_slot(:right_slot) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:right_slot, nil, *args, **kwargs, &block)
      end

      def right(*args, **kwargs, &block)
        right_slot(*args, **kwargs, &block)
      end

      def right?
        right_slot?
      end

      def call
        content_tag(:nav, **nav_attributes) do
          content_tag(:div, class: "flex gap-2") do
            safe_join([
              left_actions,
              anchor_actions,
              right_slot_wrapper
            ].compact)
          end
        end
      end

      private

      def nav_attributes
        merge_attributes(
          class: "flat-pack-page-nav",
          aria: {label: "Page navigation"},
          data: {controller: "flat-pack--page-nav"}
        )
      end

      def left_actions
        content_tag(:div, class: "flex items-center gap-2") do
          back_action
        end
      end

      def back_action
        tooltip_wrapper(@back_label) do
          icon_button(
            icon: @back_icon,
            label: @back_label,
            style: @back_style,
            size: @back_size,
            data: {action: "click->flat-pack--page-nav#back"}
          )
        end
      end

      def anchor_action
        return unless @anchor_url.present?

        tooltip_wrapper(@anchor_label) do
          icon_button(
            icon: @anchor_icon,
            label: @anchor_label,
            style: @anchor_style,
            size: @anchor_size,
            url: @anchor_url
          )
        end
      end

      def secondary_anchor_action
        return unless @secondary_anchor_url.present?

        tooltip_wrapper(@secondary_anchor_tooltip) do
          icon_button(
            icon: @secondary_anchor_icon,
            label: @secondary_anchor_label,
            style: @anchor_style,
            size: @anchor_size,
            url: @secondary_anchor_url
          )
        end
      end

      def anchor_actions
        actions = [
          secondary_anchor_action,
          anchor_action
        ].compact
        return if actions.empty?

        content_tag(:div, class: "flex items-center gap-2") do
          safe_join(actions)
        end
      end

      def right_slot_wrapper
        return unless right?

        content_tag(:div, class: "ml-auto flex items-center gap-2") do
          right.to_s
        end
      end

      def tooltip_wrapper(text)
        button = capture { yield }
        return button if text.blank?

        render FlatPack::Tooltip::Component.new(text: text) do
          button
        end
      end

      def icon_button(icon:, label:, style:, size:, url: nil, data: nil)
        button_arguments = {
          icon: icon,
          icon_only: true,
          style: style,
          size: size,
          aria: {label: label}
        }
        button_arguments[:url] = url if url.present?
        button_arguments[:data] = data if data.present?

        render FlatPack::Button::Component.new(**button_arguments)
      end
    end
  end
end
