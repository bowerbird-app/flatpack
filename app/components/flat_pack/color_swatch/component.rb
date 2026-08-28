# frozen_string_literal: true

module FlatPack
  module ColorSwatch
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-6" "w-6" "h-8" "w-8" "h-10" "w-10" "h-12" "w-12"
      SIZES = {
        xs: "h-6 w-6",
        sm: "h-8 w-8",
        md: "h-10 w-10",
        lg: "h-12 w-12"
      }.freeze

      DEFAULT_COLOR = "#000000"

      def initialize(
        color:,
        size: :md,
        selected: false,
        name: nil,
        value: nil,
        text: nil,
        disabled: false,
        show_tooltip: true,
        tooltip_placement: :top,
        **system_arguments
      )
        super(**system_arguments)
        @color = normalize_color(color)
        @size = size.to_sym
        @selected = ActiveModel::Type::Boolean.new.cast(selected)
        @name = name.presence
        @value = normalize_input_value(value)
        @text = text.presence
        @disabled = ActiveModel::Type::Boolean.new.cast(disabled)
        @show_tooltip = ActiveModel::Type::Boolean.new.cast(show_tooltip)
        @tooltip_placement = tooltip_placement.to_sym

        validate_color!
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
            controller: "flat-pack--color-swatch",
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

        FlatPack::Tooltip::Component.new(text: @text, placement: @tooltip_placement).render_in(view_context) do
          control
        end
      end

      def render_control
        content_tag(:div, **control_attributes) do
          safe_join([
            tag.input(**input_attributes),
            render_swatch_face
          ])
        end
      end

      def control_attributes
        {
          class: classes(
            "relative inline-flex shrink-0 items-center justify-center",
            "rounded-[var(--color-swatch-radius)]",
            "focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-[var(--color-swatch-selected-ring-color)]",
            SIZES.fetch(@size),
            @disabled ? "cursor-not-allowed opacity-50" : "cursor-pointer"
          ),
          style: size_fallback_style
        }
      end

      def render_swatch_face
        content_tag(
          :span,
          nil,
          class: swatch_face_classes,
          style: swatch_face_style,
          aria: {hidden: true},
          data: {flat_pack__color_swatch_target: "swatch"}
        )
      end

      def swatch_face_classes
        classes(
          "pointer-events-none absolute inset-0 block",
          "rounded-[var(--color-swatch-radius)]",
          "border border-[var(--color-swatch-border-color)]",
          "shadow-[var(--color-swatch-shadow)]",
          selected_ring_classes
        )
      end

      def selected_ring_classes
        return unless @selected

        "ring-2 ring-[var(--color-swatch-selected-ring-color)] ring-offset-2 ring-offset-[var(--color-swatch-ring-offset-color)]"
      end

      def swatch_face_style
        "background-color: #{@color}"
      end

      def size_fallback_style
        case @size
        when :xs then "width: 1.5rem; height: 1.5rem"
        when :sm then "width: 2rem; height: 2rem"
        when :md then "width: 2.5rem; height: 2.5rem"
        when :lg then "width: 3rem; height: 3rem"
        end
      end

      def input_attributes
        attrs = {
          type: "color",
          id: input_id,
          value: input_value,
          disabled: @disabled,
          class: classes(
            "absolute inset-0 z-10 h-full w-full cursor-pointer opacity-0",
            @disabled ? "pointer-events-none" : nil
          ),
          aria: {label: accessible_name},
          data: {
            flat_pack__color_swatch_target: "input",
            action: "input->flat-pack--color-swatch#update change->flat-pack--color-swatch#update"
          }
        }
        attrs[:name] = @name if @name

        attrs
      end

      def render_tooltip?
        @show_tooltip && @text.present?
      end

      def accessible_name
        @text.presence || "Color"
      end

      def input_id
        @input_id ||= @system_arguments[:id].presence || "flat_pack_color_swatch_#{SecureRandom.hex(4)}"
      end

      def input_value
        candidate = @value.presence || @color
        return candidate if FlatPack::AttributeSanitizer::CSS_HEX_COLOR_PATTERN.match?(candidate)

        DEFAULT_COLOR
      end

      def normalize_color(color)
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(color)
        raise ArgumentError, "color is required" if sanitized.nil?

        expand_hex(sanitized)
      end

      def normalize_input_value(value)
        return nil if value.nil? || value.to_s.strip.empty?

        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(value)
        return nil if sanitized.nil?

        expand_hex(sanitized)
      end

      def expand_hex(color)
        return color unless color.match?(/\A#[\da-f]{3}\z/i)

        digits = color.delete("#")
        "##{digits.chars.map { |digit| digit * 2 }.join}"
      end

      def validate_color!
        raise ArgumentError, "color is required" if @color.nil? || @color.to_s.strip.empty?
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
