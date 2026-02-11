# frozen_string_literal: true

module FlatPack
  module Navbar
    class ThemeToggleComponent < ViewComponent::Base
      SIZES = {
        sm: "w-8 h-8",
        md: "w-10 h-10",
        lg: "w-12 h-12"
      }.freeze

      def initialize(
        size: :md,
        show_label: false,
        **system_arguments
      )
        @size = size.to_sym
        @show_label = show_label
        @system_arguments = system_arguments
        validate_size!
      end

      def call
        content_tag(:button, **button_attributes) do
          safe_join([
            render_icon,
            (@show_label ? content_tag(:span, "Toggle theme", class: "sr-only") : nil)
          ].compact)
        end
      end

      private

      def button_attributes
        {
          class: button_classes,
          data: {
            controller: "navbar-theme-toggle",
            action: "click->navbar-theme-toggle#toggle"
          },
          aria: {label: "Toggle theme"}
        }.merge(@system_arguments)
      end

      def button_classes
        classes(
          "flatpack-theme-toggle",
          "inline-flex",
          "items-center",
          "justify-center",
          "rounded-[var(--radius-md)]",
          "p-2",
          "hover:bg-[var(--color-muted)]",
          "transition-colors",
          "duration-200"
        )
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def render_icon
        tag.svg(
          class: "#{SIZES[@size]} transition-transform duration-200",
          data: {navbar_theme_toggle_target: "icon"},
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor",
          "stroke-width": "2"
        ) do
          safe_join([
            # Sun icon (visible in light mode)
            tag.circle(cx: "12", cy: "12", r: "5", class: "dark:hidden"),
            tag.line(x1: "12", y1: "1", x2: "12", y2: "3", class: "dark:hidden"),
            tag.line(x1: "12", y1: "21", x2: "12", y2: "23", class: "dark:hidden"),
            tag.line(x1: "4.22", y1: "4.22", x2: "5.64", y2: "5.64", class: "dark:hidden"),
            tag.line(x1: "18.36", y1: "18.36", x2: "19.78", y2: "19.78", class: "dark:hidden"),
            tag.line(x1: "1", y1: "12", x2: "3", y2: "12", class: "dark:hidden"),
            tag.line(x1: "21", y1: "12", x2: "23", y2: "12", class: "dark:hidden"),
            tag.line(x1: "4.22", y1: "19.78", x2: "5.64", y2: "18.36", class: "dark:hidden"),
            tag.line(x1: "18.36", y1: "5.64", x2: "19.78", y2: "4.22", class: "dark:hidden"),
            # Moon icon (visible in dark mode)
            tag.path(d: "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z", class: "hidden dark:block")
          ])
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
