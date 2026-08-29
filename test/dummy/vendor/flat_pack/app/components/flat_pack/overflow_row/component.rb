# frozen_string_literal: true

module FlatPack
  module OverflowRow
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "gap-[var(--overflow-row-gap)]" "overflow-x-auto" "overflow-y-hidden"
      # "flex-nowrap" "min-w-0" "overscroll-x-contain"
      GAPS = {
        sm: "var(--stack-gap-sm)",
        md: "var(--stack-gap-md)",
        lg: "var(--stack-gap-lg)"
      }.freeze

      def initialize(
        gap: :md,
        **system_arguments
      )
        super(**system_arguments)
        @gap = gap.to_sym

        validate_gap!
      end

      def call
        content_tag(:div, **root_attributes) do
          content_tag(:div, **scroller_attributes) do
            content_tag(:div, content, **track_attributes)
          end
        end
      end

      private

      def root_attributes
        merge_attributes(
          class: root_classes,
          data: {
            controller: "flat-pack--overflow-row",
            can_scroll_end: "false"
          }
        )
      end

      def root_classes
        "relative min-w-0"
      end

      def scroller_attributes
        {
          class: scroller_classes,
          data: {
            flat_pack__overflow_row_target: "scroller",
            action: "scroll->flat-pack--overflow-row#update"
          }
        }
      end

      def scroller_classes
        classes(
          "overflow-x-auto overflow-y-hidden overscroll-x-contain",
          "fp-scrollbar-hidden fp-overflow-row-scroller"
        )
      end

      def track_attributes
        {
          class: track_classes,
          style: track_style,
          data: {
            flat_pack__overflow_row_target: "track"
          }
        }
      end

      def track_classes
        classes(
          "flex flex-nowrap items-start",
          "gap-[var(--overflow-row-gap)]",
          "py-1"
        )
      end

      def track_style
        "--overflow-row-gap: #{GAPS.fetch(@gap)}"
      end

      def validate_gap!
        return if GAPS.key?(@gap)

        raise ArgumentError, "Invalid gap: #{@gap}. Must be one of: #{GAPS.keys.join(", ")}"
      end
    end
  end
end
