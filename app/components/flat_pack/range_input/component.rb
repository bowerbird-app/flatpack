# frozen_string_literal: true

module FlatPack
  module RangeInput
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[default size text_size zoom].freeze
      SIZE_VARIANTS = %i[size text_size].freeze
      SIZE_GLYPH = "A"
      ZOOM_START_ICON = "magnifying-glass-minus"
      ZOOM_END_ICON = "magnifying-glass-plus"
      MAX_TICKS = 24

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
        ticks: nil,
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
        @ticks = ticks

        validate_name!
        validate_range!
        validate_step!
        validate_variant!
        validate_preview_target!
        validate_ticks!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_label,
            render_input_wrapper,
            render_preview,
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
            render_track,
            render_end_end
          ].compact)
        end
      end

      def render_default_input_wrapper
        if draw_ticks?
          render_track
        else
          content_tag(:div, class: "relative") do
            tag.input(**input_attributes)
          end
        end
      end

      def render_track
        content_tag(:div, class: "fp-range-input-track") do
          safe_join([
            tag.input(**input_attributes),
            render_ticks
          ].compact)
        end
      end

      def render_ticks
        return unless draw_ticks?

        content_tag(:div, class: "fp-range-input-ticks", aria: {hidden: true}) do
          safe_join(Array.new(tick_count) { content_tag(:span, "", class: "fp-range-input-tick") })
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
        "--fp-range-value: #{preview_value}; --fp-range-scale: #{range_scale.round(4)}; --fp-range-max: #{preview_number(@max)}"
      end

      def preview_value
        preview_number(@value)
      end

      def preview_number(raw)
        number = Float(raw)
        (number == number.to_i) ? number.to_i : number
      rescue ArgumentError, TypeError
        raw
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

      def draw_ticks?
        ticks_enabled? && tick_count.between?(2, MAX_TICKS)
      end

      def ticks_enabled?
        case @ticks
        when true then true
        when false then false
        else
          size_variant? || zoom_variant?
        end
      end

      def tick_count
        span = @max.to_f - @min.to_f
        step = @step.to_f
        return 0 if step <= 0

        ((span / step).round + 1)
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

      def validate_step!
        return if @step.to_f.positive?

        raise ArgumentError, "step must be greater than 0"
      end

      def validate_ticks!
        return if @ticks.nil? || @ticks == true || @ticks == false

        raise ArgumentError, "ticks must be true or false"
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
