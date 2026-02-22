# frozen_string_literal: true

module FlatPack
  module Chip
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--surface-muted-bg-color)]" "text-[var(--surface-content-color)]" "border-[var(--surface-border-color)]" "bg-primary" "text-primary-text" "border-primary" "bg-success-bg" "text-success-text" "border-success-border" "bg-warning-bg" "text-warning-text" "border-warning-border" "bg-destructive-bg" "text-destructive-text" "border-destructive-border" "bg-secondary" "text-secondary-text" "border-info-border"
      STYLES = {
        default: "bg-[var(--surface-muted-bg-color)] text-[var(--surface-content-color)] border-[var(--surface-border-color)]",
        primary: "bg-primary text-primary-text border-primary",
        success: "bg-success-bg text-success-text border-success-border",
        warning: "bg-warning-bg text-warning-text border-warning-border",
        danger: "bg-destructive-bg text-destructive-text border-destructive-border",
        info: "bg-secondary text-secondary-text border-info-border"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-xs" "px-[var(--chip-padding-x-sm)]" "py-[var(--chip-padding-y-sm)]" "text-sm" "px-[var(--chip-padding-x-md)]" "py-[var(--chip-padding-y-md)]" "text-base" "px-[var(--chip-padding-x-lg)]" "py-[var(--chip-padding-y-lg)]"
      SIZES = {
        sm: "text-xs px-[var(--chip-padding-x-sm)] py-[var(--chip-padding-y-sm)]",
        md: "text-sm px-[var(--chip-padding-x-md)] py-[var(--chip-padding-y-md)]",
        lg: "text-base px-[var(--chip-padding-x-lg)] py-[var(--chip-padding-y-lg)]"
      }.freeze

      TYPES = %i[static button link].freeze

      renders_one :leading
      renders_one :trailing
      renders_one :remove_button

      def initialize(
        text: nil,
        style: :default,
        size: :md,
        selected: false,
        disabled: false,
        removable: false,
        href: nil,
        type: :static,
        value: nil,
        name: nil,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @style = style.to_sym
        @size = size.to_sym
        @selected = selected
        @disabled = disabled
        @removable = removable && !disabled
        @href = href
        @type = type.to_sym
        @value = value
        @name = name

        validate_style!
        validate_size!
        validate_type!
      end

      def call
        content_tag(root_tag, **chip_attributes) do
          safe_join([
            leading,
            render_text_or_content,
            trailing,
            render_remove_button_content
          ].compact)
        end
      end

      private

      def root_tag
        return :span if @disabled && @type == :link
        return :button if @type == :button
        return :a if @type == :link
        :span
      end

      def render_text_or_content
        if @text.present?
          @text
        elsif content.present?
          content
        end
      end

      def render_remove_button_content
        return unless @removable
        return if remove_button.present?

        content_tag(:button,
          type: "button",
          class: "ml-1 inline-flex items-center justify-center rounded-full hover:bg-[var(--chip-remove-hover-background-color)] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-ring",
          "aria-label": "Remove",
          data: {action: "click->flat-pack--chip#remove"}) do
          # X icon (close)
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-3 w-3", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z", "clip-rule": "evenodd")
          end
        end
      end

      def chip_attributes
        attrs = {class: chip_classes}

        # Add controller and target if removable
        if @removable
          attrs[:data] = {
            controller: "flat-pack--chip",
            flat_pack__chip_target: "chip",
            flat_pack__chip_value_value: @value
          }
        end

        # Add button-specific attributes
        if @type == :button
          attrs[:type] = "button"
          attrs[:disabled] = true if @disabled
          attrs[:aria] = {pressed: @selected.to_s}
        end

        # Add link-specific attributes
        if @type == :link && !@disabled
          attrs[:href] = @href
        end

        merge_attributes(**attrs)
      end

      def chip_classes
        classes(
          "inline-flex items-center gap-1.5",
          "rounded-[var(--chip-border-radius)] font-medium",
          "border",
          "transition-colors duration-base",
          STYLES.fetch(@style),
          SIZES.fetch(@size),
          disabled_classes,
          selected_classes,
          focus_classes
        )
      end

      def disabled_classes
        return unless @disabled
        "opacity-50 cursor-not-allowed"
      end

      def selected_classes
        return unless @selected && @type == :button
        "ring-2 ring-ring"
      end

      def focus_classes
        return unless @type == :button || @type == :link
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
      end

      def validate_style!
        return if STYLES.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_type!
        return if TYPES.include?(@type)
        raise ArgumentError, "Invalid type: #{@type}. Must be one of: #{TYPES.join(", ")}"
      end
    end
  end
end
