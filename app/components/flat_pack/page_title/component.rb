# frozen_string_literal: true

module FlatPack
  module PageTitle
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[h1 h2 h3 h4 h5 h6].freeze

      def initialize(
        title:,
        subtitle: nil,
        variant: :h1,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle
        @variant = variant.to_sym

        validate_title!
        validate_variant!
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
        classes("pb-8", "mb-6")
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
        content_tag(
          @variant,
          @title,
          class: "font-bold text-[var(--surface-content-color)] leading-tight",
          style: "font-size: #{heading_size_token};"
        )
      end

      def heading_size_token
        "var(--page-title-#{@variant}-size)"
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: "mt-2 text-lg text-[var(--surface-muted-content-color)]")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
      end
    end
  end
end
