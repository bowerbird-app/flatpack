# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      class Component < FlatPack::BaseComponent
        renders_many :menu, types: {
          item: FlatPack::Button::DropdownItem::Component,
          divider: FlatPack::Button::DropdownDivider::Component,
          html: ->(body) { body }
        }

        undef_method :with_menu_item, :with_menu_divider, :with_menu_html
        undef_method :with_menu_item_content, :with_menu_divider_content, :with_menu_html_content

        ICON_VARIANTS = IconOptions::VARIANTS
        ICON_STYLES = IconOptions::STYLES
        PUBLIC_SIZES = FlatPack::Button::Component::PUBLIC_SIZES

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
          round: false,
          icon: nil,
          icon_variant: nil,
          icon_style: nil,
          icon_only: false,
          show_chevron: nil,
          chevron: "chevron-down",
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
          @chevron = normalize_chevron!(chevron)
          @show_chevron = resolved_chevron(show_chevron)
          @disabled = disabled
          @placement = placement.to_sym
          @max_height = max_height
          @trigger_attributes = sanitize_args(trigger_attributes)

          validate_style!
          validate_placement!
          validate_round!
          validate_size!
          validate_icon_only!
        end

        def menu_item(**kwargs, &block)
          set_polymorphic_slot(:menu, :item, **kwargs, &block)
        end

        def menu_divider(**kwargs, &block)
          set_polymorphic_slot(:menu, :divider, **kwargs, &block)
        end

        # Already-rendered menu body. Button Group uses this for each overflow
        # child's menu_row. The string is placed in the menu as given.
        def menu_html(body)
          set_polymorphic_slot(:menu, :html, body)
        end

        # Phone row for a collapsing button group. The wide control stays a dropdown.
        def menu_row
          render(FlatPack::Menu::Collapse::Component.new(title: @text, icon: @icon)) do |section|
            section.items do
              safe_join(menu.map { |item| menu_collapse_item(item.menu_row) })
            end
          end
        end

        private

        def wrapper_attributes
          merge_attributes(
            class: wrapper_classes,
            data: dropdown_data_attributes
          )
        end

        def wrapper_classes
          classes("fp-button-dropdown", "relative inline-block")
        end

        def dropdown_data_attributes
          {
            controller: "flat-pack--button-dropdown",
            flat_pack__button_dropdown_max_height_value: @max_height,
            flat_pack__button_dropdown_placement_value: @placement
          }
        end

        def render_trigger_button
          button = FlatPack::Button::Component.new(**trigger_button_arguments)
          button.with_trailing { chevron_icon } if @show_chevron
          render(button)
        end

        # The trigger is a Button. Callers still pass the dropdown kwargs.
        # fp-button-dropdown__trigger stays so a joined group can reach the radius.
        def trigger_button_arguments
          attrs = @trigger_attributes.dup
          extra_class = [attrs.delete(:class), attrs.delete("class")].compact
          extra_data = extract_nested_attributes(attrs, :data)
          extra_aria = extract_nested_attributes(attrs, :aria)
          title = attrs.delete(:title) || attrs.delete("title")
          type = attrs.delete(:type) || attrs.delete("type") || "button"

          {
            text: @text.presence,
            style: @style,
            size: @size,
            round: @round,
            icon: @icon,
            icon_variant: @icon_variant,
            icon_style: @icon_style,
            icon_only: @icon_only,
            disabled: @disabled,
            type: type,
            title: title,
            class: ["fp-button-dropdown__trigger", *extra_class].compact.join(" "),
            aria: extra_aria.merge(haspopup: "true", expanded: "false"),
            data: extra_data.merge(
              flat_pack__button_dropdown_target: "trigger",
              action: "click->flat-pack--button-dropdown#toggle"
            )
          }.merge(attrs)
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
          options = {name: @chevron, size: :sm}
          if chevron_rotates?
            options[:class] = "transition-transform duration-[var(--duration-base)] ease-[var(--easing-standard)]"
            options[:data] = {flat_pack__button_dropdown_target: "chevron"}
          end

          render FlatPack::Shared::IconComponent.new(**options)
        end

        def chevron_rotates?
          @chevron.tr("_", "-") == "chevron-down"
        end

        def normalize_chevron!(icon)
          return "chevron-down" if icon.nil? || icon == ""
          return icon.to_s if icon.is_a?(String) || icon.is_a?(Symbol)

          raise ArgumentError, "chevron must be a string"
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

        def resolved_chevron(show_chevron)
          if @icon_only && show_chevron == true
            raise ArgumentError, "Icon-only dropdowns hide the chevron. Omit show_chevron or pass false."
          end

          return !@icon_only if show_chevron.nil?

          show_chevron
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

        def validate_size!
          FlatPack::Button::Component.validate_size!(@size, icon_only: @icon_only)
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

        def menu_collapse_item(row)
          return content_tag(:div, "", class: "fp-menu-collapse__divider", role: "separator") if row[:divider]

          body = menu_collapse_body(row)
          attributes = {class: "fp-menu-collapse__item"}
          attributes[:data] = {fp_style: "danger"} if row[:destructive]
          return link_to(body, row[:href], **attributes) if row[:href].present? && !row[:disabled]

          attributes[:type] = "button"
          attributes[:disabled] = true if row[:disabled]
          button_tag(body, **attributes)
        end

        def menu_collapse_body(row)
          label = content_tag(:span, row[:label].to_s)
          return label if row[:icon].blank?

          safe_join([
            render(FlatPack::Shared::IconComponent.new(name: row[:icon], size: :sm)),
            label
          ])
        end

        def extract_nested_attributes(attrs, key)
          (attrs.delete(key) || {}).merge(attrs.delete(key.to_s) || {})
        end
      end
    end
  end
end
