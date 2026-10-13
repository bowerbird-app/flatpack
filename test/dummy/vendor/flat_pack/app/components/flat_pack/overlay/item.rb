# frozen_string_literal: true

module FlatPack
  module Overlay
    class Item < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "absolute" "z-10" "h-max" "w-max"
      # "top-[var(--overlay-inset-sm)]" "right-[var(--overlay-inset-sm)]" "bottom-[var(--overlay-inset-sm)]" "left-[var(--overlay-inset-sm)]"
      # "top-[var(--overlay-inset-md)]" "right-[var(--overlay-inset-md)]" "bottom-[var(--overlay-inset-md)]" "left-[var(--overlay-inset-md)]"
      # "top-[var(--overlay-inset-lg)]" "right-[var(--overlay-inset-lg)]" "bottom-[var(--overlay-inset-lg)]" "left-[var(--overlay-inset-lg)]"
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

      # Gap sizes are --overlay-inset-sm (0.5rem), --overlay-inset-md (1rem),
      # and --overlay-inset-lg (1.5rem). :center does not use the inset.
      # Edge centers use it on the edge axis only.
      INSETS = {
        sm: {
          top_left: "absolute z-10 h-max w-max top-[var(--overlay-inset-sm)] left-[var(--overlay-inset-sm)]",
          top_center: "absolute z-10 h-max w-max top-[var(--overlay-inset-sm)] left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-[var(--overlay-inset-sm)] right-[var(--overlay-inset-sm)]",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-[var(--overlay-inset-sm)] -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-[var(--overlay-inset-sm)] -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-sm)] left-[var(--overlay-inset-sm)]",
          bottom_center: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-sm)] left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-sm)] right-[var(--overlay-inset-sm)]"
        },
        md: {
          top_left: "absolute z-10 h-max w-max top-[var(--overlay-inset-md)] left-[var(--overlay-inset-md)]",
          top_center: "absolute z-10 h-max w-max top-[var(--overlay-inset-md)] left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-[var(--overlay-inset-md)] right-[var(--overlay-inset-md)]",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-[var(--overlay-inset-md)] -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-[var(--overlay-inset-md)] -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-md)] left-[var(--overlay-inset-md)]",
          bottom_center: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-md)] left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-md)] right-[var(--overlay-inset-md)]"
        },
        lg: {
          top_left: "absolute z-10 h-max w-max top-[var(--overlay-inset-lg)] left-[var(--overlay-inset-lg)]",
          top_center: "absolute z-10 h-max w-max top-[var(--overlay-inset-lg)] left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-[var(--overlay-inset-lg)] right-[var(--overlay-inset-lg)]",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-[var(--overlay-inset-lg)] -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-[var(--overlay-inset-lg)] -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-lg)] left-[var(--overlay-inset-lg)]",
          bottom_center: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-lg)] left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-[var(--overlay-inset-lg)] right-[var(--overlay-inset-lg)]"
        }
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
        INSETS.fetch(@inset).fetch(@placement)
      end

      def validate_placement!
        return if PLACEMENTS.include?(@placement)

        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.join(", ")}"
      end

      def validate_inset!
        return if INSETS.key?(@inset)

        raise ArgumentError, "Invalid inset: #{@inset}. Must be one of: #{INSETS.keys.join(", ")}"
      end
    end
  end
end
