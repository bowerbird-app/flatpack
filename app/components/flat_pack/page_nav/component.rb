# frozen_string_literal: true

module FlatPack
  module PageNav
    class Component < FlatPack::BaseComponent
      renders_one :right_slot

      def initialize(
        back_icon: "chevron-left",
        back_label: "Go back",
        back_style: :secondary,
        back_size: :md,
        anchor_url: nil,
        anchor_icon: "x-mark",
        anchor_label: "Close",
        anchor_style: :secondary,
        anchor_size: :md,
        **system_arguments
      )
        super(**system_arguments)

        @back_icon = back_icon
        @back_label = back_label
        @back_style = back_style
        @back_size = back_size

        @anchor_url = anchor_url
        @anchor_icon = anchor_icon
        @anchor_label = anchor_label
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
          content_tag(:div, class: "flex items-center justify-between gap-2") do
            safe_join([
              left_actions,
              right_action
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
          safe_join([
            icon_button(
              icon: @back_icon,
              label: @back_label,
              style: @back_style,
              size: @back_size,
              data: {action: "click->flat-pack--page-nav#back"}
            ),
            anchor_action
          ].compact)
        end
      end

      def anchor_action
        return unless @anchor_url.present?

        icon_button(
          icon: @anchor_icon,
          label: @anchor_label,
          style: @anchor_style,
          size: @anchor_size,
          url: @anchor_url
        )
      end

      def right_action
        return unless right?

        right.to_s
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
