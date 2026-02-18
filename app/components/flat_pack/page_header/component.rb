# frozen_string_literal: true

module FlatPack
  module PageHeader
    class Component < FlatPack::BaseComponent
      renders_one :actions
      renders_one :meta
      renders_one :breadcrumb

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
        content_tag(:div, **container_attributes) do
          safe_join([
            render_breadcrumb,
            render_header_content
          ].compact)
        end
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

      def render_breadcrumb
        return nil unless breadcrumb?

        content_tag(:div, breadcrumb, class: "mb-4")
      end

      def render_header_content
        content_tag(:div, class: "flex items-start justify-between gap-4") do
          safe_join([
            render_title_section,
            render_actions_section
          ].compact)
        end
      end

      def render_title_section
        content_tag(:div, class: "flex-1 min-w-0") do
          safe_join([
            render_title,
            render_subtitle,
            render_meta
          ].compact)
        end
      end

      def render_title
        content_tag(:h1, @title, class: "text-2xl font-bold text-[var(--color-text)] leading-tight")
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: "mt-2 text-sm text-[var(--color-text-muted)]")
      end

      def render_meta
        return nil unless meta?

        content_tag(:div, meta, class: "mt-3")
      end

      def render_actions_section
        return nil unless actions?

        content_tag(:div, actions, class: "flex gap-3 flex-shrink-0")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end
    end
  end
end
