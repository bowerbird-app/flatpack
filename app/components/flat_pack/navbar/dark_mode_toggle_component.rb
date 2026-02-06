# frozen_string_literal: true

module FlatPack
  module Navbar
    class DarkModeToggleComponent < FlatPack::BaseComponent
      def initialize(**system_arguments)
        super(**system_arguments)
      end

      def call
        tag.button(**button_attributes) do
          safe_join([
            sun_icon,
            moon_icon
          ])
        end
      end

      private

      def button_attributes
        merge_attributes(
          type: "button",
          class: [
            "p-2 rounded-md",
            "text-[var(--color-foreground)]",
            "hover:bg-[var(--color-muted)]",
            "transition-colors duration-200",
            "relative"
          ],
          data: {
            controller: "flat-pack--dark-mode",
            action: "click->flat-pack--dark-mode#toggle"
          },
          aria: { label: "Toggle dark mode" }
        )
      end

      def sun_icon
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-5 h-5 transition-opacity duration-200",
          data: { flat_pack__dark_mode_target: "sunIcon" },
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
          )
        end
      end

      def moon_icon
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-5 h-5 transition-opacity duration-200 absolute top-2 left-2",
          data: { flat_pack__dark_mode_target: "moonIcon" },
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor"
        ) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
          )
        end
      end
    end
  end
end
