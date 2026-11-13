# frozen_string_literal: true

module FlatPack
  module Text
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-text" "fp-type-body" "fp-text-pretty"
      # "fp-type-body--xs" "fp-type-body--sm" "fp-type-body--lg" "fp-type-body--xl" "fp-type-body--2xl"
      AS = %i[p span div].freeze
      ROLE_WEIGHT = :normal
      SIZES = {
        xs: "fp-type-body--xs",
        sm: "fp-type-body--sm",
        base: nil,
        lg: "fp-type-body--lg",
        xl: "fp-type-body--xl",
        "2xl": "fp-type-body--2xl"
      }.freeze
      STYLES = {
        default: "text-[var(--surface-content-color)]",
        muted: "text-[var(--surface-muted-content-color)]",
        primary: "text-[var(--color-primary)]"
      }.freeze
      WEIGHTS = %i[normal medium semibold bold].freeze

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
        @pin_weight = @weight != ROLE_WEIGHT
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
        attributes = merge_attributes(class: text_classes)
        attributes[:data] = (attributes[:data] || {}).merge(fp_weight: @weight) if @pin_weight
        attributes
      end

      def text_classes
        classes(
          "fp-text",
          "fp-type-body",
          "fp-text-pretty",
          SIZES.fetch(@size),
          STYLES.fetch(@style)
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
        return if WEIGHTS.include?(@weight)

        raise ArgumentError, "Invalid weight: #{@weight}. Must be one of: #{WEIGHTS.join(", ")}"
      end

      def validate_as!
        return if AS.include?(@as)

        raise ArgumentError, "Invalid as: #{@as}. Must be one of: #{AS.join(", ")}"
      end
    end
  end
end
