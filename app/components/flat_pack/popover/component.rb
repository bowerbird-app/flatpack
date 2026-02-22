# frozen_string_literal: true

module FlatPack
  module Popover
    class Component < FlatPack::BaseComponent
      renders_one :popover_content

      PLACEMENTS = {
        top: :top,
        bottom: :bottom,
        left: :left,
        right: :right
      }.freeze

      def initialize(
        trigger_id:,
        placement: :bottom,
        **system_arguments
      )
        super(**system_arguments)
        @trigger_id = trigger_id
        @placement = placement.to_sym

        validate_trigger_id!
        validate_placement!
      end

      def call
        content_tag(:div, **popover_attributes) do
          render_popover_content
        end
      end

      private

      def render_popover_content
        return nil unless popover_content?

        # SECURITY: Slot content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components. Never pass unsanitized user input
        # directly to this slot.
        popover_content.to_s.html_safe
      end

      def popover_attributes
        merge_attributes(
          class: popover_classes,
          data: {
            controller: "flat-pack--popover",
            "flat-pack--popover-trigger-id-value": @trigger_id,
            "flat-pack--popover-placement-value": @placement
          },
          aria: {
            hidden: "true"
          }
        )
      end

      def popover_classes
        classes(
          "absolute",
          "z-40",
          "hidden",
          "bg-[var(--popover-background-color)]",
          "border",
          "border-[var(--popover-border-color)]",
          "text-[var(--popover-text-color)]",
          "rounded-[var(--popover-radius)]",
          "shadow-[var(--popover-shadow)]",
          "p-[var(--popover-padding)]"
        )
      end

      def validate_trigger_id!
        return if @trigger_id.present?
        raise ArgumentError, "trigger_id is required"
      end

      def validate_placement!
        return if PLACEMENTS.key?(@placement)
        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.keys.join(", ")}"
      end
    end
  end
end
