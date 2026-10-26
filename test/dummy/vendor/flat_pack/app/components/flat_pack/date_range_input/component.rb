# frozen_string_literal: true

module FlatPack
  module DateRangeInput
    class Component < FlatPack::BaseComponent
      include FlatPack::DatePicker::Field

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"

      def initialize(
        start_name:,
        end_name:,
        start_value: nil,
        end_value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        help_text: nil,
        min: nil,
        max: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @start_name = start_name
        @end_name = end_name
        @start_value = format_date_value(start_value)
        @end_value = format_date_value(end_value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @min = format_date_value(min)
        @max = format_date_value(max)

        validate_names!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_input,
            render_help_text,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_input
        content_tag(:div, **picker_root_attributes) do
          safe_join([
            render_picker_trigger,
            render_picker_hidden_fields,
            render_picker_panel
          ])
        end
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def render_picker_hidden_fields
        safe_join([
          tag.input(type: "hidden", name: @start_name, value: @start_value, data: {"flat-pack--flatpack-date-picker-target": "rangeStartField"}),
          tag.input(type: "hidden", name: @end_name, value: @end_value, data: {"flat-pack--flatpack-date-picker-target": "rangeEndField"})
        ])
      end

      def picker_data_attributes
        existing_controller = data_attributes[:controller]
        controllers = [existing_controller, "flat-pack--flatpack-date-picker"].compact.join(" ")

        data_attributes.merge(
          controller: controllers,
          "flat-pack--flatpack-date-picker-range-value": true,
          "flat-pack--flatpack-date-picker-min-value": @min,
          "flat-pack--flatpack-date-picker-max-value": @max,
          "flat-pack--flatpack-date-picker-start-value": @start_value,
          "flat-pack--flatpack-date-picker-end-value": @end_value,
          "flat-pack--flatpack-date-picker-preset-labels-value": quick_range_presets.index_by { |preset| preset[:key] }.transform_values { |preset| preset[:label] },
          "flat-pack--flatpack-date-picker-preset-key-value": initial_preset_key,
          "flat-pack--flatpack-date-picker-panel-id-value": panel_id
        ).compact
      end

      def picker_placeholder
        fp_t("date.select_range")
      end

      def range_picker?
        true
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--surface-content-color)] mb-1.5"
        )
      end

      def input_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "rounded-[var(--form-control-radius)]",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding-x)] py-[var(--form-control-padding-y)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-[var(--surface-muted-content-color)]",
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-error)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-error)]"
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@start_name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def validate_names!
        raise ArgumentError, "start_name is required" if @start_name.nil? || @start_name.to_s.strip.empty?
        raise ArgumentError, "end_name is required" if @end_name.nil? || @end_name.to_s.strip.empty?
      end

      def initial_display_value
        return nil if @start_value.blank? || @end_value.blank?

        preset = quick_range_presets.find { |candidate| candidate[:key] == initial_preset_key }
        return preset[:label] if preset

        "#{@start_value} to #{@end_value}"
      end

      def initial_preset_key
        return nil if @start_value.blank? || @end_value.blank?

        quick_range_presets.find do |preset|
          range = preset_range_for(preset[:key])
          range[:start] == @start_value && range[:end] == @end_value
        end&.dig(:key)
      end

      def preset_range_for(key)
        today = Date.current

        case key
        when "today"
          {start: today.iso8601, end: today.iso8601}
        when "yesterday"
          yesterday = (today - 1.day)
          {start: yesterday.iso8601, end: yesterday.iso8601}
        when "last_3_days"
          {start: (today - 2.days).iso8601, end: today.iso8601}
        when "this_week"
          week_start = start_of_week(today)
          {start: week_start.iso8601, end: today.iso8601}
        when "last_week"
          this_week_start = start_of_week(today)
          week_end = this_week_start - 1.day
          week_start = start_of_week(week_end)
          {start: week_start.iso8601, end: week_end.iso8601}
        when "last_4_weeks"
          {start: (today - 27.days).iso8601, end: today.iso8601}
        when "this_month"
          month_start = Date.new(today.year, today.month, 1)
          {start: month_start.iso8601, end: today.iso8601}
        when "last_month"
          current_month_start = Date.new(today.year, today.month, 1)
          last_month_start = current_month_start << 1
          {start: last_month_start.iso8601, end: (current_month_start - 1.day).iso8601}
        when "this_year"
          year_start = Date.new(today.year, 1, 1)
          {start: year_start.iso8601, end: today.iso8601}
        when "last_year"
          last_year = today.year - 1
          {start: Date.new(last_year, 1, 1).iso8601, end: Date.new(last_year, 12, 31).iso8601}
        else
          {start: nil, end: nil}
        end
      end

      def start_of_week(date)
        date - ((date.wday + 6) % 7)
      end
    end
  end
end
