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

        content_tag(:figcaption, "— #{@cite}", class: "mt-2 text-sm text-[var(--surface-muted-content-color)]")
      end

      def quote_content
        @quote_content ||= @text.presence || content
      end

      def quote_classes
        classes(
          "border-l-4",
          "border-[var(--surface-border-color)]",
          "pl-4",
          "leading-relaxed",
          "text-[var(--surface-content-color)]",
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
end# frozen_string_literal: true

module FlatPack
  module Quote
    class Component < FlatPack::BaseComponent
      def initialize(
        text: nil,
        cite: nil,
        variant: :default,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @cite = cite
        @variant = variant.to_sym

        validate_variant!
      end

      def call
        validate_content!

        content_tag(:figure, **figure_attributes) do
          safe_join([
            content_tag(:blockquote, quote_text, class: blockquote_classes),
            render_citation
          ].compact)
        end
      end

      private

      def figure_attributes
        merge_attributes(class: "fp-quote space-y-2")
      end

      def blockquote_classes
        [
          "border-l-4",
          "border-[var(--surface-border-color)]",
          "pl-4",
          "text-[var(--surface-content-color)]",
          variant_classes
        ].join(" ")
      end

      def variant_classes
        case @variant
        when :default
          "italic"
        when :emphasis
          "text-lg leading-relaxed"
        end
      end

      def quote_text
        content.presence || @text
      end

      def render_citation
        return unless @cite.present?

        content_tag(:figcaption, "— #{@cite}", class: "text-sm text-[var(--surface-muted-content-color)]")
      end

      def validate_variant!
        return if %i[default emphasis].include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: default, emphasis"
      end

      def validate_content!
        return if quote_text.present?

        raise ArgumentError, "Quote text is required"
      end
    end
  end
end