# frozen_string_literal: true

module FlatPack
  module Card
    class Component < FlatPack::BaseComponent
      renders_one :header_slot, FlatPack::Card::Header::Component
      renders_one :body_slot, FlatPack::Card::Body::Component
      renders_one :footer_slot, FlatPack::Card::Footer::Component
      renders_one :media_slot, FlatPack::Card::Media::Component

      undef_method :with_header_slot, :with_header_slot_content
      undef_method :with_body_slot, :with_body_slot_content
      undef_method :with_footer_slot, :with_footer_slot_content
      undef_method :with_media_slot, :with_media_slot_content

      def header(**args, &block)
        return header_slot if args.empty? && !block

        set_slot(:header_slot, nil, **header_slot_arguments(args), &block)
      end

      def body(**args, &block)
        return body_slot if args.empty? && !block

        set_slot(:body_slot, nil, **args, &block)
      end

      def footer(**args, &block)
        return footer_slot if args.empty? && !block

        set_slot(:footer_slot, nil, **footer_slot_arguments(args), &block)
      end

      def media(**args, &block)
        return media_slot if args.empty? && !block

        set_slot(:media_slot, nil, **default_media_arguments.merge(args), &block)
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
      # "border" "border-[var(--card-border-color)]" "border-2" "shadow-[var(--shadow-sm)]" "shadow-[var(--shadow-md)]"
      SHADOWS = {
        none: "",
        sm: "shadow-[var(--shadow-sm)]",
        md: "shadow-[var(--shadow-md)]"
      }.freeze

      BORDERS = {
        none: "",
        default: "border border-[var(--card-border-color)]",
        strong: "border-2 border-[var(--card-border-color)]"
      }.freeze

      HOVERS = {
        none: "",
        subtle: "fp-card-hover-subtle",
        strong: "fp-card-hover-strong"
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
        shadow: :none,
        border: :default,
        hover: :none,
        clickable: false,
        href: nil,
        padding: :md,
        **system_arguments
      )
        reject_removed_theme!(system_arguments)
        super(**system_arguments)
        @style = style.to_sym
        @shadow = shadow.to_sym
        @border = border.to_sym
        @hover = (hover || :none).to_sym
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
        validate_shadow!
        validate_border!
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
        attributes = merge_attributes(
          class: card_classes,
          data: {style: @style.to_s, fp_card_padding: @padding.to_s}
        )

        attributes.delete("style")
        attributes[:style] = caller_style if caller_style.present?
        attributes
      end

      def card_classes
        classes(
          "fp-card",
          "rounded-[var(--card-radius)]",
          overflow_class,
          "h-full",
          "flex",
          "flex-col",
          "text-[var(--surface-content-color)]",
          style_classes,
          shadow_classes,
          border_classes,
          hover_classes,
          container_padding_classes
        )
      end

      def caller_style
        html_attributes[:style] || html_attributes["style"]
      end

      def overflow_class
        media? ? "overflow-hidden" : "overflow-visible"
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

      def header_slot_arguments(args)
        {padding: @padding}.merge(args)
      end

      def footer_slot_arguments(args)
        {padding: @padding}.merge(args)
      end

      def style_classes
        Style.classes_for(@style)
      end

      def shadow_classes
        SHADOWS.fetch(@shadow)
      end

      def border_classes
        BORDERS.fetch(@border)
      end

      def padding_classes
        PADDINGS.fetch(@padding)
      end

      def hover_classes
        HOVERS.fetch(@hover)
      end

      def validate_style!
        return if Style::CLASSES.key?(@style)

        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{Style::NAMES.join(", ")}"
      end

      def validate_shadow!
        return if SHADOWS.key?(@shadow)

        raise ArgumentError, "Invalid shadow: #{@shadow}. Must be one of: #{SHADOWS.keys.join(", ")}"
      end

      def validate_border!
        return if BORDERS.key?(@border)

        raise ArgumentError, "Invalid border: #{@border}. Must be one of: #{BORDERS.keys.join(", ")}"
      end

      def validate_padding!
        return if PADDINGS.key?(@padding)
        raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
      end

      def validate_hover!
        return if HOVERS.key?(@hover)

        raise ArgumentError, "Invalid hover: #{@hover}. Must be one of: #{HOVERS.keys.join(", ")}"
      end

      def reject_removed_theme!(system_arguments)
        if system_arguments.key?(:theme)
          raise ArgumentError, "unknown keyword: :theme"
        end
        return unless system_arguments.key?(:tone)

        raise ArgumentError, "unknown keyword: :tone"
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
