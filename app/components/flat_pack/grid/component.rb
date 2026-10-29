# frozen_string_literal: true

module FlatPack
  module Grid
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "grid-cols-1" "grid-cols-2" "grid-cols-3" "grid-cols-4" "grid-cols-6" "grid-cols-12"
      # "sm:grid-cols-2" "md:grid-cols-2" "md:grid-cols-3" "md:grid-cols-4" "md:grid-cols-6"
      # "lg:grid-cols-3" "lg:grid-cols-4" "lg:grid-cols-6" "lg:grid-cols-12" "xl:grid-cols-4"
      # "gap-[var(--stack-gap-sm)]" "gap-[var(--stack-gap-md)]" "gap-[var(--stack-gap-lg)]"
      # "items-start" "items-center" "items-stretch"
      # The catalog reads these names here. The maps live on Shared::Flex.
      GAPS = FlatPack::Shared::Flex::GAPS
      ALIGNS = FlatPack::Shared::Flex::ALIGNS
      COLUMN_PRESETS = {
        1 => {base: 1},
        2 => {base: 1, md: 2},
        3 => {base: 1, md: 2, lg: 3},
        4 => {base: 1, md: 2, lg: 4},
        6 => {base: 2, md: 3, lg: 6},
        12 => {base: 2, md: 4, lg: 12},
        :auto => {base: 1, sm: 2, lg: 3, xl: 4}
      }.freeze

      renders_many :items, lambda { |**system_arguments|
        FlatPack::Grid::Item.new(columns: COLUMN_PRESETS.fetch(@cols), **system_arguments)
      }

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
        captured = content
        content_tag(:div, **container_attributes) do
          if items?
            safe_join(items)
          else
            captured
          end
        end
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
        COLUMN_PRESETS.fetch(@cols).map do |breakpoint, count|
          FlatPack::Shared::Breakpoints.utility(breakpoint, "grid-cols-#{count}")
        end
      end

      def gap_classes
        FlatPack::Shared::Flex.gap_class(@gap)
      end

      def align_classes
        FlatPack::Shared::Flex.align_class(@align)
      end

      def validate_cols!
        return if COLUMN_PRESETS.key?(@cols)

        raise ArgumentError, "Invalid cols: #{@cols}. Must be one of: #{COLUMN_PRESETS.keys.join(", ")}"
      end

      def validate_gap!
        FlatPack::Shared::Flex.validate_gap!(@gap)
      end

      def validate_align!
        FlatPack::Shared::Flex.validate_align!(@align)
      end
    end
  end
end
