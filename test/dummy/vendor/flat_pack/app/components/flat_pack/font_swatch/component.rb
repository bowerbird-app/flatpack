# frozen_string_literal: true

module FlatPack
  module FontSwatch
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-6" "w-6" "h-8" "w-8" "h-10" "w-10" "h-12" "w-12"
      # "text-[10px]" "text-xs" "text-sm" "text-base"
      SIZES = {
        xs: "h-6 w-6",
        sm: "h-8 w-8",
        md: "h-10 w-10",
        lg: "h-12 w-12"
      }.freeze

      FACE_TEXT_SIZES = {
        xs: "text-[10px]",
        sm: "text-xs",
        md: "text-sm",
        lg: "text-base"
      }.freeze

      SAMPLE_TEXT = "Aa"

      def initialize(
        font:,
        options:,
        size: :md,
        selected: false,
        name: nil,
        text: nil,
        disabled: false,
        show_tooltip: true,
        tooltip_placement: :top,
        **system_arguments
      )
        super(**system_arguments)
        @options = normalize_options(options)
        @font = normalize_font(font)
        @size = size.to_sym
        @selected = ActiveModel::Type::Boolean.new.cast(selected)
        @name = name.presence
        @text = text.presence
        @disabled = ActiveModel::Type::Boolean.new.cast(disabled)
        @show_tooltip = ActiveModel::Type::Boolean.new.cast(show_tooltip)
        @tooltip_placement = tooltip_placement.to_sym

        validate_options!
        validate_font!
        validate_size!
        validate_tooltip_placement!
      end

      def call
        content_tag(:div, **root_attributes) do
          render_control_with_tooltip
        end
      end

      private

      def root_attributes
        merge_attributes(
          class: root_classes,
          data: {
            controller: "flat-pack--font-swatch",
            selected: @selected.to_s
          }
        ).except(:id)
      end

      def root_classes
        "relative inline-flex items-center"
      end

      def render_control_with_tooltip
        control = render_control

        return control unless render_tooltip?

        FlatPack::Tooltip::Component.new(text: tooltip_text, placement: @tooltip_placement).render_in(view_context) do
          control
        end
      end

      def render_control
        content_tag(:div, **control_attributes) do
          safe_join([
            content_tag(:select, safe_join(select_options_markup), **select_attributes),
            render_swatch_face
          ])
        end
      end

      def control_attributes
        {
          class: classes(
            "relative inline-flex shrink-0 items-center justify-center",
            "rounded-[var(--font-swatch-radius)]",
            "focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-[var(--font-swatch-selected-ring-color)]",
            SIZES.fetch(@size),
            @disabled ? "cursor-not-allowed opacity-50" : "cursor-pointer"
          ),
          style: size_fallback_style
        }
      end

      def render_swatch_face
        content_tag(
          :span,
          SAMPLE_TEXT,
          class: swatch_face_classes,
          style: swatch_face_style,
          aria: {hidden: true},
          data: {flat_pack__font_swatch_target: "swatch"}
        )
      end

      def swatch_face_classes
        classes(
          "pointer-events-none absolute inset-0 flex items-center justify-center",
          "rounded-[var(--font-swatch-radius)]",
          "border border-[var(--font-swatch-border-color)]",
          "bg-[var(--font-swatch-background-color)]",
          "text-[var(--font-swatch-text-color)]",
          "font-medium leading-none",
          "shadow-[var(--font-swatch-shadow)]",
          FACE_TEXT_SIZES.fetch(@size),
          selected_ring_classes
        )
      end

      def selected_ring_classes
        return unless @selected

        "ring-2 ring-[var(--font-swatch-selected-ring-color)] ring-offset-2 ring-offset-[var(--font-swatch-ring-offset-color)]"
      end

      def swatch_face_style
        "font-family: #{@font}"
      end

      def size_fallback_style
        case @size
        when :xs then "width: 1.5rem; height: 1.5rem"
        when :sm then "width: 2rem; height: 2rem"
        when :md then "width: 2.5rem; height: 2.5rem"
        when :lg then "width: 3rem; height: 3rem"
        end
      end

      def select_attributes
        attrs = {
          id: select_id,
          disabled: @disabled,
          class: classes(
            "absolute inset-0 z-10 h-full w-full cursor-pointer opacity-0",
            @disabled ? "pointer-events-none" : nil
          ),
          aria: {label: accessible_name},
          data: {
            flat_pack__font_swatch_target: "select",
            action: "change->flat-pack--font-swatch#update"
          }
        }
        attrs[:name] = @name if @name

        attrs
      end

      def select_options_markup
        @options.map do |option|
          tag.option(
            option[:label],
            value: option[:value],
            selected: option[:value] == @font
          )
        end
      end

      def render_tooltip?
        @show_tooltip && tooltip_text.present?
      end

      def tooltip_text
        @text.presence || selected_option_label
      end

      def accessible_name
        tooltip_text.presence || "Font"
      end

      def selected_option_label
        match = @options.find { |option| option[:value] == @font }
        match&.fetch(:label)
      end

      def select_id
        @select_id ||= @system_arguments[:id].presence || "flat_pack_font_swatch_#{SecureRandom.hex(4)}"
      end

      def normalize_font(font)
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_font_family(font)
        raise ArgumentError, "font is required" if sanitized.nil?

        sanitized
      end

      def normalize_options(options)
        raise ArgumentError, "options is required" if options.nil?
        raise ArgumentError, "options must be an array" unless options.is_a?(Array)

        options.map do |option|
          label, value = case option
          when Array
            raise ArgumentError, "each option must be [label, value]" unless option.length >= 2

            [option[0], option[1]]
          when Hash
            [
              option[:label] || option["label"],
              option[:value] || option["value"]
            ]
          else
            raise ArgumentError, "each option must be [label, value] or {label:, value:}"
          end

          raise ArgumentError, "option label is required" if label.nil? || label.to_s.strip.empty?

          sanitized_value = FlatPack::AttributeSanitizer.sanitize_css_font_family(value)
          raise ArgumentError, "option value is required" if sanitized_value.nil?

          {label: label.to_s, value: sanitized_value}
        end
      end

      def validate_font!
        raise ArgumentError, "font is required" if @font.nil? || @font.to_s.strip.empty?
      end

      def validate_options!
        raise ArgumentError, "options must include at least one entry" if @options.empty?
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_tooltip_placement!
        return if FlatPack::Tooltip::Component::PLACEMENTS.key?(@tooltip_placement)

        raise ArgumentError, "Invalid tooltip_placement: #{@tooltip_placement}. Must be one of: #{FlatPack::Tooltip::Component::PLACEMENTS.keys.join(", ")}"
      end
    end
  end
end
