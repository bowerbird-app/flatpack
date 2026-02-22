# frozen_string_literal: true

module FlatPack
  module EmptyState
    class Component < FlatPack::BaseComponent
      renders_one :actions
      renders_one :graphic

      # Icon constants with hardcoded SVG for performance
      # SECURITY: These SVG strings are developer-controlled constants, not user input.
      # They are marked html_safe because they contain intentional HTML markup that
      # should be rendered as-is, not escaped.
      ICONS = {
        inbox: <<~SVG.html_safe,
          <svg class="w-12 h-12 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
        SVG
        search: <<~SVG.html_safe
          <svg class="w-12 h-12 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        SVG
      }.freeze

      def initialize(
        title:,
        description: nil,
        icon: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @icon = normalize_icon(icon)

        validate_title!
        validate_icon!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_graphic,
            render_title,
            render_description,
            render_actions
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
          "flex",
          "flex-col",
          "items-center",
          "justify-center",
          "text-center",
          "py-12",
          "px-4"
        )
      end

      def render_graphic
        return graphic if graphic?
        return nil if @icon.nil?

        content_tag(:div, graphic_content, class: "mb-4")
      end

      def graphic_content
        return ICONS.fetch(@icon) if ICONS.key?(@icon)

        render FlatPack::Shared::IconComponent.new(
          name: @icon,
          size: :xl,
          class: "text-muted-foreground"
        )
      end

      def render_title
        content_tag(:h3, @title, class: "text-lg font-semibold text-foreground mb-2")
      end

      def render_description
        return nil unless @description

        content_tag(:p, @description, class: "text-sm text-muted-foreground max-w-md mb-6")
      end

      def render_actions
        return nil unless actions?

        content_tag(:div, actions, class: "flex gap-3 flex-wrap justify-center")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_icon!
        return if @icon.nil?
        return if @icon.is_a?(Symbol)
        raise ArgumentError, "Invalid icon: #{@icon.inspect}. Must be a symbol or string."
      end

      def normalize_icon(icon)
        return nil if icon == false
        return icon.to_sym if icon.respond_to?(:to_sym)

        icon
      end
    end
  end
end
