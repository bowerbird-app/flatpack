# frozen_string_literal: true

module FlatPack
  module DateRangeInput
    class Component < FlatPack::BaseComponent
      include FlatPack::DatePicker::Field

      DEFAULT_PRESET_KEYS = %i[
        today yesterday last_3_days this_week last_week last_4_weeks
        this_month last_month this_year last_year
      ].freeze

      NAMED_PRESET_KEYS = %i[
        today yesterday last_3_days this_week last_week last_4_weeks last_30_days
        this_month last_month this_year last_year
      ].freeze

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
        presets: nil,
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
        @preset_entries = presets

        validate_names!
        resolved_presets unless @preset_entries.nil?
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
          "flat-pack--flatpack-date-picker-preset-ranges-value": custom_preset_ranges_value,
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

      def quick_range_presets
        return super if @preset_entries.nil?

        resolved_presets.map { |preset| {key: preset[:key], label: preset[:label]} }
      end

      def custom_preset_ranges_value
        return if @preset_entries.nil?

        ranges = resolved_presets.each_with_object({}) do |preset, acc|
          next if preset[:start].blank? || preset[:end].blank?

          acc[preset[:key]] = {start: preset[:start], end: preset[:end]}
        end

        ranges.presence
      end

      def resolved_presets
        @resolved_presets ||= Array(@preset_entries).map { |entry| resolve_preset_entry(entry) }
      end

      def resolve_preset_entry(entry)
        case entry
        when String, Symbol
          named_preset(entry)
        when Hash
          resolve_hash_preset(entry)
        else
          raise ArgumentError, "presets entries must be a name or a label and range"
        end
      end

      def resolve_hash_preset(entry)
        entry = entry.to_h.symbolize_keys
        has_days = !entry[:days].nil?
        has_start = !entry[:start].nil?
        has_end = !entry[:end].nil?

        if has_days && (has_start || has_end)
          raise ArgumentError, "preset needs days: or start: and end:, not both"
        end

        if !has_days && !has_start && !has_end
          raise ArgumentError, "preset needs days: or start: and end:" if entry[:key].blank?

          named = named_preset(entry[:key])
          named[:label] = entry[:label].to_s if entry[:label].present?
          return named
        end

        raise ArgumentError, "preset label is required" if entry[:label].blank?
        raise ArgumentError, "preset needs days: or start: and end:" if has_start != has_end

        key = (entry[:key].presence || entry[:label].to_s.parameterize(separator: "_")).to_s
        raise ArgumentError, "preset key is required" if key.blank?

        range = if has_days
          inclusive_days_range(entry[:days])
        else
          {start: format_date_value(entry[:start]), end: format_date_value(entry[:end])}
        end

        {key: key, label: entry[:label].to_s, start: range[:start], end: range[:end]}
      end

      def named_preset(name)
        key = name.to_s
        unless NAMED_PRESET_KEYS.map(&:to_s).include?(key)
          raise ArgumentError, "unknown date range preset #{key.inspect}"
        end

        {key: key, label: fp_t("date.#{key}")}
      end

      def inclusive_days_range(days)
        count = Integer(days)
        raise ArgumentError, "preset days must be greater than 0" if count < 1

        today = Date.current
        {start: (today - (count - 1).days).iso8601, end: today.iso8601}
      rescue ArgumentError, TypeError
        raise ArgumentError, "preset days must be greater than 0"
      end

      def preset_range_for(key)
        key = key.to_s
        resolved = resolved_presets.find { |candidate| candidate[:key] == key }
        if resolved && resolved[:start].present? && resolved[:end].present?
          return {start: resolved[:start], end: resolved[:end]}
        end

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
        when "last_30_days"
          {start: (today - 29.days).iso8601, end: today.iso8601}
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
