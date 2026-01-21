# frozen_string_literal: true

module FlatPack
  module Button
    class Component < FlatPack::BaseComponent
      SCHEMES = {
        primary: "bg-[var(--color-primary)] hover:bg-[var(--color-primary-hover)] text-[var(--color-primary-text)] shadow-[var(--shadow-sm)]",
        secondary: "bg-[var(--color-secondary)] hover:bg-[var(--color-secondary-hover)] text-[var(--color-secondary-text)] border border-[var(--color-border)]",
        ghost: "bg-[var(--color-ghost)] hover:bg-[var(--color-ghost-hover)] text-[var(--color-ghost-text)]"
      }.freeze

      SIZES = {
        sm: "px-3 py-1.5 text-xs",
        md: "px-4 py-2 text-sm",
        lg: "px-6 py-3 text-base"
      }.freeze

      def initialize(
        label:,
        scheme: :primary,
        size: :md,
        url: nil,
        method: nil,
        target: nil,
        **system_arguments
      )
        super(**system_arguments)
        @label = label
        @scheme = scheme.to_sym
        @size = size.to_sym
        @url = url
        @method = method
        @target = target

        validate_scheme!
        validate_size!
      end

      def call
        if @url
          render_link
        else
          render_button
        end
      end

      private

      def render_link
        link_to @url, **link_attributes do
          @label
        end
      end

      def render_button
        button_tag @label, **button_attributes
      end

      def link_attributes
        attrs = {
          class: button_classes,
          method: @method,
          target: @target
        }
        # Add rel="noopener noreferrer" for security when opening in new tab
        attrs[:rel] = "noopener noreferrer" if @target == "_blank"
        merge_attributes(**attrs).compact
      end

      def button_attributes
        merge_attributes(
          type: "button",
          class: button_classes
        )
      end

      def button_classes
        classes(
          "inline-flex items-center justify-center",
          "rounded-[var(--radius-md)]",
          "font-medium",
          "transition-colors duration-[var(--transition-base)]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2",
          "disabled:pointer-events-none disabled:opacity-50",
          size_classes,
          scheme_classes
        )
      end

      def scheme_classes
        SCHEMES.fetch(@scheme)
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_scheme!
        return if SCHEMES.key?(@scheme)
        raise ArgumentError, "Invalid scheme: #{@scheme}. Must be one of: #{SCHEMES.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
