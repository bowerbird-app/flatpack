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
      # "[--fp-button-background:var(--button-secondary-background-color)]"
      # "[--fp-button-hover-background:var(--button-secondary-hover-background-color)]"
      # "[--fp-button-text:var(--button-secondary-text-color)]"
      # "[--fp-button-border:var(--button-secondary-border-color)]"
      # "has-[:checked]:[--fp-button-background:var(--button-primary-background-color)]"
      # "has-[:checked]:[--fp-button-hover-background:var(--button-primary-hover-background-color)]"
      # "has-[:checked]:[--fp-button-text:var(--button-primary-text-color)]"
      # "has-[:checked]:[--fp-button-border:var(--button-primary-border-color)]"
      # "has-[:checked]:shadow-[var(--button-shadow)]"
      # "has-[:checked]:hover:shadow-[var(--button-shadow-hover)]"
      # "has-[:checked]:active:shadow-[var(--button-shadow-active)]"
      # "opacity-[var(--button-disabled-opacity)]" "mt-4"

      SIZES = FlatPack::Shared::ControlSize::SIZES
      VARIANTS = %i[default inline cards].freeze

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

        validate_name!
        validate_options!
        validate_variant!
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

        content_tag(:label, **visual_option_tag_attributes(option_id, option_disabled)) do
          safe_join([
            tag.input(**visual_radio_attributes(option_value, checked, option_disabled)),
            render_visual_face(option)
          ])
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
        else
          render_inline_face(option)
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
        else
          "flex flex-wrap gap-2"
        end
      end

      def visual_option_classes(option_disabled)
        return inline_option_classes(option_disabled) if inline_variant?

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
          "[--fp-button-background:var(--button-secondary-background-color)]",
          "[--fp-button-hover-background:var(--button-secondary-hover-background-color)]",
          "[--fp-button-text:var(--button-secondary-text-color)]",
          "[--fp-button-border:var(--button-secondary-border-color)]",
          "has-[:checked]:[--fp-button-background:var(--button-primary-background-color)]",
          "has-[:checked]:[--fp-button-hover-background:var(--button-primary-hover-background-color)]",
          "has-[:checked]:[--fp-button-text:var(--button-primary-text-color)]",
          "has-[:checked]:[--fp-button-border:var(--button-primary-border-color)]",
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
              description: option[:description] || option["description"]
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
    end
  end
end
