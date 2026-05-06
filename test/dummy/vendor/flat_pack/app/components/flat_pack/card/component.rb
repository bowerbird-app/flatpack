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

        set_slot(:header_slot, nil, **args, &block)
      end

      def body(**args, &block)
        return body_slot if args.empty? && !block

        set_slot(:body_slot, nil, **args, &block)
      end

      def footer(**args, &block)
        return footer_slot if args.empty? && !block

        set_slot(:footer_slot, nil, **args, &block)
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

      THEME_VARIABLES = {
        background: "--card-background-color",
        background_muted: "--card-background-muted-color",
        text: "--surface-content-color",
        muted_text: "--surface-muted-content-color",
        primary: "--color-primary",
        primary_hover: "--color-primary-hover",
        primary_text: "--color-primary-text"
      }.freeze

      BUTTON_THEME_VARIABLES = {
        primary: ["--button-primary-background-color", "--button-primary-border-color"],
        primary_hover: ["--button-primary-hover-background-color"],
        primary_text: ["--button-primary-text-color"],
        default_button: ["--button-default-background-color"],
        default_button_hover: ["--button-default-hover-background-color"],
        default_button_text: ["--button-default-text-color"],
        default_button_border: ["--button-default-border-color"],
        secondary_button: ["--button-secondary-background-color"],
        secondary_button_hover: ["--button-secondary-hover-background-color"],
        secondary_button_text: ["--button-secondary-text-color"],
        secondary_button_border: ["--button-secondary-border-color"]
      }.freeze

      def initialize(
        style: :default,
        hover: nil,
        clickable: false,
        href: nil,
        padding: :md,
        theme: nil,
        **system_arguments
      )
        super(**system_arguments)
        @style = style.to_sym
        @hover = hover&.to_sym
        @clickable = clickable
        @padding = padding.to_sym
        @theme = normalize_theme(theme)

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
        validate_theme!
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
          class: card_classes
        )

        attributes.delete("style")
        attributes[:style] = combined_style if combined_style.present?
        attributes
      end

      def card_classes
        classes(
          "rounded-lg",
          overflow_class,
          "h-full",
          "flex",
          "flex-col",
          "text-[var(--surface-content-color)]",
          style_classes,
          hover_classes,
          container_padding_classes
        )
      end

      def combined_style
        existing_style = html_attributes[:style] || html_attributes["style"]
        [existing_style, theme_style].compact.join("; ").presence
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

      def theme_style
        return if @theme.empty?

        direct_variables = @theme.filter_map do |key, value|
          next unless THEME_VARIABLES.key?(key)

          "#{THEME_VARIABLES.fetch(key)}: #{value}"
        end

        button_variables = @theme.flat_map do |key, value|
          Array(BUTTON_THEME_VARIABLES[key]).map do |variable|
            "#{variable}: #{value}"
          end
        end

        [*direct_variables, *button_variables].join("; ")
      end

      def normalize_theme(theme)
        return {} if theme.nil?

        theme.to_h.each_with_object({}) do |(key, value), normalized|
          normalized[key.to_sym] = value
        end
      rescue NoMethodError
        raise ArgumentError, "Theme must be a hash of color overrides."
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

      def validate_theme!
        valid_theme_keys = THEME_VARIABLES.keys | BUTTON_THEME_VARIABLES.keys
        invalid_keys = @theme.keys - valid_theme_keys
        return if invalid_keys.empty? && valid_theme_colors?

        unless invalid_keys.empty?
          raise ArgumentError, "Invalid theme keys: #{invalid_keys.join(", ")}. Must be one of: #{valid_theme_keys.join(", ")}"
        end

        raise ArgumentError, "Theme values must be safe CSS color values."
      end

      def valid_theme_colors?
        @theme.all? do |_key, value|
          FlatPack::AttributeSanitizer.sanitize_css_color(value).present?
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
