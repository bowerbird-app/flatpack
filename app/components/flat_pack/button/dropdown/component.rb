# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      class Component < FlatPack::BaseComponent
        renders_many :menu, types: {
          item: FlatPack::Button::DropdownItem::Component,
          divider: FlatPack::Button::DropdownDivider::Component
        }

        POSITIONS = {
          bottom_right: "top-full right-0 mt-2",
          bottom_left: "top-full left-0 mt-2",
          top_right: "bottom-full right-0 mb-2",
          top_left: "bottom-full left-0 mb-2"
        }.freeze

        def initialize(
          text:,
          style: :primary,
          size: :md,
          icon: nil,
          disabled: false,
          position: :bottom_right,
          max_height: "384px",
          **system_arguments
        )
          super(**system_arguments)
          @text = text
          @style = style.to_sym
          @size = size.to_sym
          @icon = icon
          @disabled = disabled
          @position = position.to_sym
          @max_height = max_height

          validate_position!
        end

        private

        def wrapper_attributes
          merge_attributes(
            class: wrapper_classes,
            data: dropdown_data_attributes
          )
        end

        def wrapper_classes
          classes("relative inline-block")
        end

        def dropdown_data_attributes
          {
            controller: "button-dropdown",
            button_dropdown_max_height_value: @max_height
          }
        end

        def button_attributes
          {
            class: button_classes,
            aria: {
              haspopup: "true",
              expanded: "false"
            },
            data: {
              button_dropdown_target: "trigger",
              action: "click->button-dropdown#toggle"
            }
          }
        end

        def button_classes
          # Use the same classes as Button component would use
          base_classes = [
            "inline-flex items-center justify-center gap-2",
            "rounded-md",
            "font-medium",
            "cursor-pointer",
            "transition-colors duration-base",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
            "disabled:pointer-events-none disabled:opacity-50"
          ]

          base_classes << FlatPack::Button::Component::SIZES.fetch(@size)
          base_classes << FlatPack::Button::Component::SCHEMES.fetch(@style)
          base_classes.join(" ")
        end

        def button_content
          content = []
          content << render(FlatPack::Shared::IconComponent.new(name: @icon, size: @size)) if @icon
          content << content_tag(:span, @text)
          content << chevron_icon
          safe_join(content)
        end

        def chevron_icon
          content_tag(:svg,
            class: "h-4 w-4 transition-transform duration-200",
            data: {button_dropdown_target: "chevron"},
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2",
            "stroke-linecap": "round",
            "stroke-linejoin": "round") do
            content_tag(:polyline, nil, points: "6 9 12 15 18 9")
          end
        end

        def menu_attributes
          {
            class: menu_classes,
            role: "menu",
            data: {
              button_dropdown_target: "menu"
            }
          }
        end

        def menu_classes
          classes(
            "absolute z-50",
            "min-w-[12rem]",
            "overflow-auto",
            "rounded-md",
            "border border-border",
            "bg-background",
            "p-1",
            "shadow-lg",
            "opacity-0 scale-95 hidden",
            "transition-all duration-200",
            POSITIONS.fetch(@position)
          )
        end

        def validate_position!
          return if POSITIONS.key?(@position)

          raise ArgumentError,
            "Invalid position: #{@position}. Must be one of: #{POSITIONS.keys.join(", ")}"
        end
      end
    end
  end
end
