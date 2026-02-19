# frozen_string_literal: true

module FlatPack
  module PageHeader
    class Component < FlatPack::BaseComponent
      def initialize(
        title:,
        subtitle: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle

        validate_title!
      end

      def call
        content_tag(:div, **container_attributes) { render_header_content }
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes(
          "pb-5",
          "border-b",
          "border-[var(--color-border)]",
          "mb-6"
        )
      end

      def render_header_content
        content_tag(:div, class: "flex items-start gap-4") do
          render_title_section
        end
      end

      def render_title_section
        content_tag(:div, class: "flex-1 min-w-0") do
          safe_join([
            render_title,
            render_subtitle
          ].compact)
        end
      end

      def render_title
        content_tag(:h1, @title, class: "text-4xl font-bold text-[var(--color-text)] leading-tight")
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: "mt-2 text-lg text-[var(--color-text-muted)]")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end
    end
  end
end
