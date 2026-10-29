# frozen_string_literal: true

module FlatPack
  module Text
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-text" "fp-text-pretty"
      # "text-[length:var(--text-xs)]" "text-[length:var(--text-sm)]" "text-[length:var(--text-base)]"
      # "text-[length:var(--text-lg)]" "text-[length:var(--text-xl)]" "text-[length:var(--text-2xl)]"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
      # "text-[var(--color-primary)]"
      # "font-normal" "font-medium" "font-semibold" "font-bold"
      AS = %i[p span div].freeze
      SIZES = {
        xs: "text-[length:var(--text-xs)]",
        sm: "text-[length:var(--text-sm)]",
        base: "text-[length:var(--text-base)]",
        lg: "text-[length:var(--text-lg)]",
        xl: "text-[length:var(--text-xl)]",
        "2xl": "text-[length:var(--text-2xl)]"
      }.freeze
      STYLES = {
        default: "text-[var(--surface-content-color)]",
        muted: "text-[var(--surface-muted-content-color)]",
        primary: "text-[var(--color-primary)]"
      }.freeze
      WEIGHTS = {
        normal: "font-normal",
        medium: "font-medium",
        semibold: "font-semibold",
        bold: "font-bold"
      }.freeze

      def initialize(
        text: nil,
        size: :base,
        style: :default,
        weight: :normal,
        as: :p,
        **system_arguments
      )
        super(**system_arguments)
        validate_text_option!(text, name: :text)
        @text = text
        @size = size.to_sym
        @style = style.to_sym
        @weight = weight.to_sym
        @as = as.to_sym

        validate_size!
        validate_style!
        validate_weight!
        validate_as!
      end

      def call
        raise ArgumentError, "text is required" if copy.blank?

        content_tag(@as, copy, **text_attributes)
      end

      private

      def text_attributes
        merge_attributes(class: text_classes)
      end

      def text_classes
        classes(
          "fp-text",
          "fp-text-pretty",
          SIZES.fetch(@size),
          STYLES.fetch(@style),
          WEIGHTS.fetch(@weight)
        )
      end

      def copy
        @copy ||= @text.presence || content
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_style!
        return if STYLES.key?(@style)

        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
      end

      def validate_weight!
        return if WEIGHTS.key?(@weight)

        raise ArgumentError, "Invalid weight: #{@weight}. Must be one of: #{WEIGHTS.keys.join(", ")}"
      end

      def validate_as!
        return if AS.include?(@as)

        raise ArgumentError, "Invalid as: #{@as}. Must be one of: #{AS.join(", ")}"
      end
    end
  end
end
