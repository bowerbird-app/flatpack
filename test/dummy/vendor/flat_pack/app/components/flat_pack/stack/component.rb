# frozen_string_literal: true

module FlatPack
  module Stack
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "flex" "flex-col" "gap-2" "gap-4" "gap-6"
      # "items-start" "items-center" "items-stretch"
      GAPS = {
        sm: "gap-2",
        md: "gap-4",
        lg: "gap-6"
      }.freeze

      ALIGNS = {
        start: "items-start",
        center: "items-center",
        stretch: "items-stretch"
      }.freeze

      def initialize(
        gap: :md,
        align: :stretch,
        **system_arguments
      )
        super(**system_arguments)
        @gap = gap.to_sym
        @align = align.to_sym

        validate_gap!
        validate_align!
      end

      def call
        content_tag(:div, content, **container_attributes)
      end

      private

      def container_attributes
        merge_attributes(
          class: stack_classes
        )
      end

      def stack_classes
        classes(
          "flex flex-col",
          gap_classes,
          align_classes
        )
      end

      def gap_classes
        GAPS.fetch(@gap)
      end

      def align_classes
        ALIGNS.fetch(@align)
      end

      def validate_gap!
        return if GAPS.key?(@gap)

        raise ArgumentError, "Invalid gap: #{@gap}. Must be one of: #{GAPS.keys.join(", ")}"
      end

      def validate_align!
        return if ALIGNS.key?(@align)

        raise ArgumentError, "Invalid align: #{@align}. Must be one of: #{ALIGNS.keys.join(", ")}"
      end
    end
  end
end
