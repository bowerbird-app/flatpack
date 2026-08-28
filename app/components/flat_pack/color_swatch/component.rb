# frozen_string_literal: true

module FlatPack
  module ColorSwatch
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-6" "w-6" "h-8" "w-8" "h-10" "w-10" "h-12" "w-12" "h-16" "w-16"
      SIZES = {
        xs: "h-6 w-6",
        sm: "h-8 w-8",
        md: "h-10 w-10",
        lg: "h-12 w-12",
        xl: "h-16 w-16"
      }.freeze

      SIZE_FALLBACKS = {
        xs: "width: 1.5rem; height: 1.5rem",
        sm: "width: 2rem; height: 2rem",
        md: "width: 2.5rem; height: 2.5rem",
        lg: "width: 3rem; height: 3rem",
        xl: "width: 4rem; height: 4rem"
      }.freeze

      DEFAULT_VALUE = "#000000"

      def initialize(
        text:,
        value: DEFAULT_VALUE,
        name: nil,
        selected: false,
        size: :md,
        disabled: false,
        show_tooltip: true,
        tooltip_placement: :top,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @value = normalize_value(value)
        @name = name.presence
        @selected = ActiveModel::Type::Boolean.new.cast(selected)
        @size = size.to_sym
        @disabled = ActiveModel::Type::Boolean.new.cast(disabled)
        @show_tooltip = ActiveModel::Type::Boolean.new.cast(show_tooltip)
        @tooltip_placement = tooltip_placement.to_sym

        validate_text!
        validate_size!
        validate_tooltip_placement!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_swatch_with_tooltip,
            render_selected_label
          ].compact)
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
        classes(
          "inline-flex flex-col items-center",
          "gap-[var(--color-swatch-gap)]"
        )
      end

      def render_swatch_with_tooltip
        swatch = render_swatch_control

        return swatch unless render_tooltip?

        FlatPack::Tooltip::Component.new(text: @text, placement: @tooltip_placement).render_in(view_context) do
          swatch
        end
      end

      def render_swatch_control
        content_tag(:label, **control_attributes) do
          safe_join([
            render_swatch_face,
            render_color_input
          ])
        end
      end

      def control_attributes
        {
          class: classes(
            "relative inline-flex shrink-0",
            @disabled ? "cursor-not-allowed opacity-50" : "cursor-pointer"
          ),
          for: input_id
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
          "block rounded-[var(--color-swatch-radius)]",
          "border border-[var(--color-swatch-border-color)]",
          "shadow-[var(--color-swatch-shadow)]",
          "pointer-events-none",
          SIZES.fetch(@size),
          selected_ring_classes
        )
      end

      def selected_ring_classes
        return unless @selected

        "ring-2 ring-[var(--color-swatch-selected-ring-color)] ring-offset-2 ring-offset-[var(--color-swatch-ring-offset-color)]"
      end

      def swatch_face_style
        [
          SIZE_FALLBACKS.fetch(@size),
          "background-color: #{@value}"
        ].join("; ")
      end

      def render_color_input
        tag.input(**input_attributes)
      end

      def input_attributes
        attrs = {
          type: "color",
          id: input_id,
          value: input_value,
          disabled: @disabled,
          class: "absolute inset-0 h-full w-full cursor-pointer opacity-0 disabled:cursor-not-allowed",
          aria: {label: @text},
          data: {
            flat_pack__color_swatch_target: "input",
            action: "input->flat-pack--color-swatch#update change->flat-pack--color-swatch#update"
          }
        }
        attrs[:name] = @name if @name

        attrs
      end

      def render_selected_label
        return unless @selected

        content_tag(
          :span,
          @text,
          class: classes(
            "text-xs font-medium text-center leading-tight",
            "text-[var(--color-swatch-label-color)]",
            "max-w-[var(--color-swatch-label-max-width)]"
          )
        )
      end

      def render_tooltip?
        @show_tooltip && @text.present?
      end

      def input_id
        @input_id ||= @system_arguments[:id].presence || "flat_pack_color_swatch_#{SecureRandom.hex(4)}"
      end

      def input_value
        return @value if FlatPack::AttributeSanitizer::CSS_HEX_COLOR_PATTERN.match?(@value)

        DEFAULT_VALUE
      end

      def normalize_value(value)
        sanitized = FlatPack::AttributeSanitizer.sanitize_css_color(value)
        return DEFAULT_VALUE if sanitized.nil?

        expand_hex(sanitized)
      end

      def expand_hex(color)
        return color unless color.match?(/\A#[\da-f]{3}\z/i)

        digits = color.delete("#")
        "##{digits.chars.map { |digit| digit * 2 }.join}"
      end

      def validate_text!
        raise ArgumentError, "text is required" if @text.nil? || @text.to_s.strip.empty?
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
