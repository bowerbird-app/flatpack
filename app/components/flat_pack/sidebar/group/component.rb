# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Group
      class Component < FlatPack::BaseComponent
        renders_one :items_slot

        def initialize(
          label:,
          icon: nil,
          default_open: false,
          collapsed: false,
          group_id: nil,
          **system_arguments
        )
          super(**system_arguments)
          @label = label
          @icon = icon
          @default_open = default_open
          @collapsed = collapsed
          @group_id = resolved_group_id(group_id)
        end

        def items(**args, &block)
          return items_slot unless block

          with_items_slot(**args, &block)
        end

        def items?
          items_slot?
        end

        def call
          content_tag(:div, **group_attributes) do
            safe_join([
              render_header,
              render_panel
            ].compact)
          end
        end

        private

        def render_header
          content_tag(:button, **header_button_attributes) do
            safe_join([
              render_icon,
              render_label,
              render_chevron,
              render_collapsed_tooltip
            ].compact)
          end
        end

        def render_collapsed_tooltip
          content_tag(:div, @label, **tooltip_attributes)
        end

        def render_panel
          return unless items?

          content_tag(:div, items.to_s, **panel_attributes)
        end

        def render_icon
          return unless @icon

          content_tag(:span, class: icon_wrapper_classes) do
            render FlatPack::Shared::IconComponent.new(
              name: @icon,
              size: :md
            )
          end
        end

        def render_label
          content_tag(:span, @label, class: label_classes)
        end

        def render_chevron
          content_tag(:span, class: chevron_wrapper_classes, data: chevron_data) do
            render FlatPack::Shared::IconComponent.new(
              name: :chevron_down,
              size: :sm
            )
          end
        end

        def group_attributes
          merge_attributes(
            class: group_classes,
            data: group_data
          )
        end

        def group_data
          {
            controller: "flat-pack--sidebar-group",
            "flat-pack--sidebar-group-default-open-value": @default_open,
            "flat-pack--sidebar-group-group-id-value": @group_id
          }
        end

        def resolved_group_id(explicit_group_id)
          raw_group_id = explicit_group_id.presence || @label.to_s
          normalized = raw_group_id.parameterize

          normalized.presence || "group"
        end

        def group_classes
          "my-1"
        end

        def header_button_attributes
          {
            class: header_button_classes,
            type: "button",
            data: header_button_data,
            aria: header_aria_attributes
          }
        end

        def header_button_classes
          classes(
            "flex",
            "items-center",
            "gap-3",
            "px-4",
            "py-2.5",
            "text-sm",
            "font-medium",
            "text-[var(--sidebar-item-text-color)]",
            "hover:bg-[var(--sidebar-item-hover-background-color)]",
            "hover:text-[var(--sidebar-item-hover-text-color)]",
            "transition-colors",
            "rounded-lg",
            "mx-2",
            "w-[calc(100%-1rem)]"
          )
        end

        def header_button_data
          {
            controller: "flat-pack--tooltip",
            action: "mouseenter->flat-pack--tooltip#show mouseleave->flat-pack--tooltip#hide focusin->flat-pack--tooltip#show focusout->flat-pack--tooltip#hide click->flat-pack--sidebar-group#toggle",
            "flat-pack--tooltip-placement-value": "right",
            "flat-pack--tooltip-collapsed-only-value": true,
            "flat-pack--sidebar-group-target": "button"
          }
        end

        def header_aria_attributes
          {
            expanded: @default_open,
            controls: "sidebar-group-panel-#{object_id}"
          }
        end

        def icon_wrapper_classes
          "flex-shrink-0"
        end

        def label_classes
          classes(
            "flex-1",
            "text-left",
            ("sr-only" if @collapsed)
          )
        end

        def chevron_wrapper_classes
          classes(
            "flex-shrink-0",
            "transition-transform",
            "duration-200",
            ("hidden" if @collapsed)
          )
        end

        def chevron_data
          {
            "flat-pack--sidebar-group-target": "chevron"
          }
        end

        def panel_attributes
          {
            id: "sidebar-group-panel-#{object_id}",
            class: panel_classes,
            data: panel_data
          }
        end

        def tooltip_attributes
          {
            role: "tooltip",
            class: tooltip_classes,
            style: tooltip_fallback_styles,
            data: {
              "flat-pack--tooltip-target": "tooltip"
            }
          }
        end

        def tooltip_fallback_styles
          "background-color: var(--tooltip-background-color, var(--surface-content-color)); color: var(--tooltip-text-color, var(--surface-background-color)); border-color: var(--tooltip-border-color, var(--surface-border-color));"
        end

        def tooltip_classes
          classes(
            "fixed",
            "z-50",
            "hidden",
            "px-[var(--tooltip-padding-x)]",
            "py-[var(--tooltip-padding-y)]",
            "text-[length:var(--tooltip-font-size)]",
            "leading-snug",
            "font-medium",
            "text-[var(--tooltip-text-color)]",
            "bg-[var(--tooltip-background-color)]",
            "border",
            "border-[var(--tooltip-border-color)]",
            "rounded-[var(--tooltip-radius)]",
            "shadow-[var(--tooltip-shadow)]",
            "max-w-[var(--tooltip-max-width)]",
            "whitespace-normal",
            "break-words",
            "pointer-events-none",
            "opacity-0",
            "transition-opacity",
            "duration-200"
          )
        end

        def panel_classes
          classes(
            "overflow-hidden",
            ("pl-[var(--sidebar-group-item-indent)]" unless @collapsed),
            (@default_open ? "" : "max-h-0")
          )
        end

        def panel_data
          {
            "flat-pack--sidebar-group-target": "panel"
          }
        end
      end
    end
  end
end
