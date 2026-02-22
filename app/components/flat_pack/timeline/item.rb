# frozen_string_literal: true

module FlatPack
  module Timeline
    class Item < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-primary" "bg-success-bg" "bg-warning-bg" "bg-destructive-bg"
      VARIANTS = {
        default: "bg-primary",
        success: "bg-success-bg",
        warning: "bg-warning-bg",
        danger: "bg-destructive-bg"
      }.freeze

      def initialize(
        title:,
        timestamp: nil,
        variant: :default,
        status: nil,
        description: nil,
        icon: nil,
        last: false,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @timestamp = timestamp
        @variant = (status || variant).to_sym
        @description = description
        @icon = icon
        @last = last

        validate_title!
        validate_variant!
      end

      def call
        content_tag(:div, **item_attributes) do
          safe_join([
            render_marker,
            render_content_area
          ])
        end
      end

      private

      def render_marker
        content_tag(:div, class: "flex flex-col items-center") do
          safe_join([
            render_icon_circle,
            render_line
          ].compact)
        end
      end

      def render_icon_circle
        content_tag(:div, **icon_circle_attributes) do
          render_icon_content
        end
      end

      def render_icon_content
        return @icon.html_safe if @icon.is_a?(String) && @icon.start_with?("<svg")

        content_tag(:span, nil, class: "w-2 h-2 rounded-full bg-white")
      end

      def render_line
        return if @last

        content_tag(:div, nil, class: "w-0.5 h-full min-h-[2rem] bg-[var(--surface-border-color)]")
      end

      def render_content_area
        content_tag(:div, class: "flex-1 pb-8 pl-4") do
          safe_join([
            render_header,
            render_content
          ])
        end
      end

      def render_header
        content_tag(:div, class: "flex items-baseline justify-between mb-1") do
          safe_join([
            content_tag(:h3, @title, class: "text-base font-semibold text-[var(--surface-content-color)]"),
            render_timestamp
          ].compact)
        end
      end

      def render_timestamp
        return unless @timestamp

        content_tag(:time, @timestamp, class: "text-sm text-[var(--surface-muted-content-color)]")
      end

      def render_content
        return content_tag(:div, @description, class: "text-sm text-[var(--surface-content-color)] mt-2") if @description.present?
        return unless content?

        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from components captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(:div, content.html_safe, class: "text-sm text-[var(--surface-content-color)] mt-2")
      end

      def item_attributes
        merge_attributes(
          class: "flex",
          role: "listitem"
        )
      end

      def icon_circle_attributes
        {
          class: icon_circle_classes,
          aria: {hidden: true}
        }
      end

      def icon_circle_classes
        "flex items-center justify-center w-10 h-10 rounded-full #{VARIANTS.fetch(@variant)}"
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)
        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end
    end
  end
end
