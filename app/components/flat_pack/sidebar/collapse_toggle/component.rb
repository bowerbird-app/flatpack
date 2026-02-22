# frozen_string_literal: true

module FlatPack
  module Sidebar
    module CollapseToggle
      class Component < FlatPack::BaseComponent
        def initialize(
          collapsed: false,
          **system_arguments
        )
          super(**system_arguments)
          @collapsed = collapsed
        end

        def call
          content_tag(:button, **button_attributes) do
            safe_join([
              render_icon,
              render_label
            ].compact)
          end
        end

        private

        def render_icon
          content_tag(:span, class: icon_wrapper_classes) do
            render FlatPack::Shared::IconComponent.new(
              name: :chevron_left,
              size: :md
            )
          end
        end

        def render_label
          content_tag(:span, label_text, class: label_classes)
        end

        def button_attributes
          merge_attributes(
            class: button_classes,
            type: "button",
            data: button_data,
            aria: aria_attributes_for_button
          )
        end

        def button_classes
          classes(
            "flex",
            "items-center",
            "gap-2",
            "px-4",
            "py-2.5",
            "text-sm",
            "font-medium",
            "text-muted-foreground",
            "hover:bg-muted",
            "hover:text-foreground",
            "transition-colors",
            "rounded-lg",
            "mx-2",
            "w-[calc(100%-1rem)]"
          )
        end

        def button_data
          {
            "flat-pack--sidebar-layout-target": "desktopToggle",
            action: "click->flat-pack--sidebar-layout#toggleDesktop"
          }
        end

        def icon_wrapper_classes
          classes(
            "flex-shrink-0",
            "transition-transform",
            "duration-300",
            (@collapsed ? "rotate-180" : "")
          )
        end

        def label_classes
          classes(
            "flex-1",
            "text-left",
            (@collapsed ? "sr-only" : "")
          )
        end

        def label_text
          @collapsed ? "Expand sidebar" : "Collapse sidebar"
        end

        def aria_attributes_for_button
          {
            label: label_text,
            expanded: !@collapsed
          }
        end
      end
    end
  end
end
