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
        lg: "p-[var(--button-icon-only-padding-lg)]",
        xs: "p-[var(--button-icon-only-padding-xs)]"
      }.freeze

      # :xs is icon-only. It stays out of SIZES so SegmentedButtons, Tabs, and Button::Pill do not inherit it.
      PUBLIC_SIZES = (SIZES.keys + [:xs]).freeze

      ROUND_RADIUS_CLASS = "rounded-[var(--button-round-border-radius)]"

      ROUND_ICON_ONLY_SIZES = {
        sm: "h-[var(--button-round-size-sm)] w-[var(--button-round-size-sm)] shrink-0",
        md: "h-[var(--button-round-size-md)] w-[var(--button-round-size-md)] shrink-0",
        lg: "h-[var(--button-round-size-lg)] w-[var(--button-round-size-lg)] shrink-0",
        xs: "h-[var(--button-round-size-xs)] w-[var(--button-round-size-xs)] shrink-0"
      }.freeze

      ICON_ONLY_HIT_CLASSES = {
        sm: "fp-hit-target",
        md: "fp-hit-target",
        lg: "fp-hit-target",
        xs: "fp-hit-slop"
      }.freeze

      XS_REQUIRES_ICON_ONLY = "size: :xs is only for icon-only buttons. Pass icon_only: true."

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

      ICON_VARIANTS = IconOptions::VARIANTS
      ICON_STYLES = IconOptions::STYLES

      renders_one :trailing

      def initialize(
        text: nil,
        style: :default,
        size: :md,
        round: false,
        href: nil,
        method: nil,
        target: nil,
        icon: nil,
        icon_variant: nil,
        icon_style: nil,
        icon_only: false,
        loading: false,
        disabled: false,
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
        @round = round
        @method = method
        @target = target
        @icon = icon
        @icon_variant = IconOptions.normalize_variant!(icon_variant)
        @icon_style = IconOptions.normalize_style!(icon_style)
        @icon_only = icon_only
        @loading = loading
        @disabled = disabled ? true : false
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
        validate_round!
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

      # Plain row for a collapsing button group. Label, href, and icon stay.
      # Danger is red text. The wide control keeps id, class, and button chrome.
      def menu_row
        validate_trailing!

        if @href
          link_to(@href, **menu_row_attributes(link: true)) { menu_row_content }
        else
          button_tag(**menu_row_attributes(link: false)) { menu_row_content }
        end
      end

      def self.painted_icon_size(size)
        (size.to_sym == :xs) ? :sm : size
      end

      def self.icon_only_classes_for(size, round:)
        [
          ICON_ONLY_SIZES.fetch(size),
          (ROUND_ICON_ONLY_SIZES.fetch(size) if round),
          ICON_ONLY_HIT_CLASSES.fetch(size)
        ].compact.join(" ")
      end

      def self.validate_size!(size, icon_only:)
        if size == :xs && !icon_only
          raise ArgumentError, XS_REQUIRES_ICON_ONLY
        end

        return if SIZES.key?(size) || ICON_ONLY_SIZES.key?(size)

        raise ArgumentError, "Invalid size: #{size}. Must be one of: #{SIZES.keys.join(", ")}"
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

      def menu_row_content
        content = []

        if @loading
          content << render(FlatPack::Spinner::Component.new(size: icon_size, label: nil))
        elsif @icon
          content << render_leading_icon
        end

        label = menu_row_label
        content << content_tag(:span, label) if label.present?
        safe_join(content)
      end

      def menu_row_label
        return fp_t("button.loading") if @loading

        @text.presence || explicit_aria_label
      end

      def menu_row_attributes(link:)
        attrs = html_attributes.except(:id, "id")
        attrs[:class] = "fp-menu-row"
        attrs[:title] = @title if @title.present?
        data = menu_row_data
        attrs[:data] = data if data.present?
        aria = menu_row_aria(link)
        attrs[:aria] = aria if aria.present?

        if link
          attrs[:method] = @method if @method
          attrs[:target] = @target if @target
          attrs[:rel] = "noopener noreferrer" if @target == "_blank"
          apply_inert_link_attributes!(attrs)
        else
          attrs[:type] = @type
          attrs[:disabled] = true if inactive?
        end

        attrs
      end

      def menu_row_data
        data = data_attributes.dup
        data.delete(:fp_style)
        data.delete("fp_style")
        data[:fp_style] = "danger" if @style.to_sym == :danger
        data.presence
      end

      def menu_row_aria(link)
        aria = aria_attributes.dup
        aria[:current] = "page" if link && @current
        aria[:busy] = "true" if @loading
        aria.presence
      end

      def button_content
        content = []

        if @loading
          content << render(FlatPack::Spinner::Component.new(size: icon_size, label: nil))
          content << content_tag(:span, fp_t("button.loading"), class: label_classes) unless @icon_only
        else
          content << render_leading_icon if @icon
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

      # Heroicon names stay here so icon_variant and icon_style are not dropped.
      # A trusted `<svg` string, or a host prepend on render_icon, goes through
      # render_icon. Do not pass user input as icon:.
      def render_leading_icon
        return render_icon if FlatPack::Shared::InlineSvg.markup?(@icon)

        render_heroicon
      end

      def render_icon
        if FlatPack::Shared::InlineSvg.markup?(@icon)
          content_tag(:span, @icon.html_safe, class: inline_svg_classes, aria: {hidden: true})
        else
          render_heroicon
        end
      end

      # Tailwind CSS scanning requires these classes as string literals.
      # DO NOT REMOVE:
      # "inline-flex" "h-4" "w-4" "h-5" "w-5" "h-6" "w-6" "[&_svg]:h-full" "[&_svg]:w-full"
      def inline_svg_classes
        [
          "inline-flex shrink-0 items-center justify-center",
          FlatPack::Shared::IconComponent::SIZES.fetch(icon_size),
          "[&_svg]:h-full [&_svg]:w-full"
        ].join(" ")
      end

      def render_heroicon
        render FlatPack::Shared::IconComponent.new(
          **IconOptions.component_arguments(
            name: @icon,
            size: icon_size,
            icon_variant: @icon_variant,
            icon_style: @icon_style
          )
        )
      end

      def icon_size
        self.class.painted_icon_size(@size)
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
        attrs[:disabled] = true if inactive?
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
        apply_inert_link_attributes!(attrs)
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
          # "pointer-events-none" "opacity-[var(--button-disabled-opacity)]"
          (inactive_classes if inactive?),
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

        @round ? ROUND_RADIUS_CLASS : "rounded-[var(--button-border-radius)]"
      end

      def custom_radius_override?
        class_tokens = Array(@system_arguments[:class]).flat_map { |value| value.to_s.split }

        class_tokens.any? do |token|
          token.match?(/\A!?rounded(?:$|-(?:none|sm|md|lg|xl|2xl|3xl|4xl|full|\[[^\]]+\]))\z/)
        end
      end

      def icon_only_classes
        return unless @icon_only

        self.class.icon_only_classes_for(@size, round: @round)
      end

      def validate_round!
        return if @round == true || @round == false

        raise ArgumentError, "Invalid round: #{@round.inspect}. Must be true or false."
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
        self.class.validate_size!(@size, icon_only: @icon_only)
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

      def inactive?
        @disabled || @loading
      end

      def inactive_classes
        "pointer-events-none opacity-[var(--button-disabled-opacity)]"
      end

      def apply_inert_link_attributes!(attrs)
        return unless @href.present? && inactive?

        attrs[:tabindex] = "-1"
        attrs[:aria] ||= {}
        attrs[:aria][:disabled] = "true"
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
