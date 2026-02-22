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
              render_badge
            ].compact)
          end
        end

        private

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

        def render_badge
          return unless @badge

          render FlatPack::Sidebar::Badge::Component.new(
            value: @badge
          )
        end

        def link_attributes
          merge_attributes(
            class: link_classes,
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
            "bg-[var(--sidebar-item-active-background-color)] text-[var(--sidebar-item-active-text-color)]"
          else
            "text-[var(--sidebar-item-text-color)] hover:bg-[var(--sidebar-item-hover-background-color)] hover:text-[var(--sidebar-item-hover-text-color)]"
          end
        end

        def icon_wrapper_classes
          classes(
            "flex-shrink-0",
            (@active ? "text-[var(--sidebar-item-active-icon-color)]" : "text-[var(--sidebar-item-icon-color)]")
          )
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
