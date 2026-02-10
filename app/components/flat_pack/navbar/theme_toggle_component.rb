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

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
