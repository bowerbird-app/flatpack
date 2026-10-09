# frozen_string_literal: true

module FlatPack
  module RadioGroup
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "h-[var(--checkbox-size)]" "w-[var(--checkbox-size)]"
      # "sr-only" "peer" "flex" "flex-wrap" "gap-2" "grid" "grid-cols-1"
      # "sm:grid-cols-[repeat(auto-fit,minmax(14rem,1fr))]" "gap-3"
      # "min-h-[7rem]" "rounded-[var(--radius-lg)]" "rounded-[var(--button-border-radius)]"
      # "border-2" "border-[var(--surface-border-color)]" "border-[var(--color-primary)]"
      # "border-[var(--color-error)]" "bg-[var(--surface-background-color)]"
      # "bg-[color-mix(in_oklab,var(--color-primary)_12%,var(--surface-background-color))]"
      # "has-[:checked]:border-[var(--color-primary)]"
      # "has-[:checked]:bg-[color-mix(in_oklab,var(--color-primary)_12%,var(--surface-background-color))]"
      # "has-[:focus-visible]:outline-none" "has-[:focus-visible]:ring-2"
      # "has-[:focus-visible]:ring-ring" "has-[:focus-visible]:ring-offset-2"
      # "has-[:focus-visible]:ring-offset-[var(--surface-background-color)]"
      # "has-[:focus-visible]:ring-[var(--button-focus-ring-color)]"
      # "has-[:focus-visible]:ring-offset-[var(--button-focus-ring-offset-color)]"
      # "has-[:disabled]:opacity-50" "has-[:disabled]:cursor-not-allowed"
      # "has-[:disabled]:pointer-events-none" "hover:bg-[var(--surface-muted-background-color)]"
      # "hover:border-[var(--surface-border-hover-color)]" "active:translate-y-px"
      # "motion-reduce:transform-none" "motion-reduce:transition-none"
      # "group-has-[:checked]:text-[var(--color-primary)]"
      # "fp-button" "fp-touch-manipulation" "items-center" "text-center" "justify-center"
      # "px-[var(--button-padding-x-sm)]" "py-[var(--button-padding-y-sm)]" "text-xs"
      # "px-[var(--button-padding-x-md)]" "py-[var(--button-padding-y-md)]" "text-sm"
      # "px-[var(--button-padding-x-lg)]" "py-[var(--button-padding-y-lg)]" "text-base"
      # "has-[:checked]:bg-[var(--button-primary-background-color)]"
      # "has-[:checked]:text-[var(--button-primary-text-color)]"
      # "has-[:checked]:border-[var(--button-primary-border-color)]"
      # "has-[:checked]:hover:bg-[var(--button-primary-hover-background-color)]"
      # "has-[:checked]:shadow-[var(--button-shadow)]"
      # "has-[:checked]:hover:shadow-[var(--button-shadow-hover)]"
      # "has-[:checked]:active:shadow-[var(--button-shadow-active)]"
      # "opacity-[var(--button-disabled-opacity)]" "mt-4"
      # "h-8" "w-8" "h-10" "w-10" "h-12" "w-12" "min-h-11" "min-w-11" "p-1.5"
      # "gap-3" "shrink-0" "overflow-visible" "w-3.5" "h-3.5"
      # "rounded-[var(--color-swatch-radius)]"
      # "border-[var(--color-swatch-border-color)]"
      # "shadow-[var(--color-swatch-shadow)]"
      # "group-has-[:checked]:ring-2"
      # "group-has-[:checked]:ring-[var(--color-swatch-selected-ring-color)]"
      # "group-has-[:checked]:ring-offset-2"
      # "group-has-[:checked]:ring-offset-[var(--color-swatch-ring-offset-color)]"
      # "group-has-[:checked]:opacity-100" "opacity-0"
      # "text-[var(--color-swatch-check-on-dark)]"
      # "text-[var(--color-swatch-check-on-light)]"
      # "hover:-translate-y-px" "active:scale-[0.96]"

      SIZES = FlatPack::Shared::ControlSize::SIZES
      VARIANTS = %i[default inline cards swatches].freeze
      SWATCH_SIZES = {
        sm: "h-8 w-8",
        md: "h-10 w-10",
        lg: "h-12 w-12"
      }.freeze
      SWATCH_SIZE_FALLBACKS = {
        sm: "width: 2rem; height: 2rem",
        md: "width: 2.5rem; height: 2.5rem",
        lg: "width: 3rem; height: 3rem"
      }.freeze
      SWATCH_CHECK_SIZES = {
        sm: "w-3.5 h-3.5",
        md: "w-4 h-4",
        lg: "w-5 h-5"
      }.freeze
      SWATCH_LIGHT_INK_THRESHOLD = 0.55

      def initialize(
        name:,
        options:,
        value: nil,
        label: nil,
        disabled: false,
        required: false,
        error: nil,
        help_text: nil,
        size: :md,
        variant: :default,
        show_tooltip: true,
        tooltip_placement: :top,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @raw_options = options
        @options = normalize_options(options)
        @value = value
        @label = label
        @disabled = disabled
        @required = required
        @error = error
        @help_text = normalize_help_text!(help_text)
        @size = FlatPack::Shared::ControlSize.normalize!(size)
        @variant = (variant || :default).to_sym
        @show_tooltip = ActiveModel::Type::Boolean.new.cast(show_tooltip)
        @tooltip_placement = tooltip_placement.to_sym

        validate_name!
        validate_options!
        validate_variant!
        validate_tooltip_placement!
        resolve_swatch_colors!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_radio_group,
            render_help_text,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        content_tag(:legend, @label, class: label_classes)
      end

      def render_radio_group
        return render_visual_radio_group unless default_variant?

        content_tag(:fieldset, class: "space-y-2") do
          safe_join(@options.map { |option| render_radio_option(option) })
        end
      end

      def render_radio_option(option)
        option_value = option[:value]
        option_label = option[:label]
        option_disabled = option[:disabled] || @disabled
        checked = @value.to_s == option_value.to_s

        content_tag(:div, class: "flex items-center") do
          safe_join([
            tag.input(**radio_attributes(option_value, checked, option_disabled)),
            label_tag(radio_id(option_value), option_label, class: radio_label_classes(option_disabled))
          ])
        end
      end

      def render_visual_radio_group
        content_tag(:fieldset, class: visual_group_classes) do
          safe_join(@options.map { |option| render_visual_option(option) })
        end
      end

      def render_visual_option(option)
        option_value = option[:value]
        option_disabled = option[:disabled] || @disabled
        checked = @value.to_s == option_value.to_s
        option_id = radio_id(option_value)

        option_el = content_tag(:label, **visual_option_tag_attributes(option_id, option_disabled)) do
          safe_join([
            tag.input(**visual_radio_attributes(option_value, checked, option_disabled)),
            render_visual_face(option)
          ])
        end

        return option_el unless render_swatch_tooltip?(option)

        FlatPack::Tooltip::Component.new(
          text: option[:label],
          placement: @tooltip_placement
        ).render_in(view_context) do
          option_el
        end
      end

      def visual_option_tag_attributes(option_id, option_disabled)
        attrs = {for: option_id, class: visual_option_classes(option_disabled)}
        attrs[:data] = {fp_style: "secondary"} if inline_variant?
        attrs
      end

      def render_visual_face(option)
        if cards_variant?
          render_card_face(option)
        elsif swatches_variant?
          render_swatch_face(option)
        else
          render_inline_face(option)
        end
      end

      def render_swatch_face(option)
        safe_join([
          content_tag(:span, swatch_accessible_name(option), class: "sr-only"),
          content_tag(
            :span,
            render_swatch_check(option),
            class: swatch_face_classes,
            style: swatch_face_style(option),
            aria: {hidden: true}
          )
        ])
      end

      def render_swatch_check(option)
        content_tag(
          :span,
          class: [
            "pointer-events-none absolute inset-0 flex items-center justify-center",
            "opacity-0 group-has-[:checked]:opacity-100",
            "transition-[opacity] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
            "motion-reduce:transition-none",
            swatch_ink_classes(option)
          ].join(" ")
        ) do
          content_tag(
            :svg,
            tag.path(d: "m5 13 4 4 10-10"),
            class: SWATCH_CHECK_SIZES.fetch(@size),
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2.5",
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            aria: {hidden: true}
          )
        end
      end

      def render_inline_face(option)
        content_tag(:span, class: "inline-flex items-center gap-2 pointer-events-none") do
          safe_join([
            render_option_icon(option, size: @size),
            content_tag(:span, option[:label])
          ].compact)
        end
      end

      def render_card_face(option)
        content_tag(:span, class: "flex h-full min-w-0 flex-col items-center text-center gap-2 pointer-events-none") do
          safe_join([
            render_option_icon(
              option,
              size: :lg,
              extra_class: "text-[var(--surface-content-color)] group-has-[:checked]:text-[var(--color-primary)]"
            ),
            render_card_copy(option)
          ].compact)
        end
      end

      def render_card_copy(option)
        content_tag(:span, class: "min-w-0 w-full text-center") do
          safe_join([
            content_tag(
              :span,
              option[:label],
              class: "block text-sm font-semibold text-[var(--surface-content-color)] fp-text-balance"
            ),
            (if option[:description].present?
               content_tag(
                 :span,
                 option[:description],
                 class: "mt-1 block text-xs text-[var(--surface-muted-content-color)] fp-text-pretty"
               )
             end)
          ].compact)
        end
      end

      def render_option_icon(option, size:, extra_class: nil)
        name = option[:icon]
        return unless name.present?

        render FlatPack::Shared::IconComponent.new(
          name: name,
          size: size,
          class: ["pointer-events-none", extra_class].compact.join(" ")
        )
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def radio_attributes(option_value, checked, option_disabled)
        attrs = {
          type: "radio",
          name: @name,
          id: radio_id(option_value),
          value: option_value,
          checked: checked,
          disabled: option_disabled,
          required: @required,
          class: radio_classes,
          style: size_style
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?)
      end

      def visual_radio_attributes(option_value, checked, option_disabled)
        attrs = {
          type: "radio",
          name: @name,
          id: radio_id(option_value),
          value: option_value,
          checked: checked,
          disabled: option_disabled,
          required: @required,
          class: visual_radio_input_classes
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?)
      end

      def size_style
        declaration = FlatPack::Shared::ControlSize.css_var_declaration(@size)
        existing = @system_arguments[:style] || @system_arguments["style"]
        return declaration unless existing.present?

        "#{existing.to_s.rstrip.sub(/;+\z/, "")}; #{declaration}"
      end

      def wrapper_classes
        "flat-pack-radio-group-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--surface-content-color)] mb-2"
        )
      end

      def radio_label_classes(disabled)
        classes(
          "ml-2 text-sm font-medium text-[var(--surface-content-color)]",
          disabled ? "opacity-50 cursor-not-allowed" : "cursor-pointer"
        )
      end

      def radio_classes
        base_classes = [
          "flat-pack-radio",
          "h-[var(--checkbox-size)] w-[var(--checkbox-size)]",
          "rounded-full",
          "border",
          "bg-[var(--surface-background-color)]",
          "accent-[var(--color-primary)]",
          "checked:text-[var(--color-primary-text)]",
          "checked:bg-[var(--color-primary)] checked:border-[var(--color-primary)]",
          "transition-colors duration-base",
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:ring-offset-2",
          "cursor-pointer",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-error)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def visual_radio_input_classes
        ["sr-only", "peer", @custom_class].compact.join(" ")
      end

      def visual_group_classes
        if cards_variant?
          "grid grid-cols-1 sm:grid-cols-[repeat(auto-fit,minmax(14rem,1fr))] gap-3"
        elsif swatches_variant?
          "flex flex-wrap items-center gap-3"
        else
          "flex flex-wrap gap-2"
        end
      end

      def visual_option_classes(option_disabled)
        return inline_option_classes(option_disabled) if inline_variant?
        return swatch_option_classes(option_disabled) if swatches_variant?

        [
          "group relative",
          "border-2",
          visual_option_layout_classes,
          visual_option_surface_classes(option_disabled: option_disabled),
          visual_option_motion_classes,
          visual_option_selected_classes,
          visual_option_focus_classes,
          (option_disabled ? visual_option_disabled_classes : "cursor-pointer")
        ].compact.join(" ")
      end

      def inline_option_classes(option_disabled)
        [
          "fp-button relative",
          "inline-flex items-center justify-center gap-2",
          "rounded-[var(--button-border-radius)]",
          "font-medium",
          "border",
          "fp-touch-manipulation",
          "transition-[color,background-color,border-color,box-shadow,transform] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
          "motion-reduce:transform-none motion-reduce:transition-none",
          FlatPack::Button::Component::SIZES.fetch(@size),
          "has-[:checked]:bg-[var(--button-primary-background-color)]",
          "has-[:checked]:text-[var(--button-primary-text-color)]",
          "has-[:checked]:border-[var(--button-primary-border-color)]",
          (unless option_disabled
             "has-[:checked]:hover:bg-[var(--button-primary-hover-background-color)]"
           end),
          "has-[:checked]:shadow-[var(--button-shadow)]",
          (unless option_disabled
             "has-[:checked]:hover:shadow-[var(--button-shadow-hover)]"
           end),
          "has-[:checked]:active:shadow-[var(--button-shadow-active)]",
          "has-[:focus-visible]:outline-none has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-inset",
          "has-[:focus-visible]:ring-[var(--button-focus-ring-color)] has-[:focus-visible]:ring-offset-2",
          "has-[:focus-visible]:ring-offset-[var(--button-focus-ring-offset-color)]",
          (option_disabled ? "opacity-[var(--button-disabled-opacity)] cursor-not-allowed pointer-events-none" : "cursor-pointer")
        ].compact.join(" ")
      end

      def visual_option_layout_classes
        "flex min-h-[7rem] flex-col items-center justify-center p-4 rounded-[var(--radius-lg)]"
      end

      def visual_option_surface_classes(option_disabled: false)
        border = @error ? "border-[var(--color-error)]" : "border-[var(--surface-border-color)]"
        hover = if option_disabled
          nil
        else
          "hover:bg-[var(--surface-muted-background-color)] hover:border-[var(--surface-border-hover-color)]"
        end
        [border, "bg-[var(--surface-background-color)]", hover].compact.join(" ")
      end

      def visual_option_motion_classes
        "transition-[color,background-color,border-color,box-shadow,transform] " \
          "duration-[var(--duration-fast)] ease-[var(--easing-standard)] " \
          "active:translate-y-px motion-reduce:transform-none motion-reduce:transition-none"
      end

      def visual_option_selected_classes
        "has-[:checked]:border-[var(--color-primary)] " \
          "has-[:checked]:bg-[color-mix(in_oklab,var(--color-primary)_12%,var(--surface-background-color))] " \
          "has-[:checked]:hover:bg-[color-mix(in_oklab,var(--color-primary)_12%,var(--surface-background-color))]"
      end

      def visual_option_focus_classes
        "has-[:focus-visible]:outline-none has-[:focus-visible]:ring-2 " \
          "has-[:focus-visible]:ring-ring has-[:focus-visible]:ring-offset-2 " \
          "has-[:focus-visible]:ring-offset-[var(--surface-background-color)]"
      end

      def visual_option_disabled_classes
        "opacity-50 cursor-not-allowed pointer-events-none"
      end

      def swatch_option_classes(option_disabled)
        [
          "flat-pack-radio-swatch group relative",
          "inline-flex shrink-0 items-center justify-center",
          "min-h-11 min-w-11 p-1.5 overflow-visible",
          "fp-touch-manipulation",
          "transition-[transform] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
          "motion-reduce:transform-none motion-reduce:transition-none",
          (unless option_disabled
             "hover:-translate-y-px active:scale-[0.96]"
           end),
          "has-[:focus-visible]:outline-none has-[:focus-visible]:ring-2",
          "has-[:focus-visible]:ring-[var(--color-swatch-selected-ring-color)]",
          "has-[:focus-visible]:ring-offset-2",
          "has-[:focus-visible]:ring-offset-[var(--color-swatch-ring-offset-color)]",
          (option_disabled ? visual_option_disabled_classes : "cursor-pointer")
        ].compact.join(" ")
      end

      def swatch_face_classes
        [
          "pointer-events-none relative block shrink-0",
          "rounded-[var(--color-swatch-radius)]",
          "border",
          (@error ? "border-[var(--color-error)]" : "border-[var(--color-swatch-border-color)]"),
          "shadow-[var(--color-swatch-shadow)]",
          SWATCH_SIZES.fetch(@size),
          "group-has-[:checked]:ring-2",
          "group-has-[:checked]:ring-[var(--color-swatch-selected-ring-color)]",
          "group-has-[:checked]:ring-offset-2",
          "group-has-[:checked]:ring-offset-[var(--color-swatch-ring-offset-color)]",
          "transition-[box-shadow] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
          "motion-reduce:transition-none"
        ].join(" ")
      end

      def swatch_face_style(option)
        "#{SWATCH_SIZE_FALLBACKS.fetch(@size)}; background-color: #{option[:color]}"
      end

      def swatch_ink_classes(option)
        if swatch_color_light?(option[:color])
          "text-[var(--color-swatch-check-on-light)]"
        else
          "text-[var(--color-swatch-check-on-dark)]"
        end
      end

      def swatch_color_light?(color)
        hex = expand_hex(color.to_s)
        return false unless hex.match?(/\A#(?:[\da-f]{6}|[\da-f]{8})\z/i)

        digits = hex.delete("#")
        red, green, blue = [digits[0, 2], digits[2, 2], digits[4, 2]].map { |pair| pair.to_i(16) / 255.0 }
        luminance = (0.2126 * linearize_srgb(red)) + (0.7152 * linearize_srgb(green)) + (0.0722 * linearize_srgb(blue))
        luminance > SWATCH_LIGHT_INK_THRESHOLD
      end

      def linearize_srgb(channel)
        (channel <= 0.04045) ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
      end

      def expand_hex(color)
        return color unless color.match?(/\A#[\da-f]{3}\z/i)

        digits = color.delete("#")
        "##{digits.chars.map { |digit| digit * 2 }.join}"
      end

      def render_swatch_tooltip?(option)
        swatches_variant? && @show_tooltip && option[:label].present?
      end

      def swatch_accessible_name(option)
        option[:label].presence || option[:value].to_s
      end

      def error_classes
        return "mt-2 text-sm text-[var(--color-error)]" if default_variant?

        "mt-4 text-sm text-[var(--color-error)]"
      end

      def help_text_classes
        return super if default_variant?

        "mt-4 text-xs text-[var(--surface-muted-content-color)]"
      end

      def radio_id(option_value)
        "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{option_value.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}"
      end

      def error_id
        "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_error"
      end

      def help_text_id
        "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_help_text"
      end

      def normalize_options(options)
        return [] if options.nil?

        options.map do |option|
          case option
          when String
            {label: option, value: option, disabled: false}
          when Array
            {label: option[0], value: option[1], disabled: false}
          when Hash
            {
              label: option[:label] || option["label"],
              value: option[:value] || option["value"],
              disabled: option[:disabled] || option["disabled"] || false,
              icon: option[:icon] || option["icon"],
              description: option[:description] || option["description"],
              color: option[:color] || option["color"]
            }
          else
            raise ArgumentError, "Invalid option format: #{option.inspect}"
          end
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_options!
        raise ArgumentError, "options is required" if @raw_options.nil?
        raise ArgumentError, "options must be an array" unless @raw_options.is_a?(Array)
        raise ArgumentError, "options cannot be empty" if @raw_options.empty?
      end

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
      end

      def default_variant?
        @variant == :default
      end

      def cards_variant?
        @variant == :cards
      end

      def inline_variant?
        @variant == :inline
      end

      def swatches_variant?
        @variant == :swatches
      end

      def validate_tooltip_placement!
        return if FlatPack::Tooltip::Component::PLACEMENTS.key?(@tooltip_placement)

        raise ArgumentError, "Invalid tooltip_placement: #{@tooltip_placement}. Must be one of: #{FlatPack::Tooltip::Component::PLACEMENTS.keys.join(", ")}"
      end

      def resolve_swatch_colors!
        return unless swatches_variant?

        @options = @options.map do |option|
          color = resolve_swatch_color(option)
          if color.nil?
            raise ArgumentError, "Swatch option #{option[:value].inspect} needs a color. Pass color: or a CSS colour value."
          end

          option.merge(color: color)
        end
      end

      def resolve_swatch_color(option)
        raw = option[:color].presence || option[:value]
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(raw)
        return if sanitized.nil?

        expand_hex(sanitized)
      end
    end
  end
end
