# frozen_string_literal: true

module FlatPack
  module DateInput
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles

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
        help_text: nil,
        min: nil,
        max: nil,
        picker: :native,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @picker = normalize_picker(picker)
        @value = format_date_value(value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @min = format_date_value(min)
        @max = format_date_value(max)

        validate_name!
        validate_picker!
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: input_id,
          class: wrapper_classes
        ) do |field|
          field.with_control { render_input }
        end
      end

      private

      def render_input
        return render_custom_picker if custom_picker_mode?

        tag.input(**native_input_attributes)
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

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

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
          describedby: describedby_tokens((help_text_id if @help_text), (error_id if @error)).presence
        }.compact

        tag.input(**attrs)
      end

      def render_picker_hidden_fields
        tag.input(type: "hidden", name: @name, value: @value, data: {"flat-pack--flatpack-date-picker-target": "singleField"})
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
            content_tag(:p, "Quick Select", class: "text-xs font-semibold uppercase tracking-wide text-[var(--surface-muted-content-color)]"),
            content_tag(:div, class: "mt-2 space-y-1") do
              safe_join(quick_range_presets.map { |preset| render_quick_range_button(preset) })
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
        content_tag(:div, class: picker_calendar_section_classes) do
          safe_join([
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
          "flat-pack--flatpack-date-picker-range-value": false,
          "flat-pack--flatpack-date-picker-min-value": @min,
          "flat-pack--flatpack-date-picker-max-value": @max,
          "flat-pack--flatpack-date-picker-value-value": @value,
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
          "w-auto",
          "overflow-hidden",
          "rounded-[var(--radius-lg)]",
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
          "max-w-[150px]",
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
          "max-w-[320px]",
          "p-3"
        )
      end

      def picker_nav_button_classes
        "rounded-[var(--radius-md)] border border-[var(--surface-border-color)] px-2 py-1 text-xs text-[var(--surface-content-color)] transition-colors duration-base hover:bg-[var(--surface-subtle-background-color)] focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring"
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

      def input_classes
        form_control_classes(error: @error, custom_class: @custom_class)
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

      def help_text_id
        "#{input_id}_help_text"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_picker!
        unless %i[native flatpack_date_picker].include?(@picker)
          raise ArgumentError, "picker must be one of: native, flatpack_date_picker"
        end
      end

      def normalize_picker(picker)
        (picker || :native).to_sym
      end

      def custom_picker_mode?
        @picker == :flatpack_date_picker
      end

      def default_picker_placeholder
        "Select date"
      end

      def initial_display_value
        @value
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
