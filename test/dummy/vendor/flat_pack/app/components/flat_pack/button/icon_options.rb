# frozen_string_literal: true

module FlatPack
  module Button
    # Shared icon variant and colour for button-family leading icons.
    module IconOptions
      VARIANTS = %i[outline solid mini micro].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-button-icon"
      # "text-[color-mix(in_oklab,var(--button-icon-primary-color)_55%,var(--fp-button-text))]"
      # "text-[color-mix(in_oklab,var(--button-icon-success-color)_55%,var(--fp-button-text))]"
      # "text-[color-mix(in_oklab,var(--button-icon-warning-color)_55%,var(--fp-button-text))]"
      # "text-[color-mix(in_oklab,var(--button-icon-danger-color)_55%,var(--fp-button-text))]"
      STYLES = {
        primary: "text-[color-mix(in_oklab,var(--button-icon-primary-color)_55%,var(--fp-button-text))]",
        success: "text-[color-mix(in_oklab,var(--button-icon-success-color)_55%,var(--fp-button-text))]",
        warning: "text-[color-mix(in_oklab,var(--button-icon-warning-color)_55%,var(--fp-button-text))]",
        danger: "text-[color-mix(in_oklab,var(--button-icon-danger-color)_55%,var(--fp-button-text))]"
      }.freeze

      module_function

      def normalize_variant!(icon_variant)
        return if icon_variant.nil?

        normalized = icon_variant.to_sym
        return normalized if VARIANTS.include?(normalized)

        raise ArgumentError, "Invalid icon_variant: #{icon_variant.inspect}. Must be one of: #{VARIANTS.join(", ")}."
      end

      def normalize_style!(icon_style)
        return if icon_style.nil?

        normalized = icon_style.to_sym
        return normalized if STYLES.key?(normalized)

        raise ArgumentError, "Invalid icon_style: #{icon_style.inspect}. Must be one of: #{STYLES.keys.join(", ")}."
      end

      def component_arguments(name:, size:, icon_variant:, icon_style:)
        arguments = {
          name: name,
          size: size,
          class: icon_class(icon_style)
        }
        arguments[:variant] = icon_variant if icon_variant
        arguments[:data] = {icon_style: icon_style.to_s} if icon_style
        arguments
      end

      def icon_class(icon_style)
        ["fp-button-icon", STYLES[icon_style]].compact.join(" ")
      end
    end
  end
end
