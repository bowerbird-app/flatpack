# frozen_string_literal: true

module FlatPack
  module Grid
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "grid-cols-1" "grid-cols-2" "grid-cols-3" "grid-cols-4" "grid-cols-6" "grid-cols-12"
      # "md:grid-cols-2" "md:grid-cols-3" "md:grid-cols-4" "md:grid-cols-6"
      # "gap-2" "gap-4" "gap-6" "items-start" "items-center" "items-stretch"
      # "mx-auto" "max-w-sm" "w-full"
      COLS = {
        1 => "grid-cols-1",
        2 => "grid-cols-1 md:grid-cols-2",
        3 => "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
        4 => "grid-cols-1 md:grid-cols-2 lg:grid-cols-4",
        6 => "grid-cols-2 md:grid-cols-3 lg:grid-cols-6",
        12 => "grid-cols-2 md:grid-cols-4 lg:grid-cols-12",
        :auto => "grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
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

      # Places the grid box on the page. align: is items-* (within cells);
      # justify: centers the whole grid when paired with max: (e.g. auth forms).
      JUSTIFIES = {
        start: nil,
        center: "mx-auto"
      }.freeze

      # Same width language as Modal size: :sm → max-w-sm (form/card column).
      MAXES = {
        sm: "max-w-sm w-full"
      }.freeze

      def initialize(
        cols: :auto,
        gap: :md,
        align: :stretch,
        justify: :start,
        max: nil,
        **system_arguments
      )
        super(**system_arguments)
        @cols = cols.is_a?(Symbol) ? cols : cols.to_i
        @gap = gap.to_sym
        @align = align.to_sym
        @justify = justify.to_sym
        @max = max.nil? ? nil : max.to_sym

        validate_cols!
        validate_gap!
        validate_align!
        validate_justify!
        validate_max!
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
          align_classes,
          justify_classes,
          max_classes
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

      def justify_classes
        JUSTIFIES.fetch(@justify)
      end

      def max_classes
        return if @max.nil?

        MAXES.fetch(@max)
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

      def validate_justify!
        return if JUSTIFIES.key?(@justify)
        raise ArgumentError, "Invalid justify: #{@justify}. Must be one of: #{JUSTIFIES.keys.join(", ")}"
      end

      def validate_max!
        return if @max.nil? || MAXES.key?(@max)
        raise ArgumentError, "Invalid max: #{@max}. Must be one of: #{MAXES.keys.join(", ")}, or nil"
      end
    end
  end
end
