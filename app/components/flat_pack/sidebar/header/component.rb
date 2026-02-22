# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Header
      class Component < FlatPack::BaseComponent
        def initialize(
          brand_abbr: "FP",
          title: "FlatPack",
          subtitle: nil,
          collapsible: true,
          **system_arguments
        )
          super(**system_arguments)
          @brand_abbr = brand_abbr
          @title = title
          @subtitle = subtitle
          @collapsible = collapsible
        end

        def call
          content_tag(:div, **header_attributes) do
            if content.present?
              content
            else
              render_default_header_content
            end
          end
        end

        private

        def render_default_header_content
          content_tag(:div, class: "flex items-center gap-3") do
            safe_join([
              render_brand,
              (@collapsible ? render_collapsed_toggle : nil),
              (@collapsible ? render_desktop_toggle : nil)
            ].compact)
          end
        end

        def render_brand
          content_tag(:div, class: "flex items-center gap-3", data: brand_data_attributes) do
            safe_join([
              (@brand_abbr.present? ? content_tag(:div, @brand_abbr, class: brand_badge_classes) : nil),
              content_tag(:div, class: "flex items-center h-8", data: header_label_data_attributes) do
                content_tag(:div, @title, class: "font-semibold text-sm text-[var(--sidebar-header-text-color)]")
              end
            ].compact)
          end
        end

        def render_collapsed_toggle
          content_tag(:button, type: "button", class: collapsed_toggle_classes, data: collapsed_toggle_data_attributes, aria: collapsed_toggle_aria_attributes) do
            render FlatPack::Shared::IconComponent.new(name: :menu, size: :md)
          end
        end

        def render_desktop_toggle
          content_tag(:button, type: "button", class: desktop_toggle_classes, data: desktop_toggle_data_attributes, aria: desktop_toggle_aria_attributes) do
            content_tag(:span, class: "flex-shrink-0 transition-transform duration-300", data: chevron_data_attributes) do
              render FlatPack::Shared::IconComponent.new(name: :chevron_left, size: :md)
            end
          end
        end

        def brand_badge_classes
          "w-8 h-8 rounded-lg flex items-center justify-center font-bold bg-[var(--sidebar-header-badge-background-color)] text-[var(--sidebar-header-badge-text-color)]"
        end

        def collapsed_toggle_classes
          "hidden items-center justify-center p-2 rounded-lg text-[var(--sidebar-header-icon-color)] hover:bg-[var(--sidebar-header-icon-hover-background-color)] hover:text-[var(--sidebar-header-icon-hover-color)] transition-colors"
        end

        def desktop_toggle_classes
          "ml-auto p-2 rounded-lg text-[var(--sidebar-header-icon-color)] hover:bg-[var(--sidebar-header-icon-hover-background-color)] hover:text-[var(--sidebar-header-icon-hover-color)] transition-colors"
        end

        def brand_data_attributes
          {
            "flat-pack--sidebar-layout-target": "headerBrand"
          }
        end

        def header_label_data_attributes
          {
            "flat-pack--sidebar-layout-target": "headerLabel"
          }
        end

        def collapsed_toggle_data_attributes
          {
            "flat-pack--sidebar-layout-target": "collapsedToggle",
            action: "click->flat-pack--sidebar-layout#toggleDesktop"
          }
        end

        def desktop_toggle_data_attributes
          {
            "flat-pack--sidebar-layout-target": "desktopToggle",
            action: "click->flat-pack--sidebar-layout#toggleDesktop click->flat-pack--sidebar-layout#toggleMobile"
          }
        end

        def chevron_data_attributes
          {
            "flat-pack--sidebar-layout-target": "chevron"
          }
        end

        def collapsed_toggle_aria_attributes
          {
            label: "Open sidebar",
            expanded: false
          }
        end

        def desktop_toggle_aria_attributes
          {
            label: "Collapse sidebar",
            expanded: true
          }
        end

        def header_attributes
          merge_attributes(
            class: header_classes
          )
        end

        def header_classes
          classes(
            "shrink-0",
            "p-4",
            "bg-[var(--sidebar-header-background-color)]",
            "border-b border-[var(--sidebar-header-border-color)]"
          )
        end
      end
    end
  end
end
