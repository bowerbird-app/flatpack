# frozen_string_literal: true

module FlatPack
  module Button
    class Component < FlatPack::BaseComponent
      SCHEMES = StyleRegistry::BUILT_IN.transform_values { |config| config.fetch(:press) }.freeze

      SIZES = {
        sm: "px-[var(--button-padding-x-sm)] py-[var(--button-padding-y-sm)] text-xs",
        md: "px-[var(--button-padding-x-md)] py-[var(--button-padding-y-md)] text-sm",
        lg: "px-[var(--button-padding-x-lg)] py-[var(--button-padding-y-lg)] text-base"
      }.freeze

      ICON_ONLY_SIZES = {
        sm: "p-[var(--button-icon-only-padding-sm)]",
        md: "p-[var(--button-icon-only-padding-md)]",
        lg: "p-[var(--button-icon-only-padding-lg)]"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "inline-flex" "gap-2" "items-center" "items-start" "justify-center" "justify-start"
      # "min-w-0" "max-w-full" "flex-1" "text-center" "text-start" "truncate" "line-clamp-2"
      # "shrink-0" "self-start"
      ALIGNS = {
        center: "justify-center",
        start: "justify-start"
      }.freeze

      LABEL_ALIGNS = {
        center: "min-w-0 max-w-full text-center",
        start: "min-w-0 flex-1 text-start"
      }.freeze

      LINES = {
        1 => "truncate",
        2 => "line-clamp-2"
      }.freeze

      TRAILING_CLASSES = {
        1 => "shrink-0",
        2 => "shrink-0 self-start"
      }.freeze

      renders_one :trailing

      def initialize(
        text: nil,
        style: :default,
        size: :md,
        href: nil,
        method: nil,
        target: nil,
        icon: nil,
        icon_only: false,
        loading: false,
        type: "button",
        align: :center,
        lines: 1,
        current: false,
        title: nil,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @style = style.to_sym
        @size = size.to_sym
        @method = method
        @target = target
        @icon = icon
        @icon_only = icon_only
        @loading = loading
        @type = type
        @align = align.to_sym
        @lines = lines
        @current = current
        @title = title

        # Sanitize URL for security and validate
        if href
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        else
          @href = nil
        end

        validate_style!
        validate_size!
        validate_content!
        validate_align!
        validate_lines!
        validate_current!
        validate_title!
      end

      def call
        validate_trailing!

        if @href
          render_link
        else
          render_button
        end
      end

      private

      def render_link
        link_to @href, **link_attributes do
          button_content
        end
      end

      def render_button
        button_tag(**button_attributes) do
          button_content
        end
      end

      def button_content
        content = []

        if @loading
          content << render(FlatPack::Spinner::Component.new(size: @size, label: nil))
          content << content_tag(:span, fp_t("button.loading"), class: label_classes) unless @icon_only
        else
          content << render_icon if @icon
          content << content_tag(:span, @text, class: label_classes) if @text && !@icon_only
          content << render_trailing if show_trailing?
        end

        safe_join(content)
      end

      def show_trailing?
        !@loading && !@icon_only && trailing?
      end

      def render_trailing
        content_tag(:span, trailing, class: TRAILING_CLASSES.fetch(@lines))
      end

      def render_icon
        render FlatPack::Shared::IconComponent.new(name: @icon, size: @size)
      end

      def icon_size
        case @size
        when :sm then :sm
        when :md then :md
        when :lg then :lg
        end
      end

      def conditional_size_classes
        @icon_only ? nil : size_classes
      end

      def button_attributes
        attrs = {
          type: @type,
          class: button_classes,
          data: style_data
        }
        attrs[:disabled] = true if @loading
        apply_shared_control_attributes!(attrs)
        merge_attributes(**attrs)
      end

      def link_attributes
        attrs = {
          class: button_classes,
          method: @method,
          target: @target,
          data: style_data
        }
        attrs[:rel] = "noopener noreferrer" if @target == "_blank"
        apply_shared_control_attributes!(attrs)
        if @current
          attrs[:aria] ||= {}
          attrs[:aria][:current] = "page"
        end
        merge_attributes(**attrs).compact
      end

      def apply_shared_control_attributes!(attrs)
        attrs[:title] = @title if @title.present?
        aria = {}
        aria[:label] = derived_icon_only_label if derived_icon_only_label.present?
        aria[:busy] = "true" if @loading
        attrs[:aria] = aria if aria.any?
      end

      def button_classes
        classes(
          "inline-flex gap-2",
          cross_align_class,
          ALIGNS.fetch(@align),
          default_radius_class,
          "font-medium",
          "cursor-pointer",
          "fp-button",
          press_class,
          "border",
          "transition-[color,background-color,border-color,box-shadow,transform] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]",
          "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)]",
          "fp-touch-manipulation",
          conditional_size_classes,
          icon_only_classes,
          ("fp-button-current" if @current)
        )
      end

      def cross_align_class
        (@lines == 2) ? "items-start" : "items-center"
      end

      def label_classes
        "#{LABEL_ALIGNS.fetch(@align)} #{LINES.fetch(@lines)}"
      end

      def default_radius_class
        return if custom_radius_override?

        "rounded-[var(--button-border-radius)]"
      end

      def custom_radius_override?
        class_tokens = Array(@system_arguments[:class]).flat_map { |value| value.to_s.split }

        class_tokens.any? do |token|
          token.match?(/\A!?rounded(?:$|-(?:none|sm|md|lg|xl|2xl|3xl|4xl|full|\[[^\]]+\]))\z/)
        end
      end

      def icon_only_classes
        return unless @icon_only

        "#{ICON_ONLY_SIZES.fetch(@size)} fp-hit-target"
      end

      def press_class
        StyleRegistry.press_class(@style)
      end

      def style_data
        {fp_style: @style.to_s}
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_style!
        return if StyleRegistry.known?(@style)

        raise ArgumentError, StyleRegistry.invalid_style_message(@style)
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_content!
        has_text = @text.present?
        has_icon = @icon.present?
        unless has_text || has_icon
          raise ArgumentError, "Button must have either a text prop or an icon prop"
        end

        return unless @icon_only
        return if icon_only_accessible_name.present?

        raise ArgumentError, "Icon-only buttons need an accessible name. Pass text: or aria: { label: \"Search\" }."
      end

      def icon_only_accessible_name
        explicit_aria_label.presence || @text.presence
      end

      def explicit_aria_label
        aria_attributes[:label].presence || aria_attributes["label"].presence
      end

      def derived_icon_only_label
        return unless @icon_only
        return if explicit_aria_label.present?

        @text.presence
      end

      def validate_align!
        return if ALIGNS.key?(@align)

        raise ArgumentError, "Invalid align: #{@align.inspect}. Must be one of: #{ALIGNS.keys.join(", ")}."
      end

      def validate_lines!
        return if LINES.key?(@lines)

        raise ArgumentError, "Invalid lines: #{@lines.inspect}. Must be 1 or 2."
      end

      def validate_current!
        return if @current == true || @current == false

        raise ArgumentError, "Invalid current: #{@current.inspect}. Must be true or false."
      end

      def validate_title!
        validate_text_option!(@title, name: :title)
      end

      def validate_trailing!
        return unless @icon_only && trailing?

        raise ArgumentError, "Trailing slot is not supported on icon-only buttons."
      end

      def validate_href!(original_url)
        # Check if the original URL was provided but sanitization failed
        return if @href.present?

        # Use a generic error message to avoid leaking sensitive information in logs
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
