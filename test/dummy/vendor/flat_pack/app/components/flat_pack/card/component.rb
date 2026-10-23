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
      # "border" "border-[var(--card-border-color)]" "border-2" "border-0" "border-solid"
      # "border-[length:var(--card-border-width)]"
      # "shadow-[var(--shadow-sm)]" "shadow-[var(--shadow-md)]" "shadow-none" "shadow-[var(--card-shadow)]"
      SHADOWS = {
        none: "shadow-none",
        sm: "shadow-[var(--shadow-sm)]",
        md: "shadow-[var(--shadow-md)]"
      }.freeze

      BORDERS = {
        none: "border-0",
        default: "border border-[var(--card-border-color)]",
        strong: "border-2 border-[var(--card-border-color)]"
      }.freeze

      THEME_SHADOW = "shadow-[var(--card-shadow)]"
      THEME_BORDER = "border-solid border-[length:var(--card-border-width)] border-[var(--card-border-color)]"

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

      INSETS = %i[sm md lg].freeze

      RADII = {
        default: nil,
        none: "0px",
        sm: "var(--radius-sm)",
        md: "var(--radius-md)",
        lg: "var(--radius-lg)",
        xl: "var(--radius-xl)",
        xxl: "var(--radius-xxl)",
        xxxl: "var(--radius-xxxl)"
      }.freeze

      def initialize(
        background: :default,
        shadow: nil,
        border: nil,
        hover: :none,
        clickable: false,
        href: nil,
        padding: :md,
        inset: nil,
        radius: :default,
        **system_arguments
      )
        reject_removed_theme!(system_arguments)
        super(**system_arguments)
        @background = background.to_sym
        @shadow = shadow&.to_sym
        @border = border&.to_sym
        @hover = (hover || :none).to_sym
        @clickable = clickable
        @padding = padding.to_sym
        @inset = inset&.to_sym
        @radius = radius.to_sym

        # Sanitize URL for security and validate
        if href
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        else
          @href = nil
        end

        validate_background!
        validate_shadow!
        validate_border!
        validate_hover!
        validate_padding!
        validate_inset!
        validate_radius!
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
          data: card_data
        )

        attributes.delete("style")
        style = joined_style
        attributes[:style] = style if style.present?
        attributes
      end

      def card_classes
        classes(
          "fp-card",
          "rounded-[var(--card-radius)]",
          overflow_class,
          "flex",
          "flex-col",
          "text-[var(--surface-content-color)]",
          background_classes,
          shadow_classes,
          border_classes,
          hover_classes,
          container_padding_classes
        )
      end

      def caller_style
        html_attributes[:style] || html_attributes["style"]
      end

      def joined_style
        declaration = radius_declaration
        return caller_style if declaration.nil?
        return declaration if caller_style.blank?

        "#{caller_style.to_s.sub(/;\s*\z/, "")}; #{declaration}"
      end

      def radius_declaration
        length = RADII.fetch(@radius)
        return if length.nil?

        "--card-radius: #{length}"
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

      def background_classes
        Background.classes_for(@background)
      end

      def shadow_classes
        return THEME_SHADOW if @shadow.nil?

        SHADOWS.fetch(@shadow)
      end

      def border_classes
        return THEME_BORDER if @border.nil?

        BORDERS.fetch(@border)
      end

      def padding_classes
        PADDINGS.fetch(@padding)
      end

      def hover_classes
        HOVERS.fetch(@hover)
      end

      def validate_background!
        return if Background::CLASSES.key?(@background)

        raise ArgumentError, "Invalid background: #{@background}. Must be one of: #{Background::NAMES.join(", ")}"
      end

      def validate_shadow!
        return if @shadow.nil? || SHADOWS.key?(@shadow)

        raise ArgumentError, "Invalid shadow: #{@shadow}. Must be one of: #{SHADOWS.keys.join(", ")}"
      end

      def validate_border!
        return if @border.nil? || BORDERS.key?(@border)

        raise ArgumentError, "Invalid border: #{@border}. Must be one of: #{BORDERS.keys.join(", ")}"
      end

      def card_data
        data = {background: @background.to_s, fp_card_padding: @padding.to_s}
        data[:fp_card_inset] = @inset.to_s if @inset
        data
      end

      def validate_padding!
        return if PADDINGS.key?(@padding)
        raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
      end

      def validate_inset!
        return if @inset.nil? || INSETS.include?(@inset)

        raise ArgumentError, "Invalid inset: #{@inset}. Must be one of: #{INSETS.join(", ")}"
      end

      def validate_radius!
        return if RADII.key?(@radius)

        raise ArgumentError, "Invalid radius: #{@radius}. Must be one of: #{RADII.keys.join(", ")}"
      end

      def validate_hover!
        return if HOVERS.key?(@hover)

        raise ArgumentError, "Invalid hover: #{@hover}. Must be one of: #{HOVERS.keys.join(", ")}"
      end

      def reject_removed_theme!(system_arguments)
        %i[style theme tone].each do |removed|
          next unless system_arguments.key?(removed)

          raise ArgumentError, "unknown keyword: :#{removed}"
        end
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
