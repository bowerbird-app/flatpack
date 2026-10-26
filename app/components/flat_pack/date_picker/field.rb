# frozen_string_literal: true

module FlatPack
  module DatePicker
    # Shared field helpers for DateInput and DateRangeInput.
    # quick_range_presets stays an instance method so a prepend on
    # DateRangeInput (Recording Studio sitemaps adds last_30_days) still runs.
    module Field
      private

      def render_picker_trigger
        attrs = {
          type: "text",
          id: input_id,
          value: initial_display_value,
          placeholder: @placeholder || picker_placeholder,
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

      def render_picker_panel
        render(FlatPack::DatePicker::Panel.new(
          panel_id: panel_id,
          presets: quick_range_presets,
          range: range_picker?
        ))
      end

      def picker_root_attributes
        {
          class: "relative",
          data: picker_data_attributes
        }
      end

      def picker_trigger_classes
        classes(input_classes, "cursor-pointer")
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
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

      def quick_range_presets
        %w[
          today yesterday last_3_days this_week last_week last_4_weeks
          this_month last_month this_year last_year
        ].map { |key| {key: key, label: fp_t("date.#{key}")} }
      end

      # Convert Date objects to YYYY-MM-DD format string.
      # Accepts Date, Time, DateTime objects or strings.
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
