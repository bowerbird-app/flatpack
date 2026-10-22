# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(component) { component }

      undef_method :with_button, :with_button_content

      # false keeps the joined row. :menu is that row from collapse_at up and a
      # hamburger disclosure below it. The row and the menu are separate elements.
      COLLAPSES = [false, :menu].freeze
      DEFAULT_COLLAPSE_AT = 768
      DEFAULT_MENU_ICON = "menu"

      def initialize(collapse: false, menu_label: nil, menu_icon: DEFAULT_MENU_ICON, collapse_at: DEFAULT_COLLAPSE_AT, **system_arguments)
        @collapse = normalize_collapse!(collapse)
        @menu_label = normalize_menu_label!(menu_label)
        @menu_icon = normalize_menu_icon!(menu_icon)
        @collapse_at = normalize_collapse_at!(collapse_at)
        super(**system_arguments)
      end

      def button(*args, &block)
        set_slot(:buttons, nil, *args, &block)
      end

      private

      def collapse_menu?
        @collapse == :menu
      end

      def group_attributes
        merge_attributes(
          class: group_classes
        )
      end

      def group_classes
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
        attributes = merge_attributes(class: "fp-button-group-menu")
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
        {
          class: "fp-button-group-menu__row",
          role: "group",
          aria: {label: group_label}
        }
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

      def menu_trigger
        options = {
          icon: @menu_icon,
          icon_only: @menu_label.blank?,
          style: :secondary,
          type: "button",
          class: "fp-button-group-menu__trigger",
          aria: trigger_aria,
          data: {
            flat_pack__button_group_menu_target: "trigger",
            action: "click->flat-pack--button-group-menu#toggle"
          }
        }
        options[:text] = @menu_label if @menu_label.present?

        render(FlatPack::Button::Component.new(**options))
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

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel {
              display: none;
            }
          }
        CSS
      end

      # The wide row renders the child. The phone menu renders menu_row when
      # that method returns HTML. Anything else is the same render again.
      def rendered_child(slot)
        @rendered_children ||= {}
        @rendered_children[slot] ||= slot.to_s
      end

      def menu_entry(slot)
        if slot.respond_to?(:menu_row)
          row = slot.menu_row
          return row if row.respond_to?(:to_str)
        end

        rendered_child(slot)
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
        return DEFAULT_MENU_ICON if icon.nil? || icon == ""
        return icon.to_s if icon.is_a?(String) || icon.is_a?(Symbol)

        raise ArgumentError, "menu_icon must be a string"
      end

      def normalize_collapse_at!(value)
        text = value.to_s
        return text.to_i if text.match?(/\A[1-9]\d*\z/)

        raise ArgumentError, "collapse_at must be a positive number of pixels"
      end
    end
  end
end
