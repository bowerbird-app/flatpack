# frozen_string_literal: true

module FlatPack
  module Heading
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-heading" "fp-type-heading" "fp-text-balance"
      # "fp-heading--xs" "fp-heading--sm" "fp-heading--base" "fp-heading--lg" "fp-heading--xl"
      # "fp-heading--2xl" "fp-heading--3xl" "fp-heading--4xl" "fp-heading--5xl"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
      # "text-[var(--color-primary)]"
      LEVELS = %i[h1 h2 h3 h4 h5 h6].freeze
      ROLE_WEIGHT = :semibold
      SIZES = {
        xs: "fp-heading--xs",
        sm: "fp-heading--sm",
        base: "fp-heading--base",
        lg: "fp-heading--lg",
        xl: "fp-heading--xl",
        "2xl": "fp-heading--2xl",
        "3xl": "fp-heading--3xl",
        "4xl": "fp-heading--4xl",
        "5xl": "fp-heading--5xl"
      }.freeze
      STYLES = {
        default: "text-[var(--surface-content-color)]",
        muted: "text-[var(--surface-muted-content-color)]",
        primary: "text-[var(--color-primary)]"
      }.freeze
      WEIGHTS = %i[normal medium semibold bold].freeze

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
        @pin_weight = @weight != ROLE_WEIGHT

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
        attributes = merge_attributes(class: heading_classes)
        attributes[:data] = (attributes[:data] || {}).merge(fp_weight: @weight) if @pin_weight
        attributes
      end

      def heading_classes
        classes(
          "fp-heading",
          "fp-type-heading",
          "fp-text-balance",
          SIZES.fetch(@size),
          STYLES.fetch(@style)
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
        return if WEIGHTS.include?(@weight)

        raise ArgumentError, "Invalid weight: #{@weight}. Must be one of: #{WEIGHTS.join(", ")}"
      end
    end
  end
end
