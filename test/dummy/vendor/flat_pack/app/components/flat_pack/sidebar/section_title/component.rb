# frozen_string_literal: true

module FlatPack
  module Sidebar
    module SectionTitle
      class Component < FlatPack::BaseComponent
        def initialize(label:, collapsed: false, **system_arguments)
          super(**system_arguments)
          @label = label
          @collapsed = collapsed
        end

        def call
          content_tag(:div, **wrapper_attributes) do
            safe_join([
              content_tag(:p, @label, class: label_classes),
              render_tooltip
            ])
          end
        end

        private

        def render_tooltip
          content_tag(:div, @label, **tooltip_attributes)
        end

        def wrapper_attributes
          merge_attributes(
            class: wrapper_classes,
            data: wrapper_data
          )
        end

        def wrapper_classes
          classes(
            (@collapsed ? "px-1" : "px-4"),
            "pt-2",
            "pb-1",
            "mx-2",
            "overflow-hidden"
          )
        end

        def wrapper_data
          {
            controller: "flat-pack--tooltip",
            action: "mouseenter->flat-pack--tooltip#show mouseleave->flat-pack--tooltip#hide focusin->flat-pack--tooltip#show focusout->flat-pack--tooltip#hide",
            "flat-pack--tooltip-placement-value": "right",
            "flat-pack--tooltip-collapsed-only-value": true,
            "flat-pack-sidebar-section-title": "true"
          }
        end

        def label_classes
          classes(
            "text-xs",
            "font-semibold",
            "uppercase",
            "tracking-wider",
            "text-[var(--sidebar-item-text-color)]",
            "opacity-50",
            "truncate",
            "block",
            (@collapsed ? "text-center" : nil)
          )
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
      end
    end
  end
end
