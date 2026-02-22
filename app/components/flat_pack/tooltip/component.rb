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
            action: "mouseenter->flat-pack--tooltip#show mouseleave->flat-pack--tooltip#hide focusin->flat-pack--tooltip#show focusout->flat-pack--tooltip#hide",
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
          style: tooltip_fallback_styles,
          data: {
            "flat-pack--tooltip-target": "tooltip"
          }
        }
      end

      def tooltip_fallback_styles
        "background-color: var(--tooltip-background-color, var(--surface-content-color)); color: var(--tooltip-text-color, var(--surface-bg-color)); border-color: var(--tooltip-border-color, var(--surface-border-color));"
      end

      def tooltip_classes
        classes(
          "fixed",
          "z-50",
          "hidden",
          "px-[var(--tooltip-padding-x)]",
          "py-[var(--tooltip-padding-y)]",
          "text-[length:var(--tooltip-font-size)]",
          "leading-snug",
          "font-medium",
          "text-[var(--tooltip-text-color)]",
          "bg-[var(--tooltip-background-color)]",
          "border",
          "border-[var(--tooltip-border-color)]",
          "rounded-[var(--tooltip-radius)]",
          "shadow-[var(--tooltip-shadow)]",
          "max-w-[var(--tooltip-max-width)]",
          "whitespace-normal",
          "break-words",
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
