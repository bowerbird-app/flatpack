# frozen_string_literal: true

module FlatPack
  module BottomNav
    module Item
      class Component < FlatPack::BaseComponent
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "flex" "flex-col" "items-center" "justify-center" "gap-1"
        # "py-[var(--bottom-nav-item-padding-y)]" "px-[var(--bottom-nav-item-padding-x)]" "text-xs" "font-medium" "text-[var(--bottom-nav-item-active-color)]"
        # "text-[var(--bottom-nav-item-color)]" "hover:text-[var(--bottom-nav-item-hover-color)]"

        def initialize(label:, href:, icon: nil, active: false, **system_arguments)
          super(**system_arguments)
          @label = label
          @icon = icon
          @active = active

          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        end

        def call
          link_to @href, **link_attributes do
            safe_join([
              render_icon,
              render_label
            ].compact)
          end
        end

        private

        def render_icon
          return unless @icon

          render FlatPack::Shared::IconComponent.new(
            name: @icon,
            size: :sm,
            class: "shrink-0"
          )
        end

        def render_label
          content_tag(:span, @label, class: "truncate")
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
            "min-w-0",
            "flex-col",
            "items-center",
            "justify-center",
            "gap-1",
            "px-[var(--bottom-nav-item-padding-x)]",
            "py-[var(--bottom-nav-item-padding-y)]",
            "text-xs",
            "font-medium",
            "transition-colors",
            state_classes
          )
        end

        def state_classes
          if @active
            "text-[var(--bottom-nav-item-active-color)]"
          else
            "text-[var(--bottom-nav-item-color)] hover:text-[var(--bottom-nav-item-hover-color)]"
          end
        end

        def aria_attributes_for_link
          attrs = {}
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
