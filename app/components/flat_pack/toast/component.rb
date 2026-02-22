# frozen_string_literal: true

module FlatPack
  module Toast
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "border-info-border" "text-[var(--surface-content-color)]"
      # "border-success-border" "bg-success-bg/10" "text-success-border"
      # "border-warning-border" "bg-warning-bg/10" "text-warning-border"
      # "border-destructive-border" "bg-destructive-bg/10" "bg-destructive-bg" "text-destructive-border"
      # "bg-destructive-text/20" "hover:bg-destructive-text/30" "text-destructive-text"
      TYPES = {
        info: {
          border: "border-info-border",
          bg: "bg-[var(--surface-bg-color)]",
          text: "text-[var(--surface-content-color)]"
        },
        success: {
          border: "border-success-border",
          bg: "bg-[var(--surface-bg-color)]",
          text: "text-success-border"
        },
        warning: {
          border: "border-warning-border",
          bg: "bg-[var(--surface-bg-color)]",
          text: "text-warning-border"
        },
        error: {
          border: "border-destructive-border",
          bg: "bg-destructive-bg",
          text: "text-destructive-border"
        }
      }.freeze

      def initialize(
        message:,
        type: :info,
        timeout: 5000,
        dismissible: true,
        **system_arguments
      )
        super(**system_arguments)
        @message = message
        @type = type.to_sym
        @timeout = timeout
        @dismissible = dismissible

        validate_message!
        validate_type!
        validate_timeout!
      end

      def call
        content_tag(:div, **toast_attributes) do
          safe_join([
            render_icon,
            render_message,
            render_dismiss_button
          ].compact)
        end
      end

      private

      def toast_attributes
        merge_attributes(
          role: "status",
          aria: {live: "polite", atomic: "true"},
          class: toast_classes,
          data: {
            controller: "flat-pack--toast",
            "flat-pack--toast-timeout-value": @timeout,
            "flat-pack--toast-dismissible-value": @dismissible
          }
        )
      end

      def toast_classes
        type_styles = TYPES.fetch(@type)
        classes(
          "flex",
          "items-start",
          "gap-3",
          "p-4",
          "rounded-md",
          "border",
          "shadow-lg",
          "z-[60]",
          "min-w-[300px]",
          "max-w-md",
          type_styles[:border],
          type_styles[:bg]
        )
      end

      def render_icon
        type_styles = TYPES.fetch(@type)
        content_tag(:div, class: "flex-shrink-0 #{type_styles[:text]}") do
          icon_svg
        end
      end

      def icon_svg
        case @type
        when :success
          success_icon
        when :warning
          warning_icon
        when :error
          error_icon
        else
          info_icon
        end
      end

      def info_icon
        content_tag(:svg, class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do
          tag.path(
            "fill-rule": "evenodd",
            d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z",
            "clip-rule": "evenodd"
          )
        end
      end

      def success_icon
        content_tag(:svg, class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do
          tag.path(
            "fill-rule": "evenodd",
            d: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z",
            "clip-rule": "evenodd"
          )
        end
      end

      def warning_icon
        content_tag(:svg, class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do
          tag.path(
            "fill-rule": "evenodd",
            d: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z",
            "clip-rule": "evenodd"
          )
        end
      end

      def error_icon
        content_tag(:svg, class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do
          tag.path(
            "fill-rule": "evenodd",
            d: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z",
            "clip-rule": "evenodd"
          )
        end
      end

      def render_message
        content_tag(:p, @message, class: "flex-1 text-sm font-medium text-[var(--surface-content-color)]")
      end

      def render_dismiss_button
        return nil unless @dismissible

        content_tag(:button,
          type: "button",
          class: dismiss_button_classes,
          aria: {label: "Dismiss"},
          data: {action: "flat-pack--toast#dismiss"}) do
          content_tag(:svg, class: "w-4 h-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
            tag.path(
              "stroke-linecap": "round",
              "stroke-linejoin": "round",
              "stroke-width": "2",
              d: "M6 18L18 6M6 6l12 12"
            )
          end
        end
      end

      def dismiss_button_classes
        classes(
          "flex-shrink-0",
          "transition-colors",
          "rounded-sm",
          "p-1",
          "focus-visible:outline-none",
          "focus-visible:ring-2",
          "focus-visible:ring-ring",
          dismiss_button_type_classes
        )
      end

      def dismiss_button_type_classes
        if @type == :error
          "bg-destructive-text/20 hover:bg-destructive-text/30 text-destructive-text"
        else
          "text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)]"
        end
      end

      def validate_message!
        return if @message.present?
        raise ArgumentError, "message is required"
      end

      def validate_type!
        return if TYPES.key?(@type)
        raise ArgumentError, "Invalid type: #{@type}. Must be one of: #{TYPES.keys.join(", ")}"
      end

      def validate_timeout!
        return if @timeout.is_a?(Integer) && @timeout >= 0
        raise ArgumentError, "timeout must be a non-negative integer"
      end
    end
  end
end
