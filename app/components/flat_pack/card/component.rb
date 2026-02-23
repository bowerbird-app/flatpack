# frozen_string_literal: true

module FlatPack
  module Card
    class Component < FlatPack::BaseComponent
      renders_one :header_slot, FlatPack::Card::Header::Component
      renders_one :body_slot, FlatPack::Card::Body::Component
      renders_one :footer_slot, FlatPack::Card::Footer::Component
      renders_one :media_slot, FlatPack::Card::Media::Component

      # Custom setter methods that provide the cleaner syntax
      def header(**args, &block)
        return header_slot unless block

        with_header_slot(**args, &block)
      end

      def body(**args, &block)
        return body_slot unless block

        with_body_slot(**args, &block)
      end

      def footer(**args, &block)
        return footer_slot unless block

        with_footer_slot(**args, &block)
      end

      def media(**args, &block)
        return media_slot unless block

        with_media_slot(**default_media_arguments.merge(args), &block)
      end

      # Custom predicate methods
      def header?
        header_slot?
      end

      def body?
        body_slot?
      end

      def footer?
        footer_slot?
      end

      def media?
        media_slot?
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--card-background-color)]" "border" "border-[var(--card-border-color)]" "shadow-md" "dark:shadow-lg" "border-2" "bg-[var(--card-background-muted-color)]"
      STYLES = {
        default: "bg-[var(--card-background-color)] border border-[var(--card-border-color)]",
        elevated: "bg-[var(--card-background-color)] border border-[var(--card-border-color)] shadow-md dark:shadow-lg",
        outlined: "bg-[var(--card-background-color)] border-2 border-[var(--card-border-color)]",
        flat: "bg-[var(--card-background-muted-color)]",
        interactive: "bg-[var(--card-background-color)] border border-[var(--card-border-color)]",
        list: "bg-[var(--card-background-color)] border border-[var(--card-border-color)]"
      }.freeze

      HOVERS = {
        none: "",
        subtle: "fp-card-hover-subtle",
        strong: "fp-card-hover-strong"
      }.freeze

      STYLE_DEFAULT_HOVERS = {
        default: :none,
        elevated: :none,
        outlined: :none,
        flat: :none,
        interactive: :strong,
        list: :subtle
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "p-[var(--card-padding-sm)]" "p-[var(--card-padding-md)]" "p-[var(--card-padding-lg)]"
      PADDINGS = {
        none: "",
        sm: "p-[var(--card-padding-sm)]",
        md: "p-[var(--card-padding-md)]",
        lg: "p-[var(--card-padding-lg)]"
      }.freeze

      def initialize(
        style: :default,
        hover: nil,
        clickable: false,
        href: nil,
        padding: :md,
        **system_arguments
      )
        super(**system_arguments)
        @style = style.to_sym
        @hover = hover&.to_sym
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
        validate_hover!
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
          "rounded-lg",
          "overflow-hidden",
          "h-full",
          "flex",
          "flex-col",
          style_classes,
          hover_classes,
          container_padding_classes
        )
      end

      def container_padding_classes
        return nil if slot_based_content?

        padding_classes
      end

      def slot_based_content?
        media? || header? || body? || footer?
      end

      def default_media_arguments
        {padding: @padding}
      end

      def style_classes
        STYLES.fetch(@style)
      end

      def padding_classes
        PADDINGS.fetch(@padding)
      end

      def hover_classes
        HOVERS.fetch(resolved_hover)
      end

      def resolved_hover
        @hover || STYLE_DEFAULT_HOVERS.fetch(@style)
      end

      def validate_style!
        return if STYLES.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
      end

      def validate_padding!
        return if PADDINGS.key?(@padding)
        raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
      end

      def validate_hover!
        return if @hover.nil? || HOVERS.key?(@hover)
        raise ArgumentError, "Invalid hover: #{@hover}. Must be one of: #{HOVERS.keys.join(", ")}"
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
