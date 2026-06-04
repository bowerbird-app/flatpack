# frozen_string_literal: true

module FlatPack
  module DateInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        min: nil,
        max: nil,
        picker: :native,
        range: false,
        range_start_name: nil,
        range_end_name: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @picker = normalize_picker(picker)
        @range = range
        @range_start_name = range_start_name
        @range_end_name = range_end_name
        @value = format_date_value(value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @min = format_date_value(min)
        @max = format_date_value(max)

        validate_name!
        validate_picker_and_range!
        resolve_initial_values(value)
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_input,
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
        return render_custom_picker if custom_picker_mode?

        tag.input(**native_input_attributes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def native_input_attributes
        attrs = {
          type: "date",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          min: @min,
          max: @max,
          class: input_classes,
          data: merged_data_attributes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def render_custom_picker
        content_tag(:div, **picker_root_attributes) do
          safe_join([
            render_picker_trigger,
            render_picker_hidden_fields,
            render_picker_panel
          ])
        end
      end

      def render_picker_trigger
        attrs = {
          type: "text",
          id: input_id,
          value: initial_display_value,
          placeholder: @placeholder || default_picker_placeholder,
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
          describedby: (@error.present? ? error_id : nil)
        }.compact

        tag.input(**attrs)
      end

      def render_picker_hidden_fields
        return tag.input(type: "hidden", name: @name, value: @single_value, data: {"flat-pack--flatpack-date-picker-target": "singleField"}) unless @range

        safe_join([
          tag.input(type: "hidden", name: resolved_range_start_name, value: @range_start_value, data: {"flat-pack--flatpack-date-picker-target": "rangeStartField"}),
          tag.input(type: "hidden", name: resolved_range_end_name, value: @range_end_value, data: {"flat-pack--flatpack-date-picker-target": "rangeEndField"})
        ])
      end

      def render_picker_panel
        content_tag(:div, **picker_panel_attributes) do
          safe_join([
            render_picker_quick_ranges,
            render_picker_calendar
          ])
        end
      end

      def render_picker_quick_ranges
        content_tag(:div, class: picker_ranges_section_classes) do
          safe_join([
            content_tag(:p, "Date Range", class: "text-xs font-semibold uppercase tracking-wide text-[var(--surface-muted-content-color)]"),
            content_tag(:div, class: "mt-2 space-y-1") do
              safe_join(quick_range_presets.map { |preset| render_quick_range_button(preset) })
            end
          ])
        end
      end

      def render_quick_range_button(preset)
        tag.button(
          preset[:label],
          type: "button",
          class: "w-full rounded-md border border-transparent px-3 py-2 text-left text-sm text-[var(--surface-content-color)] transition-colors duration-base hover:bg-[var(--surface-subtle-background-color)] focus:outline-none focus:ring-2 focus:ring-ring",
          data: {
            "flat-pack-date-picker-command": "preset",
            "flat-pack-date-picker-preset": preset[:key]
          }
        )
      end

      def render_picker_calendar
        content_tag(:div, class: picker_calendar_section_classes) do
          safe_join([
            content_tag(:div, class: "flex items-center justify-between gap-2") do
              safe_join([
                tag.button("Prev", type: "button", class: picker_nav_button_classes, data: {"flat-pack-date-picker-command": "previous-month"}),
                content_tag(:p, "", class: "text-sm font-semibold text-[var(--surface-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "monthLabel"}),
                tag.button("Next", type: "button", class: picker_nav_button_classes, data: {"flat-pack-date-picker-command": "next-month"})
              ])
            end,
            content_tag(:div, class: "mt-3 grid grid-cols-7 gap-1 text-center text-xs font-medium text-[var(--surface-muted-content-color)]") do
              safe_join(%w[Mo Tu We Th Fr Sa Su].map { |day| content_tag(:span, day) })
            end,
            content_tag(:div, "", class: "mt-2 grid grid-cols-7 justify-items-center gap-x-0 gap-y-1", data: {"flat-pack--flatpack-date-picker-target": "calendarGrid"}),
            content_tag(:p, "", class: "mt-3 text-xs text-[var(--surface-muted-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "summary"}),
            content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
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
          "flat-pack--flatpack-date-picker-range-value": @range,
          "flat-pack--flatpack-date-picker-min-value": @min,
          "flat-pack--flatpack-date-picker-max-value": @max,
          "flat-pack--flatpack-date-picker-start-value": @range_start_value,
          "flat-pack--flatpack-date-picker-end-value": @range_end_value,
          "flat-pack--flatpack-date-picker-value-value": @single_value,
          "flat-pack--flatpack-date-picker-panel-id-value": panel_id
        ).compact
      end

      def picker_panel_attributes
        {
          id: panel_id,
          class: picker_panel_classes,
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
          "w-[min(92vw,44rem)]",
          "overflow-hidden",
          "rounded-lg",
          "border",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "shadow-xl",
          "md:flex",
          "md:items-stretch"
        )
      end

      def picker_ranges_section_classes
        classes(
          "border-b",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-subtle-background-color)]",
          "p-3",
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
          "min-w-0",
          "flex-1",
          "p-3"
        )
      end

      def picker_nav_button_classes
        "rounded-md border border-[var(--surface-border-color)] px-2 py-1 text-xs text-[var(--surface-content-color)] transition-colors duration-base hover:bg-[var(--surface-subtle-background-color)] focus:outline-none focus:ring-2 focus:ring-ring"
      end

      def picker_trigger_classes
        classes(input_classes, "cursor-pointer")
      end

      def merged_data_attributes
        existing_controller = data_attributes[:controller]
        controllers = [existing_controller, "flat-pack--date-input"].compact.join(" ")

        data_attributes.merge(controller: controllers)
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
          "rounded-md",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-[var(--surface-muted-content-color)]",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent",
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
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def panel_id
        "#{input_id}_panel"
      end

      def error_id
        "#{input_id}_error"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_picker_and_range!
        unless %i[native flatpack_date_picker].include?(@picker)
          raise ArgumentError, "picker must be one of: native, flatpack_date_picker"
        end

        return unless @range && @picker != :flatpack_date_picker

        raise ArgumentError, "range mode requires picker: :flatpack_date_picker"
      end

      def normalize_picker(picker)
        (picker || :native).to_sym
      end

      def custom_picker_mode?
        @picker == :flatpack_date_picker
      end

      def resolve_initial_values(raw_value)
        if @range
          start_value, end_value = normalize_range_value(raw_value)
          @range_start_value = format_date_value(start_value)
          @range_end_value = format_date_value(end_value)
          @single_value = nil
        else
          @single_value = format_date_value(raw_value)
          @range_start_value = nil
          @range_end_value = nil
        end
      end

      def normalize_range_value(raw_value)
        case raw_value
        when Hash
          [raw_value[:start] || raw_value["start"], raw_value[:end] || raw_value["end"]]
        when Array
          [raw_value[0], raw_value[1]]
        else
          [nil, nil]
        end
      end

      def default_picker_placeholder
        @range ? "Select date range" : "Select date"
      end

      def initial_display_value
        return @single_value if @single_value.present?
        return nil unless @range
        return nil if @range_start_value.blank? || @range_end_value.blank?

        "#{@range_start_value} to #{@range_end_value}"
      end

      def quick_range_presets
        [
          {key: "today", label: "Today"},
          {key: "yesterday", label: "Yesterday"},
          {key: "last_3_days", label: "Last 3 days"},
          {key: "this_week", label: "This week"},
          {key: "last_week", label: "Last week"},
          {key: "this_month", label: "This month"},
          {key: "last_month", label: "Last month"},
          {key: "this_year", label: "This year"},
          {key: "last_year", label: "Last year"}
        ]
      end

      def resolved_range_start_name
        @range_start_name.presence || "#{@name}[start]"
      end

      def resolved_range_end_name
        @range_end_name.presence || "#{@name}[end]"
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
