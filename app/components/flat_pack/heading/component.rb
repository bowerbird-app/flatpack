# frozen_string_literal: true

module FlatPack
  module Heading
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-heading" "fp-text-balance" "leading-tight"
      # "text-[length:var(--text-xs)]" "text-[length:var(--text-sm)]" "text-[length:var(--text-base)]"
      # "text-[length:var(--text-lg)]" "text-[length:var(--text-xl)]" "text-[length:var(--text-2xl)]"
      # "text-[length:var(--text-3xl)]" "text-[length:var(--text-4xl)]" "text-[length:var(--text-5xl)]"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
      # "text-[var(--color-primary)]"
      # "font-normal" "font-medium" "font-semibold" "font-bold"
      LEVELS = %i[h1 h2 h3 h4 h5 h6].freeze
      SIZES = {
        xs: "text-[length:var(--text-xs)] leading-tight",
        sm: "text-[length:var(--text-sm)] leading-tight",
        base: "text-[length:var(--text-base)] leading-tight",
        lg: "text-[length:var(--text-lg)] leading-tight",
        xl: "text-[length:var(--text-xl)] leading-tight",
        "2xl": "text-[length:var(--text-2xl)] leading-tight",
        "3xl": "text-[length:var(--text-3xl)] leading-tight",
        "4xl": "text-[length:var(--text-4xl)] leading-tight",
        "5xl": "text-[length:var(--text-5xl)] leading-tight"
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
        level: :h2,
        size: :"2xl",
        style: :default,
        weight: :semibold,
        **system_arguments
      )
        super(**system_arguments)
        validate_text_option!(text, name: :text)
        @text = text
        @level = normalize_level(level)
        @size = size.to_sym
        @style = style.to_sym
        @weight = weight.to_sym

        validate_level!
        validate_size!
        validate_style!
        validate_weight!
      end

      def call
        raise ArgumentError, "text is required" if heading_text.blank?

        content_tag(@level, heading_text, **heading_attributes)
      end

      private

      def heading_attributes
        merge_attributes(class: heading_classes)
      end

      def heading_classes
        classes(
          "fp-heading",
          "fp-text-balance",
          SIZES.fetch(@size),
          STYLES.fetch(@style),
          WEIGHTS.fetch(@weight)
        )
      end

      def heading_text
        @heading_text ||= @text.presence || content
      end

      def normalize_level(level)
        case level
        when Integer
          :"h#{level}"
        when String
          /\A[1-6]\z/.match?(level) ? :"h#{level}" : level.to_sym
        else
          level.to_sym
        end
      end

      def validate_level!
        return if LEVELS.include?(@level)

        raise ArgumentError, "Invalid level: #{@level}. Must be one of: #{LEVELS.join(", ")}, or 1-6"
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
    end
  end
end
