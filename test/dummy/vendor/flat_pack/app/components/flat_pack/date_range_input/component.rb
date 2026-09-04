# frozen_string_literal: true

module FlatPack
  module DateRangeInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"

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

      def render_picker_trigger
        attrs = {
          type: "text",
          id: input_id,
          value: initial_display_value,
          placeholder: @placeholder || "Select date range",
          disabled: @disabled,
          required: @required,
          readonly: true,
          class: picker_trigger_classes,
          role: "button",
          data: {
            "flat-pack--flatpack-date-picker-target": "trigger",
            action: "click->flat-pack--flatpack-date-picker#toggle keydown.enter->flat-pack--flatpack-date-picker#toggle keydown.space->flat-pack--flatpack-date-picker#toggle"
          }
        }

        attrs[:aria] = {
          haspopup: "dialog",
          expanded: "false",
          controls: panel_id,
          invalid: (@error.present? ? "true" : nil),
          describedby: describedby_tokens((help_text_id if @help_text), (error_id if @error)).presence
        }.compact

        tag.input(**attrs)
      end

      def render_picker_hidden_fields
        safe_join([
          tag.input(type: "hidden", name: @start_name, value: @start_value, data: {"flat-pack--flatpack-date-picker-target": "rangeStartField"}),
          tag.input(type: "hidden", name: @end_name, value: @end_value, data: {"flat-pack--flatpack-date-picker-target": "rangeEndField"})
        ])
      end

      def render_picker_panel
        content_tag(:div, **picker_panel_attributes) do
          safe_join([
            render_picker_quick_ranges,
            render_picker_calendar,
            render_picker_actions
          ])
        end
      end

      def render_picker_quick_ranges
        content_tag(:div, class: picker_ranges_section_classes, data: {"flat-pack--flatpack-date-picker-target": "listView"}) do
          safe_join([
            content_tag(:p, "Date Range", class: "text-xs font-semibold uppercase tracking-wide text-[var(--surface-muted-content-color)]"),
            content_tag(:div, class: "mt-2 space-y-1") do
              safe_join(
                quick_range_presets.map { |preset| render_quick_range_button(preset) } +
                [render_open_calendar_button]
              )
            end
          ])
        end
      end

      def render_quick_range_button(preset)
        render(FlatPack::Button::Component.new(
          text: preset[:label],
          style: :ghost,
          size: :sm,
          type: "button",
          class: "w-full justify-start",
          data: {
            "flat-pack-date-picker-command": "preset",
            "flat-pack-date-picker-preset": preset[:key]
          }
        ))
      end

      def render_picker_calendar
        content_tag(:div, class: picker_calendar_section_classes, data: {"flat-pack--flatpack-date-picker-target": "calendarView"}) do
          safe_join([
            content_tag(:div, class: "mb-3 md:hidden") do
              render(FlatPack::Button::Component.new(
                text: "Back to Date Range",
                style: :ghost,
                size: :sm,
                type: "button",
                class: "w-full justify-start",
                data: {"flat-pack-date-picker-command": "show-ranges"}
              ))
            end,
            content_tag(:div, class: "flex items-center justify-between gap-2") do
              safe_join([
                render(FlatPack::Button::Component.new(
                  text: "Prev",
                  style: :ghost,
                  size: :sm,
                  type: "button",
                  data: {"flat-pack-date-picker-command": "previous-month"}
                )),
                content_tag(:p, "", class: "text-sm font-semibold text-[var(--surface-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "monthLabel"}),
                render(FlatPack::Button::Component.new(
                  text: "Next",
                  style: :ghost,
                  size: :sm,
                  type: "button",
                  data: {"flat-pack-date-picker-command": "next-month"}
                ))
              ])
            end,
            content_tag(:div, class: "mt-3 grid grid-cols-7 gap-1 text-center text-xs font-medium text-[var(--surface-muted-content-color)]") do
              safe_join(%w[Mo Tu We Th Fr Sa Su].map { |day| content_tag(:span, day) })
            end,
            content_tag(:div, "", class: "mt-2 grid grid-cols-7 justify-items-center gap-x-0 gap-y-1", data: {"flat-pack--flatpack-date-picker-target": "calendarGrid"}),
            content_tag(:p, "", class: "mt-3 text-xs text-[var(--surface-muted-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "summary"})
          ])
        end
      end

      def render_open_calendar_button
        render(FlatPack::Button::Component.new(
          text: "Pick in Calendar",
          style: :ghost,
          size: :sm,
          type: "button",
          class: "w-full justify-start",
          data: {"flat-pack-date-picker-command": "show-calendar"}
        ))
      end

      def render_picker_actions
        content_tag(:div, class: picker_actions_section_classes) do
          safe_join([
            render(FlatPack::Button::Component.new(
              text: "Cancel",
              style: :ghost,
              size: :sm,
              type: "button",
              data: {"flat-pack-date-picker-command": "cancel"}
            )),
            render(FlatPack::Button::Component.new(
              text: "Apply",
              style: :primary,
              size: :sm,
              type: "button",
              data: {
                "flat-pack-date-picker-command": "apply",
                action: "click->flat-pack--flatpack-date-picker#requestApply"
              }
            ))
          ])
        end
      end

      def picker_root_attributes
        {
          class: "relative",
          data: picker_data_attributes
        }
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

      def picker_panel_attributes
        {
          id: panel_id,
          class: picker_panel_classes,
          style: "display: none;",
          role: "dialog",
          tabindex: "-1",
          aria: {hidden: "true"},
          data: {"flat-pack--flatpack-date-picker-target": "panel"}
        }
      end

      def picker_panel_classes
        classes(
          "flat-pack-date-picker-panel",
          "hidden",
          "fixed",
          "z-50",
          "inset-0",
          "h-dvh",
          "w-screen",
          "max-w-none",
          "overflow-y-auto",
          "bg-[var(--surface-background-color)]",
          "md:w-auto",
          "md:h-auto",
          "md:inset-auto",
          "md:max-w-none",
          "md:overflow-hidden",
          "md:rounded-[var(--radius-lg)]",
          "md:border",
          "md:border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "shadow-xl",
          "flex",
          "flex-col",
          "md:flex-row",
          "md:flex-wrap",
          "md:items-stretch"
        )
      end

      def picker_ranges_section_classes
        classes(
          "flat-pack-date-picker-list-view",
          "border-b",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-subtle-background-color)]",
          "p-3",
          "w-full",
          "overflow-y-auto",
          "md:max-w-[150px]",
          "md:sticky",
          "md:top-0",
          "md:w-64",
          "md:self-start",
          "md:border-b-0",
          "md:border-r"
        )
      end

      def picker_calendar_section_classes
        classes(
          "flat-pack-date-picker-calendar-view",
          "hidden",
          "md:grid",
          "min-w-0",
          "flex-1",
          "p-3"
        )
      end

      def picker_actions_section_classes
        classes(
          "mt-auto",
          "sticky",
          "bottom-0",
          "z-10",
          "flex",
          "items-center",
          "justify-end",
          "gap-2",
          "border-t",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "p-3",
          "md:static",
          "md:w-full",
          "md:basis-full"
        )
      end

      def picker_trigger_classes
        classes(input_classes, "cursor-pointer")
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
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
          "rounded-[var(--radius-md)]",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-[var(--surface-muted-content-color)]",
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-warning)]"
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@start_name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def panel_id
        "#{input_id}_panel"
      end

      def error_id
        "#{input_id}_error"
      end

      def help_text_id
        "#{input_id}_help_text"
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

      def quick_range_presets
        [
          {key: "today", label: "Today"},
          {key: "yesterday", label: "Yesterday"},
          {key: "last_3_days", label: "Last 3 days"},
          {key: "this_week", label: "This week"},
          {key: "last_week", label: "Last week"},
          {key: "last_4_weeks", label: "Last 4 weeks"},
          {key: "this_month", label: "This month"},
          {key: "last_month", label: "Last month"},
          {key: "this_year", label: "This year"},
          {key: "last_year", label: "Last year"}
        ]
      end

      # Convert Date objects to YYYY-MM-DD format string
      # Accepts Date, Time, DateTime objects or strings
      def format_date_value(value)
        return nil if value.nil?
        return value if value.is_a?(String)

        if value.respond_to?(:strftime)
          value.strftime("%Y-%m-%d")
        else
          value.to_s
        end
      end
    end
  end
end
