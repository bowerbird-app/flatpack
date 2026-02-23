# frozen_string_literal: true

module FlatPack
  module Button
    class Component < FlatPack::BaseComponent
      SCHEMES = {
        default: "bg-[var(--button-default-background-color)] hover:bg-[var(--button-default-hover-background-color)] text-[var(--button-default-text-color)] border border-[var(--button-default-border-color)] shadow-[var(--button-shadow)]",
        primary: "bg-[var(--button-primary-background-color)] hover:bg-[var(--button-primary-hover-background-color)] text-[var(--button-primary-text-color)] border border-[var(--button-primary-border-color)] shadow-[var(--button-shadow)]",
        secondary: "bg-[var(--button-secondary-background-color)] hover:bg-[var(--button-secondary-hover-background-color)] text-[var(--button-secondary-text-color)] border border-[var(--button-secondary-border-color)]",
        ghost: "bg-[var(--button-ghost-background-color)] hover:bg-[var(--button-ghost-hover-background-color)] text-[var(--button-ghost-text-color)] border border-[var(--button-ghost-border-color)]",
        success: "bg-[var(--button-success-background-color)] hover:bg-[var(--button-success-hover-background-color)] text-[var(--button-success-text-color)] border border-[var(--button-success-border-color)] shadow-[var(--button-shadow)]",
        warning: "bg-[var(--button-warning-background-color)] hover:bg-[var(--button-warning-hover-background-color)] text-[var(--button-warning-text-color)] border border-[var(--button-warning-border-color)] shadow-[var(--button-shadow)]",
        error: "bg-[var(--button-danger-background-color)] hover:bg-[var(--button-danger-hover-background-color)] text-[var(--button-danger-text-color)] border border-[var(--button-danger-border-color)] shadow-[var(--button-shadow)]"
      }.freeze

      SIZES = {
        sm: "px-[var(--button-padding-x-sm)] py-[var(--button-padding-y-sm)] text-xs",
        md: "px-[var(--button-padding-x-md)] py-[var(--button-padding-y-md)] text-sm",
        lg: "px-[var(--button-padding-x-lg)] py-[var(--button-padding-y-lg)] text-base"
      }.freeze

      ICON_ONLY_SIZES = {
        sm: "p-[var(--button-icon-only-padding-sm)]",
        md: "p-[var(--button-icon-only-padding-md)]",
        lg: "p-[var(--button-icon-only-padding-lg)]"
      }.freeze

      def initialize(
        text: nil,
        style: :default,
        size: :md,
        url: nil,
        method: nil,
        target: nil,
        icon: nil,
        icon_only: false,
        loading: false,
        type: "button",
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @style = style.to_sym
        @size = size.to_sym
        @method = method
        @target = target
        @icon = icon
        @icon_only = icon_only
        @loading = loading
        @type = type

        # Sanitize URL for security and validate
        if url
          @url = FlatPack::AttributeSanitizer.sanitize_url(url)
          validate_url!(url)
        else
          @url = nil
        end

        validate_style!
        validate_size!
        validate_content!
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
          button_content
        end
      end

      def render_button
        button_tag(**button_attributes) do
          button_content
        end
      end

      def button_content
        content = []

        if @loading
          content << spinner_html
          content << content_tag(:span, "Loading") unless @icon_only
        else
          content << render_icon if @icon
          content << content_tag(:span, @text) if @text
        end

        safe_join(content)
      end

      def render_icon
        render FlatPack::Shared::IconComponent.new(name: @icon, size: @size)
      end

      def spinner_html
        # Simple CSS spinner using inline SVG
        size_classes = FlatPack::Shared::IconComponent::SIZES.fetch(@size)
        content_tag(:svg, class: "animate-spin #{size_classes}", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24") do
          content_tag(:circle, nil, class: "opacity-25", cx: "12", cy: "12", r: "10", stroke: "currentColor", "stroke-width": "4") +
            content_tag(:path, nil, class: "opacity-75", fill: "currentColor", d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z")
        end
      end

      def icon_size
        case @size
        when :sm then :sm
        when :md then :md
        when :lg then :lg
        end
      end

      def conditional_size_classes
        @icon_only ? nil : size_classes
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
        attrs = {
          type: @type,
          class: button_classes
        }
        attrs[:disabled] = true if @loading
        merge_attributes(**attrs)
      end

      def button_classes
        classes(
          "inline-flex items-center justify-center gap-2",
          "rounded-[var(--button-border-radius)]",
          "font-medium",
          "cursor-pointer",
          "transition-colors duration-base",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]",
          "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)]",
          conditional_size_classes,
          style_classes,
          icon_only_classes
        )
      end

      def icon_only_classes
        return unless @icon_only

        ICON_ONLY_SIZES.fetch(@size)
      end

      def style_classes
        SCHEMES.fetch(@style)
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_style!
        return if SCHEMES.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{SCHEMES.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_content!
        # Valid scenarios:
        # 1. Has text (with or without icon)
        # 2. Has icon
        has_text = @text.present?
        has_icon = @icon.present?
        is_valid = has_text || has_icon
        return if is_valid

        raise ArgumentError, "Button must have either a text prop or an icon prop"
      end

      def validate_url!(original_url)
        # Check if the original URL was provided but sanitization failed
        return if @url.present?

        # Use a generic error message to avoid leaking sensitive information in logs
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
