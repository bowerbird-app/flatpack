# frozen_string_literal: true

module FlatPack
  module Grid
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "grid-cols-1" "grid-cols-2" "grid-cols-3" "grid-cols-4" "grid-cols-6" "grid-cols-12"
      # "md:grid-cols-2" "md:grid-cols-3" "md:grid-cols-4" "md:grid-cols-6"
      # "gap-2" "gap-4" "gap-6" "items-start" "items-center" "items-stretch"
      COLS = {
        1 => "grid-cols-1",
        2 => "grid-cols-1 md:grid-cols-2",
        3 => "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
        4 => "grid-cols-1 md:grid-cols-2 lg:grid-cols-4",
        6 => "grid-cols-2 md:grid-cols-3 lg:grid-cols-6",
        12 => "grid-cols-2 md:grid-cols-4 lg:grid-cols-12",
        auto: "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
      }.freeze

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
        cols: :auto,
        gap: :md,
        align: :stretch,
        **system_arguments
      )
        super(**system_arguments)
        @cols = cols.is_a?(Symbol) ? cols : cols.to_i
        @gap = gap.to_sym
        @align = align.to_sym

        validate_cols!
        validate_gap!
        validate_align!
      end

      def call
        content_tag(:div, content, **container_attributes)
      end

      private

      def container_attributes
        merge_attributes(
          class: grid_classes
        )
      end

      def grid_classes
        classes(
          "grid",
          cols_classes,
          gap_classes,
          align_classes
        )
      end

      def cols_classes
        COLS.fetch(@cols)
      end

      def gap_classes
        GAPS.fetch(@gap)
      end

      def align_classes
        ALIGNS.fetch(@align)
      end

      def validate_cols!
        return if COLS.key?(@cols)
        raise ArgumentError, "Invalid cols: #{@cols}. Must be one of: #{COLS.keys.join(", ")}"
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
