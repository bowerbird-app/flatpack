# frozen_string_literal: true

module FlatPack
  module Cluster
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "flex" "flex-wrap"
      # "gap-[var(--stack-gap-sm)]" "gap-[var(--stack-gap-md)]" "gap-[var(--stack-gap-lg)]"
      # "items-start" "items-center" "items-stretch"
      # "justify-start" "justify-center" "justify-end" "justify-between"
      JUSTIFIES = {
        start: "justify-start",
        center: "justify-center",
        end: "justify-end",
        between: "justify-between"
      }.freeze

      def initialize(
        gap: :md,
        align: :center,
        justify: :start,
        **system_arguments
      )
        super(**system_arguments)
        @gap = gap.to_sym
        @align = align.to_sym
        @justify = justify.to_sym

        validate_gap!
        validate_align!
        validate_justify!
      end

      def call
        content_tag(:div, content, **container_attributes)
      end

      private

      def container_attributes
        merge_attributes(
          class: cluster_classes
        )
      end

      def cluster_classes
        classes(
          "flex flex-wrap",
          gap_classes,
          align_classes,
          justify_classes
        )
      end

      def gap_classes
        FlatPack::Shared::Flex.gap_class(@gap)
      end

      def align_classes
        FlatPack::Shared::Flex.align_class(@align)
      end

      def justify_classes
        JUSTIFIES.fetch(@justify)
      end

      def validate_gap!
        FlatPack::Shared::Flex.validate_gap!(@gap)
      end

      def validate_align!
        FlatPack::Shared::Flex.validate_align!(@align)
      end

      def validate_justify!
        return if JUSTIFIES.key?(@justify)

        raise ArgumentError, "Invalid justify: #{@justify}. Must be one of: #{JUSTIFIES.keys.join(", ")}"
      end
    end
  end
end
