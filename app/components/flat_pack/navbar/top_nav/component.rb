# frozen_string_literal: true

module FlatPack
  module Navbar
    module TopNav
      class Component < FlatPack::BaseComponent
        renders_one :left_section_slot
        renders_one :center_section_slot
        renders_one :right_section_slot

        def initialize(**kwargs)
          @height = kwargs[:height] || "64px"

          super(**kwargs.except(:height))
        end

        def left_section(...)
          with_left_section_slot(...)
        end

        def center_section(...)
          with_center_section_slot(...)
        end

        def right_section(...)
          with_right_section_slot(...)
        end

        def call
          content_tag(:nav, **nav_attributes) do
            safe_join([
              render_left_section,
              center_section_slot,
              right_section_slot
            ].compact)
          end
        end

        private

        def nav_attributes
          merge_attributes(
            class: nav_classes,
            style: "height: #{@height};"
          )
        end

        def nav_classes
          classes(
            "flex items-center justify-between gap-4",
            "px-6"
          )
        end

        def render_left_section
          content_tag(:div, class: "flex items-center gap-4") do
            safe_join([hamburger_menu, left_section_slot].compact)
          end
        end

        def hamburger_menu
          content_tag(:button, **hamburger_attributes) do
            hamburger_icon
          end
        end

        def hamburger_attributes
          {
            type: "button",
            class: "md:hidden p-2 rounded-md hover:bg-muted transition-colors",
            data: {action: "click->flat-pack--navbar#toggle"},
            aria: {label: "Toggle navigation"}
          }
        end

        def hamburger_icon
          content_tag(:svg, **hamburger_svg_attributes) do
            safe_join([
              content_tag(:line, nil, x1: "3", y1: "6", x2: "21", y2: "6"),
              content_tag(:line, nil, x1: "3", y1: "12", x2: "21", y2: "12"),
              content_tag(:line, nil, x1: "3", y1: "18", x2: "21", y2: "18")
            ])
          end
        end

        def hamburger_svg_attributes
          {
            xmlns: "http://www.w3.org/2000/svg",
            width: "24",
            height: "24",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2",
            "stroke-linecap": "round",
            "stroke-linejoin": "round"
          }
        end
      end
    end
  end
end
