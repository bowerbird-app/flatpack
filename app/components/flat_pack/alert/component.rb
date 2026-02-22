# frozen_string_literal: true

module FlatPack
  module Alert
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-white" "text-black" "border" "border-black/20" "bg-success" "text-success-text" "bg-warning" "text-warning-text" "bg-destructive" "text-destructive-text"
      VARIANTS = {
        info: {
          border: "border border-black/20",
          bg: "bg-white",
          text: "text-black",
          icon: "info"
        },
        success: {
          border: nil,
          bg: "bg-success",
          text: "text-success-text",
          icon: "check-circle"
        },
        warning: {
          border: nil,
          bg: "bg-warning",
          text: "text-warning-text",
          icon: "alert-triangle"
        },
        danger: {
          border: nil,
          bg: "bg-destructive",
          text: "text-destructive-text",
          icon: "alert-circle"
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

        # Simple icon representation using SVG
        icon_name = style_config[:icon]
        content_tag(:div, class: "flex-shrink-0") do
          render_icon_svg(icon_name)
        end
      end

      def render_icon_svg(icon_name)
        case icon_name
        when "info"
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z", "clip-rule": "evenodd")
          end
        when "check-circle"
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z", "clip-rule": "evenodd")
          end
        when "alert-triangle"
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z", "clip-rule": "evenodd")
          end
        when "alert-circle"
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z", "clip-rule": "evenodd")
          end
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

        content_tag(:h3, @title, class: "font-semibold")
      end

      def render_description
        return unless @description

        content_tag(:p, @description, class: "text-sm")
      end

      def render_dismiss_button
        return unless @dismissible

        content_tag(:button,
          type: "button",
          class: "ml-auto flex-shrink-0 inline-flex items-center justify-center rounded-md p-1.5 hover:bg-black/5 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-ring",
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
          "rounded-md",
          "p-4",
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
