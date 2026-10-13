# frozen_string_literal: true

module FlatPack
  module Overlay
    class Item < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "absolute" "z-10" "h-max" "w-max"
      # "top-2" "right-2" "bottom-2" "left-2"
      # "top-4" "right-4" "bottom-4" "left-4"
      # "top-6" "right-6" "bottom-6" "left-6"
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

      # Inset steps follow the Tailwind spacing scale (--spacing is 0.25rem):
      # sm = * 2 (0.5rem), md = * 4 (1rem), lg = * 6 (1.5rem).
      # :center does not use the inset. Edge centers use it on the edge axis only.
      INSETS = {
        sm: {
          top_left: "absolute z-10 h-max w-max top-2 left-2",
          top_center: "absolute z-10 h-max w-max top-2 left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-2 right-2",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-2 -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-2 -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-2 left-2",
          bottom_center: "absolute z-10 h-max w-max bottom-2 left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-2 right-2"
        },
        md: {
          top_left: "absolute z-10 h-max w-max top-4 left-4",
          top_center: "absolute z-10 h-max w-max top-4 left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-4 right-4",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-4 -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-4 -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-4 left-4",
          bottom_center: "absolute z-10 h-max w-max bottom-4 left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-4 right-4"
        },
        lg: {
          top_left: "absolute z-10 h-max w-max top-6 left-6",
          top_center: "absolute z-10 h-max w-max top-6 left-1/2 -translate-x-1/2",
          top_right: "absolute z-10 h-max w-max top-6 right-6",
          middle_left: "absolute z-10 h-max w-max top-1/2 left-6 -translate-y-1/2",
          center: "absolute z-10 h-max w-max top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
          middle_right: "absolute z-10 h-max w-max top-1/2 right-6 -translate-y-1/2",
          bottom_left: "absolute z-10 h-max w-max bottom-6 left-6",
          bottom_center: "absolute z-10 h-max w-max bottom-6 left-1/2 -translate-x-1/2",
          bottom_right: "absolute z-10 h-max w-max bottom-6 right-6"
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
