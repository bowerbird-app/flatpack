# frozen_string_literal: true

module FlatPack
  module FormField
    # Shared box class list for form controls that use --form-control-padding.
    # Included by TextInput, Select, TextArea, and the other matching inputs.
    module ControlStyles
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"
      # "px-[var(--form-control-padding)]" "py-[var(--form-control-padding)]"
      # "bg-[var(--surface-background-color)]" "text-[var(--surface-content-color)]"
      # "border" "border-[var(--surface-border-color)]" "placeholder:text-[var(--surface-muted-content-color)]"
      # "focus:ring-ring" "focus:border-transparent" "appearance-none"
      # "border-0" "bg-transparent" "rounded-none" "focus:outline-none" "focus:ring-0"

      CHROMES = %i[field cell].freeze

      def assign_control_chrome!(chrome)
        name = (chrome.presence || :field).to_s.to_sym
        raise ArgumentError, "chrome must be :field or :cell" unless CHROMES.include?(name)

        @control_chrome = name
      end

      def cell_chrome?
        @control_chrome == :cell
      end

      # Width + color utilities that survive host Tailwind preflight when it
      # loads after kit CSS. Color-only `border-[…]` is not enough.
      def form_control_border_classes(error:)
        [
          "border",
          (error ? "border-[var(--color-error)]" : "border-[var(--surface-border-color)]")
        ]
      end

      def form_control_padding_classes
        [
          "px-[var(--form-control-padding)]",
          "py-[var(--form-control-padding)]"
        ]
      end

      def form_control_classes(
        error:,
        custom_class: nil,
        control_class: "flat-pack-input",
        extra: [],
        placeholder: true,
        appearance_none: false
      )
        base_classes = if cell_chrome?
          cell_control_classes(
            control_class: control_class,
            extra: extra,
            placeholder: placeholder,
            appearance_none: appearance_none
          )
        else
          field_control_classes(
            error: error,
            control_class: control_class,
            extra: extra,
            placeholder: placeholder,
            appearance_none: appearance_none
          )
        end

        classes(*base_classes, custom_class)
      end

      def field_control_classes(error:, control_class:, extra:, placeholder:, appearance_none:)
        [
          control_class,
          "w-full",
          "rounded-[var(--radius-md)]",
          *form_control_border_classes(error: error),
          ("appearance-none" if appearance_none),
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          *form_control_padding_classes,
          "text-sm",
          "transition-colors duration-base",
          ("placeholder:text-[var(--surface-muted-content-color)]" if placeholder),
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          *Array(extra)
        ].compact
      end

      def cell_control_classes(control_class:, extra:, placeholder:, appearance_none:)
        [
          control_class,
          "w-full",
          "border-0",
          "rounded-none",
          ("appearance-none" if appearance_none),
          "bg-transparent",
          "text-[var(--surface-content-color)]",
          *form_control_padding_classes,
          "text-sm",
          "transition-colors duration-base",
          ("placeholder:text-[var(--surface-muted-content-color)]" if placeholder),
          "focus:outline-none focus:ring-0",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          *Array(extra)
        ].compact
      end
    end
  end
end
