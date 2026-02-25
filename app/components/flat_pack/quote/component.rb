# frozen_string_literal: true

module FlatPack
  module Quote
    class Component < FlatPack::BaseComponent
      SIZES = {
        sm: "text-base",
        md: "text-lg",
        lg: "text-xl"
      }.freeze

      def initialize(
        text: nil,
        cite: nil,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @cite = cite
        @size = size.to_sym

        validate_size!
      end

      def call
        raise ArgumentError, "text is required" if quote_content.blank?

        content_tag(:figure, **container_attributes) do
          safe_join([
            render_quote,
            render_cite
          ].compact)
        end
      end

      private

      def container_attributes
        merge_attributes(class: "fp-quote")
      end

      def render_quote
        content_tag(:blockquote, quote_content, class: quote_classes)
      end

      def render_cite
        return nil if @cite.blank?

        content_tag(:figcaption, "— #{@cite}", class: "mt-[var(--quote-cite-margin-top)] text-sm text-[var(--quote-cite-color)]")
      end

      def quote_content
        @quote_content ||= @text.presence || content
      end

      def quote_classes
        classes(
          "border-l-[var(--quote-border-width)]",
          "border-[var(--quote-border-color)]",
          "pl-[var(--quote-padding-left)]",
          "leading-relaxed",
          "text-[var(--quote-text-color)]",
          "italic",
          size_classes
        )
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(', ')}"
      end
    end
  end
end