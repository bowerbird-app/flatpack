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

      # Density for padding, title, and description. Each size uses its own padding token.
      # "gap-2" "gap-3" "gap-4" "text-sm" "text-base" "text-lg" "text-xs"
      # "p-[var(--alert-padding-sm)]" "p-[var(--alert-padding-md)]" "p-[var(--alert-padding-lg)]"
      SIZES = {
        sm: {
          padding: "p-[var(--alert-padding-sm)]",
          gap: "gap-2",
          title: "font-semibold text-sm text-[var(--alert-title-color)]",
          description: "text-xs text-[var(--alert-description-color)]",
          icon: :sm
        },
        md: {
          padding: "p-[var(--alert-padding-md)]",
          gap: "gap-3",
          title: "font-semibold text-[var(--alert-title-color)]",
          description: "text-sm text-[var(--alert-description-color)]",
          icon: :md
        },
        lg: {
          padding: "p-[var(--alert-padding-lg)]",
          gap: "gap-4",
          title: "font-semibold text-lg text-[var(--alert-title-color)]",
          description: "text-base text-[var(--alert-description-color)]",
          icon: :lg
        }
      }.freeze

      def initialize(
        title: nil,
        description: nil,
        style: :info,
        dismissible: false,
        icon: true,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @style = style.to_sym
        @dismissible = dismissible
        @show_icon = icon
        @size = size.to_sym

        validate_style!
        validate_size!
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

      def size_config
        SIZES.fetch(@size)
      end

      def render_content_area
        content_tag(:div, class: "flex items-center #{size_config.fetch(:gap)}") do
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
          render(FlatPack::Shared::IconComponent.new(name: icon_name, size: size_config.fetch(:icon)))
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

        content_tag(:h3, @title, class: size_config.fetch(:title))
      end

      def render_description
        return unless @description

        content_tag(:p, @description, class: size_config.fetch(:description))
      end

      def render_dismiss_button
        return unless @dismissible

        content_tag(:span, class: "fp-alert__dismiss") do
          render FlatPack::Button::Component.new(
            text: fp_t("alert.dismiss"),
            icon: "x-mark",
            icon_variant: :mini,
            icon_only: true,
            style: :ghost,
            size: :sm,
            type: "button",
            class: "ml-auto shrink-0 rounded-[var(--alert-dismiss-button-radius)]",
            aria: {label: fp_t("alert.dismiss")},
            data: {action: "flat-pack--alert#dismiss"}
          )
        end
      end

      def alert_attributes
        attrs = {
          class: alert_classes,
          role: "alert"
        }
        attrs[:data] = {controller: "flat-pack--alert", flat_pack__alert_target: "alert"} if @dismissible
        merge_attributes(**attrs)
      end

      def alert_classes
        classes(
          "relative flex items-center",
          size_config.fetch(:gap),
          "rounded-[var(--alert-border-radius)]",
          size_config.fetch(:padding),
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

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
