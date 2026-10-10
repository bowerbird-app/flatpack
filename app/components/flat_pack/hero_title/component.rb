# frozen_string_literal: true

module FlatPack
  module HeroTitle
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-hero-title" "fp-hero-title--md" "fp-hero-title--lg" "fp-hero-title--xl" "fp-hero-title--xxl"
      # "fp-display" "fp-text-balance" "text-left" "text-center"
      # "text-[var(--surface-content-color)]"
      SIZES = %i[md lg xl xxl].freeze
      LEVELS = %i[h1 h2 h3 h4 h5 h6].freeze
      ALIGNS = {
        left: "text-left",
        center: "text-center"
      }.freeze
      DEFAULT_SIZE = :xl

      def initialize(
        text: nil,
        size: :xl,
        level: :h1,
        align: nil,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @size = size.to_sym
        @level = level.to_sym
        @align = align&.to_sym
        # Prepend so a caller text-* class (Hero overlay ink, a host colour)
        # still wins through Tailwind Merge.
        @system_arguments[:class] = [
          "text-[var(--surface-content-color)]",
          @system_arguments[:class]
        ].compact_blank.join(" ")

        validate_size!
        validate_level!
        validate_align!
      end

      def call
        raise ArgumentError, "text is required" if heading_text.blank?

        content_tag(@level, heading_text, **heading_attributes)
      end

      private

      def heading_attributes
        merge_attributes(
          class: heading_classes,
          style: heading_style
        )
      end

      def heading_classes
        [
          "fp-hero-title",
          "fp-hero-title--#{@size}",
          (@size == :xl) ? "fp-display" : nil,
          "fp-text-balance",
          align_class
        ].compact.join(" ")
      end

      def heading_style
        [
          html_attributes[:style],
          "font-size: #{size_token}",
          "font-weight: var(--display-weight)",
          "letter-spacing: var(--display-tracking)",
          "line-height: var(--display-leading)"
        ].compact_blank.join("; ").presence
      end

      def size_token
        (@size == :xl) ? "var(--display-size)" : "var(--hero-title-#{@size}-size)"
      end

      def align_class
        return nil if @align.nil?

        ALIGNS.fetch(@align)
      end

      def heading_text
        @heading_text ||= @text.presence || content
      end

      def validate_size!
        return if SIZES.include?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.join(", ")}"
      end

      def validate_level!
        return if LEVELS.include?(@level)

        raise ArgumentError, "Invalid level: #{@level}. Must be one of: #{LEVELS.join(", ")}"
      end

      def validate_align!
        return if @align.nil? || ALIGNS.key?(@align)

        raise ArgumentError, "Invalid align: #{@align}. Must be one of: #{ALIGNS.keys.join(", ")}"
      end
    end
  end
end
