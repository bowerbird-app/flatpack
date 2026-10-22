# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(component) { component }

      undef_method :with_button, :with_button_content

      # false keeps the joined row. :menu is a row from collapse_at up and a
      # hamburger disclosure below it. The panel is one element either way.
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
      # scanned stylesheet. Mobile rules are in application.css. This block
      # is the wide layout and wins over those rules.
      def collapse_css
        pixels = @collapse_at
        <<~CSS
          @media (min-width: #{pixels}px) {
            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__trigger {
              display: none;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel {
              display: inline-flex;
              position: static;
              z-index: auto;
              inset-inline: auto;
              top: auto;
              flex-direction: row;
              align-items: stretch;
              gap: 0;
              width: auto;
              min-width: 0;
              max-width: none;
              margin: 0;
              padding: 0;
              border: 0;
              border-radius: var(--radius-md);
              background: transparent;
              box-shadow: var(--shadow-sm);
              opacity: 1;
              transform: none;
              animation: none;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel > * {
              width: auto;
              border-radius: 0;
              box-shadow: none;
              border-right-width: 0;
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel > :first-child {
              border-top-left-radius: var(--radius-md);
              border-bottom-left-radius: var(--radius-md);
            }

            .fp-button-group-menu[data-collapse-at="#{pixels}"] > .fp-button-group-menu__panel > :last-child {
              border-top-right-radius: var(--radius-md);
              border-bottom-right-radius: var(--radius-md);
              border-right-width: 1px;
            }

            #{dropdown_trigger_css(".fp-button-group-menu[data-collapse-at=\"#{pixels}\"] > .fp-button-group-menu__panel")}
            #{inline_switch_css(".fp-button-group-menu[data-collapse-at=\"#{pixels}\"] > .fp-button-group-menu__panel")}
          }
        CSS
      end

      # The phone panel shows the inline section. From collapse_at up, the
      # dropdown is the segment and the inline section is not in the row.
      def inline_switch_css(scope)
        <<~CSS
          #{scope} .fp-button-group-menu__choice,
          #{scope} .fp-button-group-menu__dropdown {
            display: contents;
          }

          #{scope} .fp-button-group-menu__inline {
            display: none;
          }
        CSS
      end

      # The joined row styles each direct child. A dropdown's direct child is a
      # wrapper, and a host control may wrap that again, so the trigger is what
      # has to take the segment shape. Menu items are not triggers, and an open
      # menu is on document.body, outside this selector.
      def dropdown_trigger_css(scope)
        trigger = '[data-controller~="flat-pack--button-dropdown"] [data-flat-pack--button-dropdown-target="trigger"]'
        <<~CSS
          #{scope} #{trigger} {
            border-radius: 0;
            box-shadow: none;
            border-right-width: 0;
          }

          #{scope} > :first-child[data-controller~="flat-pack--button-dropdown"] [data-flat-pack--button-dropdown-target="trigger"],
          #{scope} > :first-child #{trigger} {
            border-top-left-radius: var(--radius-md);
            border-bottom-left-radius: var(--radius-md);
          }

          #{scope} > :last-child[data-controller~="flat-pack--button-dropdown"] [data-flat-pack--button-dropdown-target="trigger"],
          #{scope} > :last-child #{trigger} {
            border-top-right-radius: var(--radius-md);
            border-bottom-right-radius: var(--radius-md);
            border-right-width: 1px;
          }
        CSS
      end

      def panel_child(slot)
        return slot unless dropdown_slot?(slot)

        # The dropdown's menu block runs when the slot renders. Read the rows after that.
        rendered_dropdown = slot.to_s
        content_tag(:div, class: "fp-button-group-menu__choice") do
          safe_join([
            content_tag(:div, rendered_dropdown, class: "fp-button-group-menu__dropdown"),
            content_tag(:div, inline_section(slot), class: "fp-button-group-menu__inline")
          ])
        end
      end

      def dropdown_slot?(slot)
        slot.respond_to?(:menu_rows) && slot.respond_to?(:trigger_label)
      end

      def inline_section(slot)
        render(FlatPack::Menu::Collapse::Component.new(title: slot.trigger_label, icon: slot.trigger_icon)) do |section|
          section.items do
            safe_join(slot.menu_rows.map { |row| menu_row_tag(row) })
          end
        end
      end

      def menu_row_tag(row)
        return inline_divider if row[:divider]
        return link_to(row_body(row), row[:href], **row_attributes(row)) if row[:href].present? && !row[:disabled]

        button_tag(row_body(row), **row_attributes(row, type: "button"))
      end

      def inline_divider
        content_tag(:div, "", class: "fp-menu-collapse__divider", role: "separator")
      end

      def row_body(row)
        label = content_tag(:span, row[:label].to_s)
        return label if row[:icon].blank?

        safe_join([
          render(FlatPack::Shared::IconComponent.new(name: row[:icon], size: :sm)),
          label
        ])
      end

      def row_attributes(row, type: nil)
        attributes = {class: "fp-menu-collapse__item"}
        attributes[:type] = type if type
        attributes[:disabled] = true if type && row[:disabled]
        attributes[:data] = {fp_style: "danger"} if row[:destructive]
        attributes
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
