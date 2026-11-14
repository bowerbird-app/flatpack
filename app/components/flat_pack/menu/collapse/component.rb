# frozen_string_literal: true

module FlatPack
  module Menu
    module Collapse
      class Component < FlatPack::BaseComponent
        ICON_VARIANTS = FlatPack::Button::IconOptions::VARIANTS
        ICON_STYLES = FlatPack::Button::IconOptions::STYLES

        renders_one :items_slot

        undef_method :with_items_slot, :with_items_slot_content

        def initialize(title:, icon: nil, icon_variant: nil, icon_style: nil, open: false, **system_arguments)
          super(**system_arguments)
          @title = title
          @icon = icon
          @icon_variant = FlatPack::Button::IconOptions.normalize_variant!(icon_variant)
          @icon_style = FlatPack::Button::IconOptions.normalize_style!(icon_style)
          @open = open
          @panel_id = "menu-collapse-#{SecureRandom.hex(6)}"
        end

        def items(**args, &block)
          return items_slot unless block

          set_slot(:items_slot, nil, **args, &block)
        end

        def items?
          items_slot?
        end

        def call
          content_tag(:div, **root_attributes) do
            safe_join([render_header, render_panel])
          end
        end

        private

        def render_header
          content_tag(:button, **header_button_attributes) do
            safe_join([render_icon, render_label, render_chevron].compact)
          end
        end

        def render_panel
          content_tag(:div, **panel_attributes) do
            content_tag(:div, items? ? items.to_s : "", class: "fp-menu-collapse__items")
          end
        end

        def render_icon
          return if @icon.blank?

          content_tag(:span, class: "fp-menu-collapse__icon") do
            render FlatPack::Shared::IconComponent.new(
              **FlatPack::Button::IconOptions.component_arguments(
                name: @icon,
                size: :sm,
                icon_variant: @icon_variant,
                icon_style: @icon_style
              )
            )
          end
        end

        def render_label
          content_tag(:span, @title, class: "fp-menu-collapse__label")
        end

        def render_chevron
          content_tag(:span, class: "fp-menu-collapse__chevron", data: {flat_pack__menu_collapse_target: "chevron"}) do
            render FlatPack::Shared::IconComponent.new(name: :chevron_down, size: :sm)
          end
        end

        def root_attributes
          attributes = merge_attributes(class: "fp-menu-collapse")
          attributes[:data] = merge_data_attributes(attributes[:data], root_data)
          attributes
        end

        def root_data
          {
            controller: "flat-pack--menu-collapse",
            flat_pack__menu_collapse_open_value: @open ? "true" : "false",
            open: @open ? "true" : "false"
          }
        end

        def header_button_attributes
          {
            type: "button",
            class: "fp-menu-collapse__button",
            aria: {expanded: @open.to_s, controls: @panel_id},
            data: {
              flat_pack__menu_collapse_target: "button",
              action: "click->flat-pack--menu-collapse#toggle"
            }
          }
        end

        def panel_attributes
          attributes = {
            id: @panel_id,
            class: "fp-menu-collapse__panel",
            data: {flat_pack__menu_collapse_target: "panel"}
          }
          attributes[:hidden] = true unless @open
          attributes
        end
      end
    end
  end
end
