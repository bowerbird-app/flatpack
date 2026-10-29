# frozen_string_literal: true

module FlatPack
  module Stack
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "flex" "flex-col"
      # "gap-[var(--stack-gap-sm)]" "gap-[var(--stack-gap-md)]" "gap-[var(--stack-gap-lg)]"
      # "items-start" "items-center" "items-stretch"
      # The catalog reads these names here. The maps live on Shared::Flex.
      GAPS = FlatPack::Shared::Flex::GAPS
      ALIGNS = FlatPack::Shared::Flex::ALIGNS

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
        FlatPack::Shared::Flex.gap_class(@gap)
      end

      def align_classes
        FlatPack::Shared::Flex.align_class(@align)
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
