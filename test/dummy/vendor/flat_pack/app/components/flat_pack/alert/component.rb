# frozen_string_literal: true

module FlatPack
  module Alert
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "border-[var(--alert-info-border-color)]" "bg-[var(--alert-info-background-color)]" "text-[var(--alert-info-text-color)]" "text-[var(--alert-info-icon-color)]"
      # "border-[var(--alert-success-border-color)]" "bg-[var(--alert-success-background-color)]" "text-[var(--alert-success-text-color)]" "text-[var(--alert-success-icon-color)]"
      # "border-[var(--alert-warning-border-color)]" "bg-[var(--alert-warning-background-color)]" "text-[var(--alert-warning-text-color)]" "text-[var(--alert-warning-icon-color)]"
      # "border-[var(--alert-danger-border-color)]" "bg-[var(--alert-danger-background-color)]" "text-[var(--alert-danger-text-color)]" "text-[var(--alert-danger-icon-color)]"
      VARIANTS = {
        info: {
          border: "border border-[var(--alert-info-border-color)]",
          bg: "bg-[var(--alert-info-background-color)]",
          text: "text-[var(--alert-info-text-color)]",
          icon_color: "text-[var(--alert-info-icon-color)]",
          icon: "information-circle"
        },
        success: {
          border: "border border-[var(--alert-success-border-color)]",
          bg: "bg-[var(--alert-success-background-color)]",
          text: "text-[var(--alert-success-text-color)]",
          icon_color: "text-[var(--alert-success-icon-color)]",
          icon: "check-circle"
        },
        warning: {
          border: "border border-[var(--alert-warning-border-color)]",
          bg: "bg-[var(--alert-warning-background-color)]",
          text: "text-[var(--alert-warning-text-color)]",
          icon_color: "text-[var(--alert-warning-icon-color)]",
          icon: "exclamation-triangle"
        },
        danger: {
          border: "border border-[var(--alert-danger-border-color)]",
          bg: "bg-[var(--alert-danger-background-color)]",
          text: "text-[var(--alert-danger-text-color)]",
          icon_color: "text-[var(--alert-danger-icon-color)]",
          icon: "exclamation-circle"
        }
      }.freeze

      def initialize(
        title: nil,
        description: nil,
        style: :info,
        dismissible: false,
        icon: true,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @style = style.to_sym
        @dismissible = dismissible
        @show_icon = icon

        validate_style!
      end

      def call
        content_tag(:div, **alert_attributes) do
          safe_join([
            render_content_area,
            render_dismiss_button
          ].compact)
        end
      end

      private

      def render_content_area
        content_tag(:div, class: "flex items-center gap-3") do
          safe_join([
            render_icon,
            render_text_content
          ].compact)
        end
      end

      def render_icon
        return unless @show_icon

        icon_name = style_config[:icon]
        content_tag(:div, class: classes("flex-shrink-0", style_config[:icon_color])) do
          render(FlatPack::Shared::IconComponent.new(name: icon_name, size: :md))
        end
      end

      def render_text_content
        content_tag(:div, class: "flex-1") do
          if content.present?
            content
          else
            safe_join([
              render_title,
              render_description
            ].compact)
          end
        end
      end

      def render_title
        return unless @title

        content_tag(:h3, @title, class: "font-semibold text-[var(--alert-title-color)]")
      end

      def render_description
        return unless @description

        content_tag(:p, @description, class: "text-sm text-[var(--alert-description-color)]")
      end

      def render_dismiss_button
        return unless @dismissible

        content_tag(:button,
          type: "button",
          class: "ml-auto flex-shrink-0 inline-flex items-center justify-center rounded-[var(--alert-dismiss-button-radius)] p-1.5 text-[var(--alert-dismiss-button-text-color)] hover:bg-[var(--alert-dismiss-button-hover-background-color)] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[var(--alert-dismiss-button-focus-ring-color)]",
          data: {action: "alert#dismiss"},
          "aria-label": "Dismiss") do
          # X icon
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-4 w-4", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z", "clip-rule": "evenodd")
          end
        end
      end

      def alert_attributes
        attrs = {
          class: alert_classes,
          role: "alert"
        }
        attrs[:data] = {controller: "alert", alert_target: "alert"} if @dismissible
        merge_attributes(**attrs)
      end

      def alert_classes
        classes(
          "relative flex items-center gap-3",
          "rounded-[var(--alert-border-radius)]",
          "p-[var(--alert-padding)]",
          style_config[:border],
          style_config[:bg],
          style_config[:text]
        )
      end

      def style_config
        VARIANTS.fetch(@style)
      end

      def validate_style!
        return if VARIANTS.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end
    end
  end
end
