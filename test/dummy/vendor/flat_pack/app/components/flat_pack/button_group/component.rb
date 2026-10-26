# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(component = nil, overflow: nil) { record_child(component, overflow) }

      undef_method :with_button, :with_button_content

      # false keeps the row. :menu is that row from collapse_at up and a
      # disclosure below it. No label: the bars glyph alone. A label: that
      # word, then a trailing icon. The row and the menu are separate elements.
      COLLAPSES = [false, :menu].freeze
      # :joined merges direct children into one control. :outlined is a bordered
      # container on the wide row. The phone menu does not use the container.
      VARIANTS = [:joined, :outlined].freeze
      DEFAULT_COLLAPSE_AT = 768
      DEFAULT_MENU_ICON = "menu"
      OVERFLOW_ICON = "ellipsis-horizontal"
      OVERFLOW_CHEVRON = "chevron-down"

      def initialize(
        variant: :joined,
        style: :default,
        collapse: false,
        menu_label: nil,
        menu_icon: nil,
        collapse_at: DEFAULT_COLLAPSE_AT,
        visible: nil,
        overflow_label: nil,
        overflow_icon: nil,
        **system_arguments
      )
        @variant = normalize_variant!(variant)
        @style = normalize_style!(style)
        @collapse = normalize_collapse!(collapse)
        @menu_label = normalize_menu_label!(menu_label)
        @menu_icon = normalize_menu_icon!(menu_icon)
        @collapse_at = normalize_collapse_at!(collapse_at)
        @visible = normalize_visible!(visible)
        @overflow_label = normalize_overflow_label!(overflow_label)
        @overflow_icon = normalize_overflow_icon!(overflow_icon)
        @child_overflow = []
        super(**system_arguments)
      end

      def button(component = nil, overflow: nil, &block)
        set_slot(:buttons, nil, component, overflow: overflow, &block)
      end

      private

      def collapse_menu?
        @collapse == :menu
      end

      def group_attributes
        merge_attributes(
          class: group_classes,
          data: {variant: @variant}.merge(outlined_style_data)
        )
      end

      def group_classes
        if outlined?
          return classes("fp-button-group", "fp-button-group--outlined", "inline-flex")
        end

        classes(
          "fp-button-group",
          "inline-flex",
          "rounded-[var(--radius-md)]",
          "shadow-sm",
          "[&>*]:rounded-none",
          "[&>*:first-child]:rounded-l-[var(--radius-md)]",
          "[&>*:last-child]:rounded-r-[var(--radius-md)]",
          "[&>*]:border-r-0",
          "[&>*:last-child]:border-r",
          "[&>*]:shadow-none"
        )
      end

      def menu_root_attributes
        attributes = merge_attributes(class: "fp-button-group-menu", data: {variant: @variant})
        attributes[:data] = merge_data_attributes(
          attributes[:data],
          {
            controller: "flat-pack--button-group-menu",
            open: "false",
            collapse_at: @collapse_at
          }
        )
        attributes
      end

      def row_attributes
        attributes = {
          class: row_classes,
          role: "group",
          aria: {label: group_label}
        }
        style_data = outlined_style_data
        attributes[:data] = style_data if style_data.any?
        attributes
      end

      def row_classes
        names = ["fp-button-group-menu__row"]
        names << "fp-button-group--outlined" if outlined?
        names.join(" ")
      end

      def panel_attributes
        {
          id: panel_id,
          class: "fp-button-group-menu__panel",
          role: "group",
          aria: {label: group_label},
          data: {flat_pack__button_group_menu_target: "panel"}
        }
      end

      # No label: the icon alone, named with the locale string. A label: that
      # text, then the icon in the button's trailing slot. No leading icon.
      def menu_trigger
        button = FlatPack::Button::Component.new(**menu_trigger_options)
        if @menu_label.present?
          button.with_trailing do
            render FlatPack::Shared::IconComponent.new(name: menu_icon_name, size: :sm)
          end
        end
        render(button)
      end

      def menu_trigger_options
        options = {
          style: :secondary,
          type: "button",
          class: "fp-button-group-menu__trigger",
          aria: trigger_aria,
          data: {
            flat_pack__button_group_menu_target: "trigger",
            action: "click->flat-pack--button-group-menu#toggle"
          }
        }
        if @menu_label.present?
          options[:text] = @menu_label
        else
          options[:icon] = menu_icon_name
          options[:icon_only] = true
        end
        options
      end

      def menu_icon_name
        return @menu_icon if @menu_icon

        @menu_label.present? ? OVERFLOW_CHEVRON : DEFAULT_MENU_ICON
      end

      def trigger_aria
        aria = {
          expanded: "false",
          controls: panel_id,
          haspopup: "true"
        }
        aria[:label] = group_label if @menu_label.blank?
        aria
      end

      def group_label
        @menu_label.presence || fp_t("button_group.menu")
      end

      def panel_id
        @panel_id ||= "button-group-menu-#{SecureRandom.hex(6)}"
      end

      def collapse_stylesheet
        content_tag(:style, collapse_css.html_safe)
      end

      # The breakpoint is a caller pixel value, so it cannot live in the
      # scanned stylesheet. Below it, the row is hidden and the panel is the
      # menu. This block is the wide layout and wins over those rules.
      def collapse_css
        outlined? ? outlined_collapse_css : joined_collapse_css
      end

      def joined_collapse_css
        pixels = @collapse_at
        <<~CSS
          @media (min-width: #{pixels}px) {
            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__trigger {
              display: none;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row {
              display: inline-flex;
              align-items: stretch;
              gap: 0;
              border-radius: var(--radius-md);
              box-shadow: var(--shadow-sm);
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row > * {
              width: auto;
              border-radius: 0;
              box-shadow: none;
              border-right-width: 0;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row > :first-child {
              border-top-left-radius: var(--radius-md);
              border-bottom-left-radius: var(--radius-md);
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row > :last-child {
              border-top-right-radius: var(--radius-md);
              border-bottom-right-radius: var(--radius-md);
              border-right-width: 1px;
            }

            /* A dropdown root has no border color of its own. Preflight would
               paint this width in currentColor, a dark line outside the trigger. */
            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row > .fp-button-dropdown {
              border-width: 0;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel {
              display: none;
            }
          }
        CSS
      end

      # Wide layout only. Below collapse_at the phone menu is unchanged, and
      # this block does not restyle the children.
      def outlined_collapse_css
        pixels = @collapse_at
        <<~CSS
          @media (min-width: #{pixels}px) {
            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__trigger {
              display: none;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__row {
              display: inline-flex;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel {
              display: none;
            }
          }
        CSS
      end

      # First `visible` children stay in the row. `overflow: true` and
      # `overflow: false` win over that count. Relative order is kept.
      def row_slots
        partition.fetch(:row)
      end

      def overflow_slots
        partition.fetch(:overflow)
      end

      def partition
        @partition ||= begin
          row = []
          overflow = []
          buttons.each_with_index do |slot, index|
            if show_in_row?(index)
              row << slot
            else
              overflow << slot
            end
          end
          {row: row, overflow: overflow}
        end
      end

      def show_in_row?(index)
        case @child_overflow[index]
        when true then false
        when false then true
        else @visible.nil? || index < @visible
        end
      end

      def overflow_dropdown
        slots = overflow_slots
        return if slots.empty?

        dropdown = FlatPack::Button::Dropdown::Component.new(
          **overflow_trigger_options,
          style: overflow_trigger_style,
          size: :sm,
          class: "fp-button-group__overflow"
        )
        slots.each { |slot| dropdown.menu_html(menu_entry(slot)) }
        render(dropdown)
      end

      # No label: the icon alone, named with the locale string. A label: that
      # text, then the icon, in the dropdown's trailing slot.
      def overflow_trigger_options
        icon = overflow_icon_name
        if @overflow_label.present?
          {text: @overflow_label, show_chevron: true, chevron: icon}
        else
          {text: fp_t("button_group.overflow"), icon: icon, icon_only: true, show_chevron: false}
        end
      end

      def overflow_icon_name
        return @overflow_icon if @overflow_icon

        @overflow_label.present? ? OVERFLOW_CHEVRON : OVERFLOW_ICON
      end

      # Rendering the child once gives it a view context and runs its own slot
      # block. The wide row uses that HTML. A menu uses menu_row when it returns
      # HTML, and the same render otherwise.
      def rendered_child(slot)
        @rendered_children ||= {}
        @rendered_children[slot] ||= slot.to_s
      end

      def menu_entry(slot)
        rendered_child(slot)

        if slot.respond_to?(:menu_row)
          row = slot.menu_row
          return row if row.respond_to?(:to_str)
        end

        rendered_child(slot)
      end

      def record_child(component, overflow)
        raise ArgumentError, "button group needs a child" if component.nil?

        @child_overflow << normalize_overflow!(overflow)
        component
      end

      def outlined?
        @variant == :outlined
      end

      def outlined_style_data
        return {} unless outlined?

        {fp_style: @style.to_s}
      end

      def overflow_trigger_style
        outlined? ? :ghost : :secondary
      end

      def normalize_variant!(value)
        return :joined if value.nil?
        return value.to_sym if (value.is_a?(Symbol) || value.is_a?(String)) && VARIANTS.include?(value.to_sym)

        raise ArgumentError, "variant must be :joined or :outlined"
      end

      def normalize_style!(style)
        name = style.nil? ? :default : style.to_sym
        return name if FlatPack::Button::StyleRegistry.known?(name)

        raise ArgumentError, FlatPack::Button::StyleRegistry.invalid_style_message(name)
      end

      def normalize_collapse!(value)
        return false if value == false
        return :menu if (value.is_a?(Symbol) || value.is_a?(String)) && value.to_sym == :menu

        raise ArgumentError, "collapse must be false or :menu"
      end

      def normalize_menu_label!(label)
        validate_text_option!(label, name: :menu_label)
        label.presence
      end

      def normalize_menu_icon!(icon)
        return if icon.nil? || icon == ""
        return icon.to_s if icon.is_a?(String) || icon.is_a?(Symbol)

        raise ArgumentError, "menu_icon must be a string"
      end

      def normalize_collapse_at!(value)
        text = value.to_s
        return text.to_i if text.match?(/\A[1-9]\d*\z/)

        raise ArgumentError, "collapse_at must be a positive number of pixels"
      end

      def normalize_visible!(value)
        return if value.nil?
        return value if value.is_a?(Integer) && value >= 0

        raise ArgumentError, "visible must be a whole number"
      end

      def normalize_overflow_label!(label)
        validate_text_option!(label, name: :overflow_label)
        label.presence
      end

      def normalize_overflow_icon!(icon)
        return if icon.nil? || icon == ""
        return icon.to_s if icon.is_a?(String) || icon.is_a?(Symbol)

        raise ArgumentError, "overflow_icon must be a string"
      end

      def normalize_overflow!(value)
        return if value.nil?
        return value if value == true || value == false

        raise ArgumentError, "overflow must be true or false"
      end
    end
  end
end
