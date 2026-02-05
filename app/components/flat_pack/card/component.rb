# frozen_string_literal: true

module FlatPack
  module Card
    class Component < FlatPack::BaseComponent
      renders_one :header, HeaderComponent
      renders_one :body, BodyComponent
      renders_one :footer, FooterComponent
      renders_one :media, MediaComponent

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--color-background)]" "border" "border-[var(--color-border)]" "shadow-md" "border-2" "bg-[var(--color-muted)]" "hover:shadow-md" "hover:border-[var(--color-primary)]" "transition-all" "cursor-pointer"
      STYLES = {
        default: "bg-[var(--color-background)] border border-[var(--color-border)]",
        elevated: "bg-[var(--color-background)] shadow-md",
        outlined: "bg-[var(--color-background)] border-2 border-[var(--color-border)]",
        flat: "bg-[var(--color-muted)]",
        interactive: "bg-[var(--color-background)] border border-[var(--color-border)] hover:shadow-md hover:border-[var(--color-primary)] transition-all cursor-pointer"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "p-4" "p-6" "p-8"
      PADDINGS = {
        none: "",
        sm: "p-4",
        md: "p-6",
        lg: "p-8"
      }.freeze

      def initialize(
        style: :default,
        clickable: false,
        href: nil,
        padding: :md,
        **system_arguments
      )
        super(**system_arguments)
        @style = style.to_sym
        @clickable = clickable
        @padding = padding.to_sym

        # Sanitize URL for security and validate
        if href
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        else
          @href = nil
        end

        validate_style!
        validate_padding!
      end

      def call
        if @clickable && @href
          link_to @href, **container_attributes do
            render_card_content
          end
        else
          content_tag(:div, **container_attributes) do
            render_card_content
          end
        end
      end

      private

      def render_card_content
        safe_join([
          (media if media?),
          (header if header?),
          (body if body?),
          (footer if footer?),
          (content if !media? && !header? && !body? && !footer?)
        ].compact)
      end

      def container_attributes
        merge_attributes(
          class: card_classes
        )
      end

      def card_classes
        classes(
          "rounded-[var(--radius-lg)]",
          "overflow-hidden",
          style_classes,
          padding_classes
        )
      end

      def style_classes
        STYLES.fetch(@style)
      end

      def padding_classes
        PADDINGS.fetch(@padding)
      end

      def validate_style!
        return if STYLES.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
      end

      def validate_padding!
        return if PADDINGS.key?(@padding)
        raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
      end

      def validate_href!(original_href)
        # Check if the original href was provided but sanitization failed
        return if @href.present?

        # Use a generic error message to avoid leaking sensitive information in logs
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
