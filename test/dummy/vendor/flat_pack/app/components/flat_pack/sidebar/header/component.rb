# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Header
      class Component < FlatPack::BaseComponent
        class Badge
          attr_reader :kind, :value

          def self.resolve(logo:, brand_abbr:)
            url = normalize_logo(logo)
            return new(:logo, url) if url
            return new(:abbr, brand_abbr) if brand_abbr.present?

            new(:empty, nil)
          end

          def self.normalize_logo(logo)
            return nil if logo.nil?
            unless logo.is_a?(String)
              raise ArgumentError, "logo: must be a URL string"
            end
            return nil if logo.blank?

            FlatPack::AttributeSanitizer.sanitize_url(logo)
          end
          private_class_method :normalize_logo

          def initialize(kind, value)
            @kind = kind
            @value = value
          end

          private_class_method :new
        end
        private_constant :Badge

        def initialize(
          logo: nil,
          brand_abbr: "FP",
          title: "FlatPack",
          subtitle: nil,
          collapsible: true,
          show_version: true,
          **system_arguments
        )
          super(**system_arguments)
          @title = title
          @subtitle = subtitle
          @collapsible = collapsible
          @show_version = show_version
          @badge = Badge.resolve(logo: logo, brand_abbr: brand_abbr)
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
          content_tag(:div, class: "flex items-center gap-3", data: {"flat-pack--sidebar-layout-target": "headerRow"}) do
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
              render_badge,
              content_tag(:div, class: "flex items-center h-8", data: header_label_data_attributes) do
                safe_join([
                  content_tag(:div, @title, class: "font-semibold text-sm text-[var(--sidebar-header-text-color)]"),
                  (@show_version ? content_tag(:span, sidebar_version_label, class: sidebar_version_badge_classes) : nil)
                ].compact)
              end
            ].compact)
          end
        end

        def render_badge
          case @badge.kind
          when :logo then render_logo_badge
          when :abbr then render_abbr_badge
          when :empty then nil
          end
        end

        def render_logo_badge
          render FlatPack::Avatar::Component.new(
            src: @badge.value,
            alt: "",
            size: :sm,
            shape: :circle,
            show_tooltip: false,
            aria: (@title.present? ? {hidden: true} : {})
          )
        end

        def render_abbr_badge
          content_tag(:div, @badge.value, class: brand_badge_classes)
        end

        def sidebar_version_label
          "v#{FlatPack::VERSION}"
        end

        def sidebar_version_badge_classes
          "ml-2 inline-flex items-center rounded-[var(--radius-md)] border px-2 py-0.5 text-[10px] leading-none font-medium bg-[var(--badge-default-background-color)] text-[var(--badge-default-text-color)] border-[var(--badge-default-border-color)]"
        end

        def render_collapsed_toggle
          content_tag(:button, type: "button", class: collapsed_toggle_classes, data: collapsed_toggle_data_attributes, aria: collapsed_toggle_aria_attributes) do
            render FlatPack::Shared::IconComponent.new(name: :menu, size: :md)
          end
        end

        def render_desktop_toggle
          content_tag(:button, type: "button", class: desktop_toggle_classes, data: desktop_toggle_data_attributes, aria: desktop_toggle_aria_attributes) do
            content_tag(:span, class: "flex-shrink-0 transition-transform duration-[var(--duration-slow)]", data: chevron_data_attributes) do
              render FlatPack::Shared::IconComponent.new(name: :chevron_left, size: :md)
            end
          end
        end

        def brand_badge_classes
          "w-8 h-8 rounded-[var(--radius-lg)] flex items-center justify-center font-bold bg-[var(--sidebar-header-badge-background-color)] text-[var(--sidebar-header-badge-text-color)]"
        end

        def collapsed_toggle_classes
          "hidden items-center justify-center p-2 rounded-[var(--radius-lg)] text-[var(--sidebar-header-icon-color)] hover:bg-[var(--sidebar-header-icon-hover-background-color)] hover:text-[var(--sidebar-header-icon-hover-color)] transition-colors"
        end

        def desktop_toggle_classes
          "hidden ml-auto p-2 rounded-[var(--radius-lg)] text-[var(--sidebar-header-icon-color)] hover:bg-[var(--sidebar-header-icon-hover-background-color)] hover:text-[var(--sidebar-header-icon-hover-color)] transition-colors"
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
            "bg-[var(--sidebar-header-background-color)]"
          )
        end
      end
    end
  end
end
