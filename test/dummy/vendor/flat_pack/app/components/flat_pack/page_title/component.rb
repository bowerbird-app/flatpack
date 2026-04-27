# frozen_string_literal: true

module FlatPack
  module PageTitle
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[h1 h2 h3 h4 h5 h6].freeze

      renders_one :actions

      alias_method :actions_slot, :actions

      undef_method :with_actions, :with_actions_content

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

      def actions(*args, **kwargs, &block)
        return actions_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:actions, nil, *args, **kwargs, &block)
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
            render_subtitle,
            render_actions
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

      def render_actions
        return nil unless actions?

        content_tag(:div, actions, class: "page-title-actions mt-4 flex flex-wrap items-center gap-3")
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
