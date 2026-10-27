# frozen_string_literal: true

module FlatPack
  module Overlay
    class Item < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "absolute" "z-10" "h-max" "w-max"
      # "top-[var(--fp-overlay-item-inset)]" "right-[var(--fp-overlay-item-inset)]"
      # "bottom-[var(--fp-overlay-item-inset)]" "left-[var(--fp-overlay-item-inset)]"
      # "top-1/2" "left-1/2" "-translate-x-1/2" "-translate-y-1/2"

      PLACEMENTS = %i[
        top_left
        top_center
        top_right
        middle_left
        center
        middle_right
        bottom_left
        bottom_center
        bottom_right
      ].freeze

      # The length is --fp-overlay-item-inset, set on the item from data-fp-inset.
      # sm/md/lg are resolved there, not on :root. :center does not use the inset.
      # Edge centers use it on the edge axis only.
      INSETS = %i[sm md lg].freeze

      PLACEMENT_CLASSES = {
        top_left: "absolute z-10 h-max w-max top-[var(--fp-overlay-item-inset)] left-[var(--fp-overlay-item-inset)]",
        top_center: "absolute z-10 h-max w-max top-[var(--fp-overlay-item-inset)] left-1/2 -translate-x-1/2",
        top_right: "absolute z-10 h-max w-max top-[var(--fp-overlay-item-inset)] right-[var(--fp-overlay-item-inset)]",
        middle_left: "absolute z-10 h-max w-max top-1/2 left-[var(--fp-overlay-item-inset)] -translate-y-1/2",
        center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
        middle_right: "absolute z-10 h-max w-max top-1/2 right-[var(--fp-overlay-item-inset)] -translate-y-1/2",
        bottom_left: "absolute z-10 h-max w-max bottom-[var(--fp-overlay-item-inset)] left-[var(--fp-overlay-item-inset)]",
        bottom_center: "absolute z-10 h-max w-max bottom-[var(--fp-overlay-item-inset)] left-1/2 -translate-x-1/2",
        bottom_right: "absolute z-10 h-max w-max bottom-[var(--fp-overlay-item-inset)] right-[var(--fp-overlay-item-inset)]"
      }.freeze

      def initialize(placement: :top_left, inset: :md, **system_arguments)
        super(**system_arguments)
        @placement = placement.to_sym
        @inset = inset.to_sym

        validate_placement!
        validate_inset!
      end

      def call
        content_tag(:div, content, **item_attributes)
      end

      private

      def item_attributes
        merge_attributes(
          class: position_classes,
          data: {
            fp_placement: @placement.to_s,
            fp_inset: @inset.to_s
          }
        )
      end

      def position_classes
        PLACEMENT_CLASSES.fetch(@placement)
      end

      def validate_placement!
        return if PLACEMENTS.include?(@placement)

        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.join(", ")}"
      end

      def validate_inset!
        return if INSETS.include?(@inset)

        raise ArgumentError, "Invalid inset: #{@inset}. Must be one of: #{INSETS.join(", ")}"
      end
    end
  end
end
