# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      class Component < FlatPack::BaseComponent
        renders_many :menu, types: {
          item: FlatPack::Button::DropdownItem::Component,
          divider: FlatPack::Button::DropdownDivider::Component
        }

        undef_method :with_menu_item, :with_menu_divider
        undef_method :with_menu_item_content, :with_menu_divider_content

        POSITIONS = {
          bottom_right: "top-full right-0 mt-2",
          bottom_left: "top-full left-0 mt-2",
          top_right: "bottom-full right-0 mb-2",
          top_left: "bottom-full left-0 mb-2"
        }.freeze

        def initialize(
          text:,
          style: :default,
          size: :md,
          icon: nil,
          show_chevron: true,
          disabled: false,
          position: :bottom_right,
          max_height: "384px",
          trigger_attributes: {},
          **system_arguments
        )
          super(**system_arguments)
          @text = text
          @style = style.to_sym
          @size = size.to_sym
          @icon = icon
          @show_chevron = show_chevron
          @disabled = disabled
          @position = position.to_sym
          @max_height = max_height
          @trigger_attributes = sanitize_args(trigger_attributes)

          validate_position!
        end

        def menu_item(**kwargs, &block)
          set_polymorphic_slot(:menu, :item, **kwargs, &block)
        end

        def menu_divider(**kwargs, &block)
          set_polymorphic_slot(:menu, :divider, **kwargs, &block)
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
            controller: "flat-pack--button-dropdown",
            flat_pack__button_dropdown_max_height_value: @max_height
          }
        end

        def button_attributes
          attrs = @trigger_attributes.dup

          {
            class: TailwindMerge::Merger.new.merge([attrs.delete(:class), attrs.delete("class"), button_classes].compact.join(" ")),
            aria: extract_nested_attributes(attrs, :aria).merge(
              haspopup: "true",
              expanded: "false"
            ),
            data: extract_nested_attributes(attrs, :data).merge(
              flat_pack__button_dropdown_target: "trigger",
              action: "click->flat-pack--button-dropdown#toggle"
            )
          }.merge(attrs).compact
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
          content << content_tag(:span, @text) if @text.present?
          content << chevron_icon if @show_chevron
          safe_join(content)
        end

        def chevron_icon
          content_tag(:svg,
            class: "h-4 w-4 transition-transform duration-200",
            data: {flat_pack__button_dropdown_target: "chevron"},
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
              flat_pack__button_dropdown_target: "menu"
            }
          }
        end

        def menu_classes
          classes(
            "absolute z-50",
            "min-w-[12rem]",
            "overflow-auto",
            "rounded-md",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
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

        def extract_nested_attributes(attrs, key)
          (attrs.delete(key) || {}).merge(attrs.delete(key.to_s) || {})
        end
      end
    end
  end
end
