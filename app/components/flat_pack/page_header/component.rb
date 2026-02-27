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
        content_tag(:div, **container_attributes) do
          safe_join([
            content_tag(:h1, @title, class: "text-4xl font-bold text-[var(--surface-content-color)] leading-tight"),
            (@subtitle.present? ? content_tag(:p, @subtitle, class: "mt-2 text-lg text-[var(--surface-muted-content-color)]") : nil)
          ].compact)
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: classes(
            "border-b border-[var(--surface-border-color)]",
            "pb-8 mb-6"
          )
        )
      end

      def validate_title!
        return if @title.present?

        raise ArgumentError, "title is required"
      end
    end
  end
end
