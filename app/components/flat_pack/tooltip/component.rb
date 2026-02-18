# frozen_string_literal: true

module FlatPack
  module Tooltip
    class Component < FlatPack::BaseComponent
      renders_one :tooltip_content

      PLACEMENTS = {
        top: :top,
        bottom: :bottom,
        left: :left,
        right: :right
      }.freeze

      def initialize(
        text: nil,
        placement: :top,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @placement = placement.to_sym

        validate_placement!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            content,
            render_tooltip_content
          ])
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes,
          data: {
            controller: "flat-pack--tooltip",
            "flat-pack--tooltip-placement-value": @placement
          }
        )
      end

      def container_classes
        classes(
          "relative",
          "inline-flex"
        )
      end

      def render_tooltip_content
        content_tag(:div, **tooltip_attributes) do
          if tooltip_content?
            # SECURITY: Slot content is marked html_safe because it's expected to contain
            # Rails-generated HTML from other components. Never pass unsanitized user input
            # directly to this slot.
            tooltip_content.to_s.html_safe
          else
            @text
          end
        end
      end

      def tooltip_attributes
        {
          role: "tooltip",
          class: tooltip_classes,
          data: {
            "flat-pack--tooltip-target": "tooltip"
          }
        }
      end

      def tooltip_classes
        classes(
          "absolute",
          "z-50",
          "hidden",
          "px-2",
          "py-1",
          "text-xs",
          "font-medium",
          "text-[var(--color-primary-text)]",
          "bg-[var(--color-text)]",
          "rounded-[var(--radius-sm)]",
          "shadow-lg",
          "whitespace-nowrap",
          "pointer-events-none",
          "opacity-0",
          "transition-opacity",
          "duration-200"
        )
      end

      def validate_placement!
        return if PLACEMENTS.key?(@placement)
        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.keys.join(", ")}"
      end
    end
  end
end
