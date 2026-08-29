# frozen_string_literal: true

module FlatPack
  module FormField
    # Shared box class list for form controls that use --form-control-padding.
    # Included by TextInput, Select, TextArea, and the other matching inputs.
    module ControlStyles
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"
      # "px-[var(--form-control-padding)]" "py-[var(--form-control-padding)]"
      # "bg-[var(--surface-background-color)]" "text-[var(--surface-content-color)]"
      # "border-[var(--surface-border-color)]" "placeholder:text-[var(--surface-muted-content-color)]"
      # "focus:ring-ring" "focus:border-transparent" "appearance-none"

      def form_control_classes(
        error:,
        custom_class: nil,
        control_class: "flat-pack-input",
        extra: [],
        placeholder: true,
        appearance_none: false
      )
        base_classes = [
          control_class,
          "w-full",
          "rounded-md",
          "border",
          ("appearance-none" if appearance_none),
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          ("placeholder:text-[var(--surface-muted-content-color)]" if placeholder),
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          *Array(extra)
        ].compact

        base_classes << if error
          "border-[var(--color-warning)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, custom_class)
      end
    end
  end
end
