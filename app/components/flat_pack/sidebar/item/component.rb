# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Item
      class Component < FlatPack::BaseComponent
        def initialize(
          label:,
          href:,
          icon: nil,
          active: false,
          collapsed: false,
          badge: nil,
          **system_arguments
        )
          super(**system_arguments)
          @label = label
          @icon = icon
          @active = active
          @collapsed = collapsed
          @badge = badge

          # Sanitize URL for security
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        end

        def call
          link_to @href, **link_attributes do
            safe_join([
              render_icon,
              render_label,
              render_badge,
              render_collapsed_tooltip
            ].compact)
          end
        end

        private

        def render_icon
          return unless @icon

          content_tag(:span, class: icon_wrapper_classes, data: icon_data) do
            render FlatPack::Shared::IconComponent.new(
              name: @icon,
              size: :md
            )
          end
        end

        def render_label
          content_tag(:span, @label, class: label_classes)
        end

        def render_badge
          return unless @badge

          render FlatPack::Sidebar::Badge::Component.new(
            value: @badge
          )
        end

        def render_collapsed_tooltip
          content_tag(:div, @label, **tooltip_attributes)
        end

        def link_attributes
          merged_data = merge_data_attributes(data_attributes, link_data)

          merge_attributes(
            class: link_classes,
            data: merged_data,
            aria: aria_attributes_for_link
          )
        end

        def link_classes
          classes(
            "flex",
            "items-center",
            "gap-3",
            "px-4",
            "py-2.5",
            "text-sm",
            "font-medium",
            "transition-colors",
            "rounded-lg",
            "mx-2",
            state_classes
          )
        end

        def state_classes
          if @active
            active_link_classes
          else
            inactive_link_classes
          end
        end

        def link_data
          {
            controller: "flat-pack--tooltip",
            action: "mouseenter->flat-pack--tooltip#show mouseleave->flat-pack--tooltip#hide focusin->flat-pack--tooltip#show focusout->flat-pack--tooltip#hide",
            "flat-pack--tooltip-placement-value": "right",
            "flat-pack--tooltip-collapsed-only-value": true,
            "flat-pack-sidebar-item": "true"
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

        def active_link_classes
          "bg-[var(--sidebar-item-active-background-color)] text-[var(--sidebar-item-active-text-color)]"
        end

        def inactive_link_classes
          "text-[var(--sidebar-item-text-color)] hover:bg-[var(--sidebar-item-hover-background-color)] hover:text-[var(--sidebar-item-hover-text-color)]"
        end

        def icon_wrapper_classes
          classes(
            "flex-shrink-0",
            (@active ? active_icon_classes : inactive_icon_classes)
          )
        end

        def icon_data
          {
            "flat-pack-sidebar-item-icon": "true"
          }
        end

        def active_icon_classes
          "text-[var(--sidebar-item-active-icon-color)]"
        end

        def inactive_icon_classes
          "text-[var(--sidebar-item-icon-color)]"
        end

        def label_classes
          classes(
            "flex-1",
            ("sr-only" if @collapsed)
          )
        end

        def aria_attributes_for_link
          attrs = {}
          attrs[:label] = @label if @collapsed
          attrs[:current] = "page" if @active
          attrs
        end

        def validate_href!(original_href)
          return if @href.present?

          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
      end
    end
  end
end
