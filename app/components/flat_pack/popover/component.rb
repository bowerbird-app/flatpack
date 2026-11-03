# frozen_string_literal: true

module FlatPack
  module Popover
    class Component < FlatPack::BaseComponent
      renders_one :popover_content

      alias_method :popover_content_slot, :popover_content

      undef_method :with_popover_content, :with_popover_content_content

      def content(*args, **kwargs, &block)
        return super if args.empty? && kwargs.empty? && !block_given?

        popover_content(*args, **kwargs, &block)
      end

      def popover_content(*args, **kwargs, &block)
        return popover_content_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:popover_content, nil, *args, **kwargs, &block)
      end

      # Tailwind CSS scanning requires these classes as string literals.
      # DO NOT REMOVE:
      # "overflow-y-auto"

      PLACEMENTS = {
        top: :top,
        bottom: :bottom,
        left: :left,
        right: :right
      }.freeze
      PANEL_GAP = 12

      MAX_HEIGHT_PATTERN = /\A\d+(?:\.\d+)?(?:px|rem|em|ch|ex|vw|vh|vmin|vmax|%)\z/

      def initialize(
        trigger_id:,
        placement: :bottom,
        gap: PANEL_GAP,
        max_height: nil,
        **system_arguments
      )
        super(**system_arguments)
        @trigger_id = trigger_id
        @placement = placement.to_sym
        @gap = gap
        @max_height = normalize_max_height(max_height)

        validate_trigger_id!
        validate_placement!
        validate_gap!
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
          style: popover_style,
          data: {
            controller: "flat-pack--popover",
            "flat-pack--popover-trigger-id-value": @trigger_id,
            "flat-pack--popover-placement-value": @placement,
            "flat-pack--popover-gap-value": @gap
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
          "p-[var(--popover-padding)]",
          "opacity-0",
          "transition-[opacity,transform]",
          "duration-[var(--duration-base)]",
          "ease-[var(--easing-enter)]",
          ("overflow-y-auto" if @max_height)
        )
      end

      def popover_style
        return unless @max_height

        join_styles(html_attributes[:style] || html_attributes["style"], "max-height: #{@max_height};")
      end

      def validate_trigger_id!
        return if @trigger_id.present?
        raise ArgumentError, "trigger_id is required"
      end

      def validate_placement!
        return if PLACEMENTS.key?(@placement)
        raise ArgumentError, "Invalid placement: #{@placement}. Must be one of: #{PLACEMENTS.keys.join(", ")}"
      end

      def validate_gap!
        return if @gap.is_a?(Integer) && @gap >= 0

        raise ArgumentError, "gap: must be a non-negative Integer."
      end

      def normalize_max_height(max_height)
        return if max_height.nil?

        unless max_height.is_a?(String) && !value_html_safe?(max_height)
          raise ArgumentError, "max_height: must be a CSS length such as \"24rem\"."
        end

        length = max_height.strip
        return length if length.match?(MAX_HEIGHT_PATTERN)

        raise ArgumentError, "max_height: must be a CSS length such as \"24rem\"."
      end
    end
  end
end
