# frozen_string_literal: true

module FlatPack
  module Navbar
    class ThemeToggleComponent < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "p-1.5" "text-xs" "p-2" "text-sm" "p-3" "text-base"
      SIZES = {
        sm: { padding: "p-1.5", text: "text-xs" },
        md: { padding: "p-2", text: "text-sm" },
        lg: { padding: "p-3", text: "text-base" }
      }.freeze

      def initialize(
        size: :md,
        show_label: false,
        **system_arguments
      )
        super(**system_arguments)
        @size = size.to_sym
        @show_label = show_label

        validate_size!
      end

      def call
        content_tag(:button, **button_attributes) do
          safe_join([
            render_sun_icon,
            render_moon_icon,
            (render_label if @show_label)
          ].compact)
        end
      end

      private

      def render_sun_icon
        # Visible in dark mode
        content_tag(:svg,
          class: "hidden dark:block w-5 h-5 transition-transform hover:rotate-180 duration-500",
          fill: "none",
          stroke: "currentColor",
          viewBox: "0 0 24 24") do
          safe_join([
            tag.circle(cx: "12", cy: "12", r: "4"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M12 2v2"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M12 20v2"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M4.93 4.93l1.41 1.41"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M17.66 17.66l1.41 1.41"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M2 12h2"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M20 12h2"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M6.34 17.66l-1.41 1.41"),
            tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M19.07 4.93l-1.41 1.41")
          ])
        end
      end

      def render_moon_icon
        # Visible in light mode
        content_tag(:svg,
          class: "block dark:hidden w-5 h-5 transition-transform hover:rotate-12 duration-300",
          fill: "none",
          stroke: "currentColor",
          viewBox: "0 0 24 24") do
          tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z")
        end
      end

      def render_label
        content_tag(:span, "Theme", class: "ml-2 #{SIZES[@size][:text]}")
      end

      def button_attributes
        merge_attributes(
          class: button_classes,
          data: {
            action: "click->theme#toggle"
          },
          aria: { label: "Toggle theme" }
        )
      end

      def button_classes
        classes(
          "flex items-center justify-center",
          "rounded-lg",
          "hover:bg-[var(--color-muted)]",
          "transition-colors duration-200",
          SIZES[@size][:padding]
        )
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
