# frozen_string_literal: true

module FlatPack
  module Shared
    # Gap and cross-axis alignment for Grid, Stack, and Cluster.
    # Column and span breakpoint classes go through Breakpoints.
    module Flex
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "gap-[var(--stack-gap-sm)]" "gap-[var(--stack-gap-md)]" "gap-[var(--stack-gap-lg)]"
      # "items-start" "items-center" "items-stretch"
      GAPS = {
        sm: "gap-[var(--stack-gap-sm)]",
        md: "gap-[var(--stack-gap-md)]",
        lg: "gap-[var(--stack-gap-lg)]"
      }.freeze

      ALIGNS = {
        start: "items-start",
        center: "items-center",
        stretch: "items-stretch"
      }.freeze

      module_function

      def gap_class(gap)
        GAPS.fetch(gap)
      end

      def align_class(align)
        ALIGNS.fetch(align)
      end

      def validate_gap!(gap)
        return if GAPS.key?(gap)

        raise ArgumentError, "Invalid gap: #{gap}. Must be one of: #{GAPS.keys.join(", ")}"
      end

      def validate_align!(align)
        return if ALIGNS.key?(align)

        raise ArgumentError, "Invalid align: #{align}. Must be one of: #{ALIGNS.keys.join(", ")}"
      end

      def utility(breakpoint, class_name)
        Breakpoints.utility(breakpoint, class_name)
      end
    end
  end
end
