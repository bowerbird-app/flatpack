# frozen_string_literal: true

module FlatPack
  module Navbar
    class SidebarComponent < FlatPack::BaseComponent
      renders_many :items, lambda { |*args, **kwargs|
        # ViewComponent passes keyword arguments as positional pairs when using certain patterns
        # Convert alternating [key, value, key, value] to hash if needed
        params = {}
        args.each_slice(2) { |k, v| params[k] = v }
        params.merge!(kwargs)
        SidebarItemComponent.new(**params)
      }

      renders_many :sections, lambda { |*args, **kwargs|
        # Same conversion for sections
        params = {}
        args.each_slice(2) { |k, v| params[k] = v }
        params.merge!(kwargs)
        SidebarSectionComponent.new(**params)
      }

      def initialize(**kwargs)
        @collapsed = kwargs[:collapsed] || false
        @expanded_width = kwargs[:expanded_width] || "256px"
        @collapsed_width = kwargs[:collapsed_width] || "64px"

        super(**kwargs.except(:collapsed, :expanded_width, :collapsed_width))
      end

      # Define cleaner API methods
      def item(...)
        with_item(...)
      end

      def section(...)
        with_section(...)
      end

      def call
        content_tag(:aside, **sidebar_attributes) do
          safe_join([
            content_tag(:nav, class: nav_classes) do
              safe_join([items, sections].flatten.compact)
            end,
            toggle_button
          ])
        end
      end

      private

      def sidebar_attributes
        merge_attributes(
          class: sidebar_classes,
          data: {
            controller: "flat-pack--sidebar",
            flat_pack__navbar_target: "sidebar"
          },
          style: "width: #{@expanded_width};"
        )
      end

      def sidebar_classes
        classes(
          "hidden md:flex",
          "md:relative fixed",
          "inset-y-0 left-0",
          "z-40",
          "flex-col",
          "bg-[var(--color-background)]",
          "border-r border-[var(--color-border)]",
          "shadow-lg md:shadow-none",
          "-translate-x-full md:translate-x-0",
          "transition-transform duration-300"
        )
      end

      def nav_classes
        "flex-1 overflow-y-auto p-4"
      end

      def toggle_button
        content_tag(:div, class: "p-4 border-t border-[var(--color-border)] mt-auto") do
          content_tag(:button, **toggle_button_attributes) do
            safe_join([
              chevron_icon,
              content_tag(:span, "Minimize", data: {flat_pack__navbar_target: "toggleText"})
            ])
          end
        end
      end

      def toggle_button_attributes
        {
          type: "button",
          class: "flex items-center gap-2 w-full px-3 py-2 rounded-md hover:bg-[var(--color-muted)] transition-colors",
          data: {
            action: "click->flat-pack--navbar#toggle",
            flat_pack__navbar_target: "toggleButton"
          }
        }
      end

      def chevron_icon
        content_tag(:svg, **chevron_attributes) do
          content_tag(:path, nil, d: "m9 18 6-6-6-6")
        end
      end

      def chevron_attributes
        {
          xmlns: "http://www.w3.org/2000/svg",
          width: "20",
          height: "20",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          class: "transition-transform duration-200",
          data: {flat_pack__navbar_target: "toggleIcon"}
        }
      end
    end
  end
end
