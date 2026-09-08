# frozen_string_literal: true

module FlatPack
  module SkipLink
    class Component < FlatPack::BaseComponent
      def initialize(href: "#main", text: "Skip to content", **system_arguments)
        super(**system_arguments)
        @href = FlatPack::AttributeSanitizer.sanitize_url(href)
        @text = text.to_s
        validate_href!
        validate_text!
      end

      def call
        content_tag(:a, @text, **link_attributes)
      end

      private

      def link_attributes
        merge_attributes(
          href: @href,
          class: link_classes
        )
      end

      def link_classes
        classes(
          "fp-skip-link",
          "fixed left-4 z-[100] rounded-[var(--radius-md)]",
          "bg-[var(--skip-link-background-color)] text-[var(--skip-link-text-color)]",
          "px-4 py-2 text-sm font-medium shadow-md",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring"
        )
      end

      def validate_href!
        return if @href.present? && @href.start_with?("#")

        raise ArgumentError, "href must be an in-page fragment such as #main"
      end

      def validate_text!
        return if @text.present?

        raise ArgumentError, "text is required"
      end
    end
  end
end
