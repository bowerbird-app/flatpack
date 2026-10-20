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

        ICON_VARIANTS = IconOptions::VARIANTS
        ICON_STYLES = IconOptions::STYLES

        PLACEMENTS = {
          bottom_right: "top-full right-0 mt-2",
          bottom_left: "top-full left-0 mt-2",
          top_right: "bottom-full right-0 mb-2",
          top_left: "bottom-full left-0 mb-2"
        }.freeze

        CHEVRON_UNSET = Object.new.freeze
        private_constant :CHEVRON_UNSET

        def self.new(show_chevron: CHEVRON_UNSET, icon_only: false, **kwargs, &block)
          if icon_only && show_chevron == true
            raise ArgumentError, "Icon-only dropdowns hide the chevron. Omit show_chevron or pass false."
          end

          super(icon_only: icon_only, show_chevron: resolved_chevron(show_chevron, icon_only), **kwargs, &block)
        end

        def self.resolved_chevron(show_chevron, icon_only)
          return !icon_only if show_chevron.equal?(CHEVRON_UNSET)

          show_chevron
        end
        private_class_method :resolved_chevron

        def initialize(
          text:,
          style: :default,
          size: :md,
          round: false,
          icon: nil,
          icon_variant: nil,
          icon_style: nil,
          icon_only: false,
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
          @round = round
          @icon = icon
          @icon_variant = IconOptions.normalize_variant!(icon_variant)
          @icon_style = IconOptions.normalize_style!(icon_style)
          @icon_only = icon_only
          @show_chevron = show_chevron
          @disabled = disabled
          @placement = placement.to_sym
          @max_height = max_height
          @trigger_attributes = sanitize_args(trigger_attributes)

          validate_style!
          validate_placement!
          validate_round!
          validate_icon_only!
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
            aria: trigger_aria(attrs),
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
            trigger_radius_class,
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

          size_classes = trigger_size_classes
          base_classes << size_classes if size_classes
          base_classes << icon_only_classes if @icon_only
          base_classes.join(" ")
        end

        def trigger_radius_class
          if @round
            FlatPack::Button::Component::ROUND_RADIUS_CLASS
          else
            "rounded-[var(--button-border-radius)]"
          end
        end

        def trigger_size_classes
          return if @icon_only

          FlatPack::Button::Component::SIZES.fetch(@size)
        end

        def icon_only_classes
          [
            FlatPack::Button::Component::ICON_ONLY_SIZES.fetch(@size),
            round_icon_only_size_class,
            "fp-hit-target"
          ].compact.join(" ")
        end

        def round_icon_only_size_class
          return unless @round

          FlatPack::Button::Component::ROUND_ICON_ONLY_SIZES.fetch(@size)
        end

        def button_content
          content = []
          if @icon
            content << render(FlatPack::Shared::IconComponent.new(
              **IconOptions.component_arguments(
                name: @icon,
                size: @size,
                icon_variant: @icon_variant,
                icon_style: @icon_style
              )
            ))
          end
          content << content_tag(:span, @text) if @text.present? && !@icon_only
          content << chevron_icon if @show_chevron
          safe_join(content)
        end

        def trigger_aria(attrs)
          aria = extract_nested_attributes(attrs, :aria)
          label = derived_icon_only_label
          aria[:label] = label if label.present?
          aria.merge(haspopup: "true", expanded: "false")
        end

        def derived_icon_only_label
          return unless @icon_only
          return if explicit_aria_label.present?

          @text.presence
        end

        def explicit_aria_label
          aria = @trigger_attributes[:aria] || @trigger_attributes["aria"] || {}
          aria[:label].presence || aria["label"].presence
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
            "rounded-[var(--menu-radius)]",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "p-[var(--dropdown-padding)]",
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

        def validate_round!
          return if @round == true || @round == false

          raise ArgumentError, "Invalid round: #{@round.inspect}. Must be true or false."
        end

        def validate_icon_only!
          return unless @icon_only

          if @icon.blank?
            raise ArgumentError, "Icon-only dropdowns need an icon. Pass icon:."
          end

          return if icon_only_accessible_name.present?

          raise ArgumentError, "Icon-only buttons need an accessible name. " \
            'Pass text: or trigger_attributes: { aria: { label: "Save" } }.'
        end

        def icon_only_accessible_name
          explicit_aria_label.presence || @text.presence
        end

        def extract_nested_attributes(attrs, key)
          (attrs.delete(key) || {}).merge(attrs.delete(key.to_s) || {})
        end
      end
    end
  end
end
