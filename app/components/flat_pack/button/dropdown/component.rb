# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      class Component < FlatPack::BaseComponent
        renders_one :trigger_label

        renders_many :menu, types: {
          item: FlatPack::Button::DropdownItem::Component,
          divider: FlatPack::Button::DropdownDivider::Component,
          html: ->(body) { body },
          form: FlatPack::Button::Dropdown::FormPanel
        }

        undef_method :with_menu_item, :with_menu_divider, :with_menu_html, :with_menu_form
        undef_method :with_menu_item_content, :with_menu_divider_content, :with_menu_html_content, :with_menu_form_content

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
          menu_class: nil,
          menu_attributes: {},
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
          @menu_class = menu_class
          @host_menu_attributes = sanitize_args(menu_attributes)

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

        # Form body in the menu. Not a menuitem. Stays open on interaction.
        def menu_form(**kwargs, &block)
          @menu_contains_form = true
          set_polymorphic_slot(:menu, :form, **kwargs, &block)
        end

        # Phone row for a collapsing button group. The wide control stays a dropdown.
        def menu_row
          render(FlatPack::Menu::Collapse::Component.new(title: @text, icon: @icon)) do |section|
            section.items do
              safe_join(menu.filter_map { |item|
                next unless item.respond_to?(:menu_row)

                row = item.menu_row
                next if row[:skip]

                menu_collapse_item(row)
              })
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

        # Keys that belong to the dropdown (and to Button). A host used to pass
        # these on the raw trigger as HTML attributes. Forwarding them into
        # Button.new would replace the dropdown's own options and can raise.
        TRIGGER_HTML_ONLY_KEYS = %i[
          style size text icon icon_variant icon_style icon_only
          round loading align lines current href method target
        ].freeze

        # The trigger is a Button. Callers still pass the dropdown kwargs.
        # fp-button-dropdown__trigger stays so a joined group can reach the radius.
        # The chevron is Button's trailing slot, so the icon sits in an extra span.
        def trigger_button_arguments
          attrs = @trigger_attributes.dup
          extra_class = [attrs.delete(:class), attrs.delete("class")].compact
          extra_data = extract_nested_attributes(attrs, :data)
          extra_aria = extract_nested_attributes(attrs, :aria)
          title = attrs.delete(:title) || attrs.delete("title")
          type = attrs.delete(:type) || attrs.delete("type") || "button"
          TRIGGER_HTML_ONLY_KEYS.each do |key|
            attrs.delete(key)
            attrs.delete(key.to_s)
          end

          {
            text: trigger_button_text,
            style: @style,
            size: @size,
            round: @round,
            icon: @icon,
            icon_variant: @icon_variant,
            icon_style: @icon_style,
            icon_only: @icon_only,
            disabled: @disabled,
            type: type,
            title: title.is_a?(String) ? title : nil,
            class: ["fp-button-dropdown__trigger", *extra_class].compact.join(" "),
            aria: extra_aria.merge(haspopup: trigger_popup, expanded: "false"),
            data: extra_data.merge(
              flat_pack__button_dropdown_target: "trigger",
              action: "click->flat-pack--button-dropdown#toggle"
            )
          }.merge(attrs.compact)
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

        def trigger_button_text
          return trigger_label if trigger_label?

          @text.presence
        end

        def menu_attributes
          host = @host_menu_attributes.dup
          host_class = [host.delete(:class), host.delete("class")]
          host_data = extract_nested_attributes(host, :data)
          host_aria = extract_nested_attributes(host, :aria)
          dropped_role = host.delete(:role) || host.delete("role")
          warn_dropped_menu_role(dropped_role)
          host_style = host.delete(:style) || host.delete("style")

          {
            class: menu_classes(*host_class),
            role: menu_role,
            aria: menu_aria(host_aria),
            style: join_styles("--dropdown-max-height: #{@max_height};", host_style),
            data: merge_data_attributes(
              host_data,
              {flat_pack__button_dropdown_target: "menu"}
            )
          }.merge(host)
        end

        def menu_role
          menu_contains_form? ? "dialog" : "menu"
        end

        def menu_aria(host_aria)
          aria = host_aria.merge(hidden: "true")
          return aria unless menu_contains_form?

          {label: menu_dialog_name, modal: "false"}.merge(aria)
        end

        def menu_dialog_name
          @text.to_s.strip.presence || explicit_aria_label.presence || "Menu"
        end

        def menu_contains_form?
          @menu_contains_form == true
        end

        def trigger_popup
          menu_contains_form? ? "dialog" : "true"
        end

        def render_menu_entries
          mark_dialog_items! if menu_contains_form?

          safe_join(menu)
        end

        # The dialog flag stays on this dropdown's own items. A Dropdown nested
        # inside menu_form is a different instance and keeps role=menu.
        def mark_dialog_items!
          menu.each do |entry|
            next unless entry.respond_to?(:plain_actions=)

            entry.plain_actions = true
          end
        end

        def warn_dropped_menu_role(role)
          return if role.blank?
          return unless development_log?

          Rails.logger.warn(
            "[FlatPack::Button::Dropdown] Dropped menu_attributes role=#{role.inspect}. " \
            "The panel role is #{menu_role.inspect}."
          )
        end

        def development_log?
          defined?(Rails) && Rails.respond_to?(:env) && Rails.env.development?
        end

        def menu_classes(*extra)
          classes(
            "fixed z-50",
            "min-w-[12rem]",
            "overflow-auto",
            "rounded-[var(--menu-radius)]",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "p-[var(--dropdown-padding)]",
            "shadow-lg",
            "fp-button-dropdown__menu",
            "opacity-0 scale-95 motion-reduce:scale-100 hidden",
            "transition-[opacity,transform] duration-[var(--duration-base)] ease-[var(--easing-enter)]",
            @menu_class,
            *extra
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

          icon_arguments = {name: row[:icon], size: :sm}
          icon_arguments[:class] = "ms-auto" if row[:icon_position] == :end
          icon = render(FlatPack::Shared::IconComponent.new(**icon_arguments))
          return safe_join([label, icon]) if row[:icon_position] == :end

          safe_join([icon, label])
        end

        def extract_nested_attributes(attrs, key)
          (attrs.delete(key) || {}).merge(attrs.delete(key.to_s) || {})
        end
      end
    end
  end
end
