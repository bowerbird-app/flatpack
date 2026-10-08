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

        PLACEMENTS = {
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
          placement: :bottom_right,
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
          @placement = placement.to_sym
          @max_height = max_height
          @trigger_attributes = sanitize_args(trigger_attributes)

          validate_style!
          validate_placement!
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
            flat_pack__button_dropdown_max_height_value: @max_height,
            flat_pack__button_dropdown_placement_value: @placement
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
              action: "click->flat-pack--button-dropdown#toggle",
              fp_style: @style.to_s
            )
          }.merge(attrs).compact
        end

        def button_classes
          base_classes = [
            "inline-flex items-center justify-center gap-2",
            "rounded-[var(--button-border-radius)]",
            "font-medium",
            "cursor-pointer",
            "fp-button",
            FlatPack::Button::StyleRegistry.press_class(@style),
            "border",
            "transition-[color,background-color,border-color,box-shadow,transform] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]",
            "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)]",
            "fp-touch-manipulation"
          ]

          base_classes << FlatPack::Button::Component::SIZES.fetch(@size)
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
          render FlatPack::Shared::IconComponent.new(
            name: "chevron-down",
            size: :sm,
            class: "transition-transform duration-[var(--duration-base)] ease-[var(--easing-standard)]",
            data: {flat_pack__button_dropdown_target: "chevron"}
          )
        end

        def menu_attributes
          {
            class: menu_classes,
            role: "menu",
            aria: {hidden: "true"},
            style: "max-height: #{@max_height};",
            data: {
              flat_pack__button_dropdown_target: "menu"
            }
          }
        end

        def menu_classes
          classes(
            "fixed z-50",
            "min-w-[12rem]",
            "overflow-auto",
            "rounded-[var(--radius-md)]",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "p-1",
            "shadow-lg",
            "opacity-0 scale-95 motion-reduce:scale-100 hidden",
            "transition-[opacity,transform] duration-[var(--duration-base)] ease-[var(--easing-enter)]"
          )
        end

        def validate_style!
          return if FlatPack::Button::StyleRegistry.known?(@style)

          raise ArgumentError, FlatPack::Button::StyleRegistry.invalid_style_message(@style)
        end

        def validate_placement!
          return if PLACEMENTS.key?(@placement)

          raise ArgumentError,
            "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.keys.join(", ")}"
        end

        def extract_nested_attributes(attrs, key)
          (attrs.delete(key) || {}).merge(attrs.delete(key.to_s) || {})
        end
      end
    end
  end
end
