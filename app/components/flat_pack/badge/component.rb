# frozen_string_literal: true

module FlatPack
  module Badge
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "border" "bg-[var(--badge-default-background-color)]" "text-[var(--badge-default-text-color)]" "border-[var(--badge-default-border-color)]" "bg-[var(--badge-primary-background-color)]" "text-[var(--badge-primary-text-color)]" "border-[var(--badge-primary-border-color)]" "bg-[var(--badge-success-background-color)]" "text-[var(--badge-success-text-color)]" "border-[var(--badge-success-border-color)]" "bg-[var(--badge-warning-background-color)]" "text-[var(--badge-warning-text-color)]" "border-[var(--badge-warning-border-color)]" "bg-[var(--badge-info-background-color)]" "text-[var(--badge-info-text-color)]" "border-[var(--badge-info-border-color)]"
      VARIANTS = {
        default: "border bg-[var(--badge-default-background-color)] text-[var(--badge-default-text-color)] border-[var(--badge-default-border-color)]",
        primary: "border bg-[var(--badge-primary-background-color)] text-[var(--badge-primary-text-color)] border-[var(--badge-primary-border-color)]",
        success: "border bg-[var(--badge-success-background-color)] text-[var(--badge-success-text-color)] border-[var(--badge-success-border-color)]",
        warning: "border bg-[var(--badge-warning-background-color)] text-[var(--badge-warning-text-color)] border-[var(--badge-warning-border-color)]",
        info: "border bg-[var(--badge-info-background-color)] text-[var(--badge-info-text-color)] border-[var(--badge-info-border-color)]"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-xs" "px-2.5" "py-1" "text-sm" "px-3" "text-base" "px-4" "py-2"
      SIZES = {
        sm: "text-xs px-2.5 py-1",
        md: "text-sm px-3 py-1",
        lg: "text-base px-4 py-2"
      }.freeze

      def initialize(
        text:,
        style: :default,
        size: :md,
        dot: false,
        removable: false,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @style = style.to_sym
        @size = size.to_sym
        @dot = dot
        @removable = removable

        validate_text!
        validate_style!
        validate_size!
      end

      def call
        content_tag(:span, **badge_attributes) do
          safe_join([
            render_dot,
            @text,
            render_remove_button
          ])
        end
      end

      private

      def render_dot
        return unless @dot

        content_tag(:span, nil, class: dot_classes, "aria-hidden": "true")
      end

      def render_remove_button
        return unless @removable

        content_tag(:button,
          type: "button",
          class: "ml-1 inline-flex items-center justify-center rounded-full hover:bg-black/10 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-ring",
          "aria-label": "Remove",
          data: {action: "click->flat-pack--badge#remove"}) do
          # X icon (close)
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-3 w-3", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z", "clip-rule": "evenodd")
          end
        end
      end

      def badge_attributes
        attrs = {class: badge_classes}
        if @removable
          attrs[:data] = {
            controller: "flat-pack--badge",
            flat_pack__badge_target: "badge"
          }
        end
        merge_attributes(**attrs)
      end

      def badge_classes
        classes(
          "inline-flex items-center gap-1",
          "rounded-full font-medium",
          "transition-colors duration-base",
          VARIANTS.fetch(@style),
          SIZES.fetch(@size)
        )
      end

      def dot_classes
        "inline-block h-2 w-2 rounded-full bg-current opacity-75"
      end

      def validate_text!
        return if @text.present?
        raise ArgumentError, "text is required"
      end

      def validate_style!
        return if VARIANTS.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
