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
        picker_placement: :bottom,
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
        @picker_placement = picker_placement.to_sym

        validate_color!
        validate_size!
        validate_tooltip_placement!
        validate_picker_placement!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_trigger_with_tooltip,
            render_selected_label,
            render_picker_popover
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
          "relative inline-flex flex-col items-center",
          "gap-[var(--color-swatch-gap)]"
        )
      end

      def render_trigger_with_tooltip
        trigger = render_trigger_button

        return trigger unless render_tooltip?

        FlatPack::Tooltip::Component.new(text: @text, placement: @tooltip_placement).render_in(view_context) do
          trigger
        end
      end

      def render_trigger_button
        content_tag(:button, **trigger_attributes) do
          render_swatch_face
        end
      end

      def trigger_attributes
        {
          type: "button",
          id: trigger_id,
          disabled: @disabled,
          class: classes(
            "relative inline-flex shrink-0 items-center justify-center",
            "rounded-[var(--color-swatch-radius)]",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--color-swatch-selected-ring-color)]",
            @disabled ? "cursor-not-allowed opacity-50" : "cursor-pointer"
          ),
          aria: {
            label: accessible_name,
            haspopup: "dialog"
          }
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
          size_fallback_style,
          "background-color: #{@color}"
        ].compact.join("; ")
      end

      def size_fallback_style
        case @size
        when :xs then "width: 1.5rem; height: 1.5rem"
        when :sm then "width: 2rem; height: 2rem"
        when :md then "width: 2.5rem; height: 2.5rem"
        when :lg then "width: 3rem; height: 3rem"
        end
      end

      def render_picker_popover
        return if @disabled

        FlatPack::Popover::Component.new(
          trigger_id: trigger_id,
          placement: @picker_placement
        ).render_in(view_context) do |popover|
          popover.content do
            render_picker_panel
          end
        end
      end

      def render_picker_panel
        content_tag(
          :div,
          class: classes(
            "flex flex-col",
            "gap-[var(--color-swatch-picker-gap)]",
            "min-w-[var(--color-swatch-picker-min-width)]"
          ),
          data: {flat_pack__color_swatch_target: "panel"}
        ) do
          safe_join([
            render_picker_heading,
            render_picker_preview_row,
            render_picker_input
          ].compact)
        end
      end

      def render_picker_heading
        return unless @text.present?

        content_tag(
          :p,
          @text,
          class: "text-sm font-medium text-[var(--popover-text-color)]"
        )
      end

      def render_picker_preview_row
        content_tag(:div, class: "flex items-center gap-[var(--stack-gap-sm)]") do
          safe_join([
            content_tag(
              :span,
              nil,
              class: classes(
                "block h-10 w-10 shrink-0",
                "rounded-[var(--color-swatch-radius)]",
                "border border-[var(--color-swatch-border-color)]",
                "shadow-[var(--color-swatch-shadow)]"
              ),
              style: "background-color: #{@color}",
              aria: {hidden: true},
              data: {flat_pack__color_swatch_target: "preview"}
            ),
            content_tag(
              :span,
              display_hex,
              class: classes(
                "text-sm font-mono",
                "text-[var(--surface-muted-content-color)]"
              ),
              data: {flat_pack__color_swatch_target: "hex"}
            )
          ])
        end
      end

      def render_picker_input
        content_tag(:div, class: "flex flex-col gap-1.5") do
          safe_join([
            content_tag(
              :label,
              "Choose colour",
              for: input_id,
              class: "text-xs font-medium text-[var(--surface-muted-content-color)]"
            ),
            tag.input(**input_attributes)
          ])
        end
      end

      def input_attributes
        attrs = {
          type: "color",
          id: input_id,
          value: input_value,
          class: classes(
            "block w-full h-10 cursor-pointer",
            "rounded-[var(--radius-md)]",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "p-1"
          ),
          aria: {label: "#{accessible_name} colour"},
          data: {
            flat_pack__color_swatch_target: "input",
            action: "input->flat-pack--color-swatch#update change->flat-pack--color-swatch#update"
          }
        }
        attrs[:name] = @name if @name

        attrs
      end

      def render_selected_label
        return unless @selected && @text.present?

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

      def accessible_name
        @text.presence || "Color"
      end

      def display_hex
        input_value.upcase
      end

      def trigger_id
        @trigger_id ||= "#{input_id}_trigger"
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

      def validate_picker_placement!
        return if FlatPack::Popover::Component::PLACEMENTS.key?(@picker_placement)

        raise ArgumentError, "Invalid picker_placement: #{@picker_placement}. Must be one of: #{FlatPack::Popover::Component::PLACEMENTS.keys.join(", ")}"
      end
    end
  end
end
