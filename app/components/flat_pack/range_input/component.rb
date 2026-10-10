# frozen_string_literal: true

module FlatPack
  module RangeInput
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[default size text_size zoom].freeze
      SIZE_VARIANTS = %i[size text_size].freeze
      SIZE_GLYPH = "A"
      ZOOM_START_ICON = "magnifying-glass-minus"
      ZOOM_END_ICON = "magnifying-glass-plus"

      renders_one :preview

      def initialize(
        name:,
        id: nil,
        value: nil,
        min: 0,
        max: 100,
        step: 1,
        label: nil,
        help_text: nil,
        show_value: true,
        disabled: false,
        variant: :default,
        start_icon: nil,
        end_icon: nil,
        preview_target: nil,
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @id = id || name
        @value = value || min
        @min = min
        @max = max
        @step = step
        @label = label
        @help_text = normalize_help_text!(help_text)
        @show_value = show_value
        @disabled = disabled
        @variant = (variant || :default).to_sym
        @start_icon = start_icon.presence
        @end_icon = end_icon.presence
        @preview_target = preview_target

        validate_name!
        validate_range!
        validate_variant!
        validate_preview_target!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_label,
            render_preview,
            render_input_wrapper,
            render_help_text
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        content_tag(:label, **label_attributes) do
          safe_join([
            content_tag(:span, @label),
            render_value_display
          ].compact)
        end
      end

      def render_value_display
        return unless @show_value

        content_tag(:span,
          @value.to_s,
          class: "font-mono text-sm",
          data: {"flat-pack--range-input-target": "valueDisplay"})
      end

      def render_preview
        return unless preview?

        content_tag(:div, preview, **preview_attributes)
      end

      def render_input_wrapper
        return render_default_input_wrapper unless decorative_ends?

        content_tag(:div, class: "fp-range-input-ends") do
          safe_join([
            render_start_end,
            tag.input(**input_attributes),
            render_end_end
          ].compact)
        end
      end

      def render_default_input_wrapper
        content_tag(:div, class: "relative") do
          tag.input(**input_attributes)
        end
      end

      def render_start_end
        render_range_end(start_end_kind, start_end_icon, :start)
      end

      def render_end_end
        render_range_end(end_end_kind, end_end_icon, :end)
      end

      def render_range_end(kind, icon_name, position)
        case kind
        when :glyph
          content_tag(
            :span,
            SIZE_GLYPH,
            class: "fp-range-input-glyph fp-range-input-glyph--#{position}",
            aria: {hidden: true}
          )
        when :icon
          render FlatPack::Shared::IconComponent.new(
            name: icon_name,
            size: ((position == :start) ? :sm : :md),
            class: "fp-range-input-end-icon fp-range-input-end-icon--#{position}"
          )
        end
      end

      def container_attributes
        merge_attributes(
          data: container_data,
          class: "w-full"
        )
      end

      def container_data
        data = {controller: "flat-pack--range-input"}
        data["flat-pack--range-input-preview-selector-value"] = preview_selector if preview_selector.present?
        data
      end

      def preview_attributes
        {
          class: "fp-range-input-preview",
          style: preview_custom_properties,
          data: {"flat-pack--range-input-target": "preview"}
        }
      end

      def label_attributes
        {
          for: @id,
          class: "flex items-center justify-between mb-2 text-sm font-medium text-[var(--surface-content-color)]"
        }
      end

      def input_attributes
        attrs = {
          type: "range",
          name: @name,
          id: @id,
          value: @value,
          min: @min,
          max: @max,
          step: @step,
          disabled: @disabled,
          class: input_classes,
          style: "--range-progress: #{range_progress_percent.round(4)}%",
          data: {
            "flat-pack--range-input-target": "input",
            action: "input->flat-pack--range-input#update change->flat-pack--range-input#update"
          },
          aria: {
            label: @label || "Range input",
            valuenow: @value,
            valuemin: @min,
            valuemax: @max,
            describedby: (@help_text.present? ? help_text_id : nil)
          }
        }

        apply_default_validation(attrs, error_id: error_id, has_error: false)
      end

      def input_classes
        "fp-range-input"
      end

      def preview_custom_properties
        "--fp-range-value: #{preview_value}; --fp-range-scale: #{range_scale.round(4)}"
      end

      def preview_value
        number = Float(@value)
        (number == number.to_i) ? number.to_i : number
      rescue ArgumentError, TypeError
        @value
      end

      def range_progress_percent
        range_scale * 100.0
      end

      def range_scale
        span = @max.to_f - @min.to_f
        return 0.0 if span <= 0

        ((@value.to_f - @min.to_f) / span).clamp(0.0, 1.0)
      end

      def preview_selector
        token = @preview_target.to_s.strip
        return if token.blank?
        return token if token.match?(/\A[#.\[:]/)

        "##{token}"
      end

      def decorative_ends?
        size_variant? || zoom_variant? || @start_icon.present? || @end_icon.present?
      end

      def size_variant?
        SIZE_VARIANTS.include?(@variant)
      end

      def zoom_variant?
        @variant == :zoom
      end

      def start_end_kind
        return :icon if @start_icon.present? || zoom_variant?
        return :glyph if size_variant?

        nil
      end

      def end_end_kind
        return :icon if @end_icon.present? || zoom_variant?
        return :glyph if size_variant?

        nil
      end

      def start_end_icon
        @start_icon.presence || (zoom_variant? ? ZOOM_START_ICON : nil)
      end

      def end_end_icon
        @end_icon.presence || (zoom_variant? ? ZOOM_END_ICON : nil)
      end

      def validate_name!
        return if @name.present?
        raise ArgumentError, "name is required"
      end

      def validate_range!
        return if @min < @max
        raise ArgumentError, "min must be less than max"
      end

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
      end

      def validate_preview_target!
        return if @preview_target.nil? || @preview_target.is_a?(String)

        raise ArgumentError, "preview_target must be a String"
      end

      def error_id
        "#{@id.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_error"
      end

      def help_text_id
        "#{@id.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_help_text"
      end
    end
  end
end
