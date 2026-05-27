# frozen_string_literal: true

module FlatPack
  module PageNav
    class Component < FlatPack::BaseComponent
      def initialize(
        back_icon: "chevron-left",
        back_label: "Go back",
        back_style: :secondary,
        back_size: :md,
        close_url: nil,
        close_icon: "x-mark",
        close_label: "Close",
        close_style: :secondary,
        close_size: :md,
        add_url: nil,
        add_icon: "plus",
        add_label: "Add",
        add_style: :secondary,
        add_size: :md,
        **system_arguments
      )
        super(**system_arguments)

        @back_icon = back_icon
        @back_label = back_label
        @back_style = back_style
        @back_size = back_size

        @close_url = close_url
        @close_icon = close_icon
        @close_label = close_label
        @close_style = close_style
        @close_size = close_size

        @add_url = add_url
        @add_icon = add_icon
        @add_label = add_label
        @add_style = add_style
        @add_size = add_size
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
            close_action
          ].compact)
        end
      end

      def close_action
        return unless @close_url.present?

        icon_button(
          icon: @close_icon,
          label: @close_label,
          style: @close_style,
          size: @close_size,
          url: @close_url
        )
      end

      def right_action
        return unless @add_url.present?

        icon_button(
          icon: @add_icon,
          label: @add_label,
          style: @add_style,
          size: @add_size,
          url: @add_url
        )
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