# frozen_string_literal: true

require "test_helper"

# Byte-for-byte HTML for DateInput and DateRangeInput.
#
# Fixtures were rendered from tag v0.1.311
# (c289e1ee98b96005e2d2d587aa87f17b4bfb6f99) in a worktree of that tag,
# before the shared DatePicker panel extraction. This file only compares.
# It does not rewrite fixtures.
module FlatPack
  module DateRangePresetProbe
    def quick_range_presets
      [{key: "last_30_days", label: "Last 30 days"}] + super
    end

    def preset_range_for(key)
      if key.to_s == "last_30_days"
        today = Date.current
        {start: (today - 29).iso8601, end: today.iso8601}
      else
        super
      end
    end
  end

  class DateRangePresetProbeComponent < DateRangeInput::Component
    prepend DateRangePresetProbe
  end

  class DatePickerRenderCharacterizationTest < ViewComponent::TestCase
    FROZEN_AT = Time.utc(2026, 5, 15, 12, 0, 0)
    FIXTURE_DIR = Rails.root.join("../fixtures/files/date_picker_characterization")

    setup do
      travel_to FROZEN_AT
    end

    teardown do
      travel_back
    end

    def test_rendered_html_matches_captured_fixtures
      cases.each do |name, component|
        render_inline(component)
        actual = rendered_content.to_s
        assert_predicate actual, :present?, name
        path = fixture_path(name)
        flunk "missing fixture #{name}" unless File.exist?(path)
        expected = File.binread(path)
        next if expected == actual

        index = first_difference(expected, actual)
        flunk "#{name} HTML differs at byte #{index} (expected #{expected.bytesize}, actual #{actual.bytesize})"
      end
    end

    private

    def cases
      date_input_cases + date_range_cases
    end

    def date_input_cases
      [
        ["date_input/native_default", DateInput::Component.new(id: "birth", name: "birth_date")],
        ["date_input/native_value_string", DateInput::Component.new(id: "birth", name: "birth_date", value: "2024-01-15")],
        ["date_input/native_value_date", DateInput::Component.new(id: "birth", name: "birth_date", value: Date.new(2024, 1, 15))],
        ["date_input/native_value_time", DateInput::Component.new(id: "birth", name: "birth_date", value: Time.utc(2024, 1, 15, 10, 30, 0))],
        ["date_input/native_value_nil", DateInput::Component.new(id: "birth", name: "birth_date", value: nil)],
        ["date_input/native_placeholder_label_help", DateInput::Component.new(
          id: "birth",
          name: "birth_date",
          placeholder: "Select date",
          label: "Birth Date",
          help_text: "Use the date on your government ID."
        )],
        ["date_input/native_disabled_required", DateInput::Component.new(id: "birth", name: "birth_date", disabled: true, required: true)],
        ["date_input/native_error", DateInput::Component.new(id: "birth", name: "birth_date", error: "Date is required")],
        ["date_input/native_error_and_help", DateInput::Component.new(
          id: "birth",
          name: "birth_date",
          error: "Date is required",
          help_text: "Use the date on your government ID."
        )],
        ["date_input/native_min_max_strings", DateInput::Component.new(id: "birth", name: "birth_date", min: "2024-01-01", max: "2024-12-31")],
        ["date_input/native_min_max_dates", DateInput::Component.new(
          id: "birth",
          name: "birth_date",
          min: Date.new(2024, 1, 1),
          max: Date.new(2024, 12, 31)
        )],
        ["date_input/native_class_data_aria", DateInput::Component.new(
          id: "birth",
          name: "birth_date",
          class: "custom-input-class",
          data: {controller: "custom", action: "change->custom#go", testid: "date-input"},
          aria: {label: "Custom date"}
        )],
        ["date_input/native_bracket_name", DateInput::Component.new(id: "article_published_on", name: "article[published_on]", value: Date.new(2026, 5, 2))],
        ["date_input/native_chrome_cell", DateInput::Component.new(id: "birth", name: "birth_date", chrome: :cell, value: "2024-01-15", error: "Invalid")],
        ["date_input/native_explicit_picker", DateInput::Component.new(id: "birth", name: "birth_date", picker: :native)],
        ["date_input/native_picker_string", DateInput::Component.new(id: "birth", name: "birth_date", picker: "native")],
        ["date_input/native_ignored_range_kwargs", DateInput::Component.new(
          id: "logs",
          name: "logs_date_range",
          range: true,
          range_start_name: "start_date",
          range_end_name: "end_date",
          value: {start: Date.new(2026, 5, 1), end: Date.new(2026, 5, 15)},
          label: "Date Range",
          class: "w-[220px]"
        )],
        ["date_input/native_onclick_stripped", DateInput::Component.new(id: "birth", name: "birth_date", onclick: "alert('xss')")],
        ["date_input/custom_default", DateInput::Component.new(id: "anchor", name: "billing_anchor_date", picker: :flatpack_date_picker)],
        ["date_input/custom_value", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          value: "2026-05-31",
          placeholder: "Pick a day",
          label: "Billing Anchor Date",
          help_text: "Pick a date from the calendar.",
          min: "2026-05-01",
          max: "2026-06-30"
        )],
        ["date_input/custom_value_date", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: "flatpack_date_picker",
          value: Date.new(2026, 5, 15),
          min: Date.new(2026, 1, 1),
          max: Time.utc(2026, 12, 31, 23, 0, 0)
        )],
        ["date_input/custom_min_max", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          min: "2026-05-01",
          max: "2026-06-30"
        )],
        ["date_input/custom_min_max_dates", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          min: Date.new(2026, 1, 1),
          max: Date.new(2026, 12, 31)
        )],
        ["date_input/custom_label", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          label: "Billing Anchor Date"
        )],
        ["date_input/custom_help_text", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          help_text: "Pick a date from the calendar."
        )],
        ["date_input/custom_placeholder", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          placeholder: "Pick a day"
        )],
        ["date_input/custom_disabled_required_error", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          disabled: true,
          required: true,
          error: "Date is required",
          label: "Billing Anchor Date"
        )],
        ["date_input/custom_class_data_aria", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          class: "custom-input-class",
          data: {controller: "custom", testid: "date-input"},
          aria: {label: "Custom date"}
        )],
        ["date_input/custom_chrome_cell", DateInput::Component.new(
          id: "anchor",
          name: "billing_anchor_date",
          picker: :flatpack_date_picker,
          chrome: :cell,
          value: "2026-05-15",
          error: "Invalid"
        )],
        ["date_input/custom_api_range_kwargs_ignored", DateInput::Component.new(
          id: "logs",
          name: "logs_date_range",
          picker: :flatpack_date_picker,
          range: true,
          range_start_name: "start_date",
          range_end_name: "end_date",
          value: {start: Date.new(2026, 5, 1), end: Date.new(2026, 5, 15)},
          label: "Date Range",
          class: "w-[220px]"
        )]
      ]
    end

    def date_range_cases
      [
        ["date_range/default", DateRangeInput::Component.new(id: "period", start_name: "start_date", end_name: "end_date")],
        ["date_range/values_string", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-02",
          end_value: "2026-05-30"
        )],
        ["date_range/values_date", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: Date.new(2026, 5, 1),
          end_value: Date.new(2026, 5, 31)
        )],
        ["date_range/values_time", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: Time.utc(2026, 5, 1, 8, 0, 0),
          end_value: Time.utc(2026, 5, 31, 18, 0, 0)
        )],
        ["date_range/preset_today", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-15",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_yesterday", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: Date.new(2026, 5, 14),
          end_value: Date.new(2026, 5, 14)
        )],
        ["date_range/preset_this_month", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-01",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_last_week", DateRangeInput::Component.new(
          id: "period",
          start_name: "reporting_period_start",
          end_name: "reporting_period_end",
          start_value: "2026-05-04",
          end_value: "2026-05-10"
        )],
        ["date_range/preset_last_3_days", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-13",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_this_week", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-11",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_last_4_weeks", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-04-18",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_last_month", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-04-01",
          end_value: "2026-04-30"
        )],
        ["date_range/preset_this_year", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-01-01",
          end_value: "2026-05-15"
        )],
        ["date_range/preset_last_year", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2025-01-01",
          end_value: "2025-12-31"
        )],
        ["date_range/prepend_last_30_days", DateRangePresetProbeComponent.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-04-16",
          end_value: "2026-05-15"
        )],
        ["date_range/start_only", DateRangeInput::Component.new(id: "period", start_name: "start_date", end_name: "end_date", start_value: "2026-05-02")],
        ["date_range/end_only", DateRangeInput::Component.new(id: "period", start_name: "start_date", end_name: "end_date", end_value: "2026-05-30")],
        ["date_range/label_placeholder_help", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          label: "Reporting Period",
          placeholder: "Choose comparison window",
          help_text: "Select the inclusive reporting period."
        )],
        ["date_range/label_nil", DateRangeInput::Component.new(id: "period", start_name: "start_date", end_name: "end_date", label: nil)],
        ["date_range/disabled_required_error", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          disabled: true,
          required: true,
          error: "Date range is required",
          label: "Reporting Period"
        )],
        ["date_range/min_max", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          min: Date.new(2025, 5, 15),
          max: "2026-05-15",
          start_value: "2026-04-16",
          end_value: "2026-05-15"
        )],
        ["date_range/class_data_aria", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          class: "custom-input-class",
          data: {controller: "custom", action: "change->custom#go", testid: "date-range-input"},
          aria: {label: "Custom range"}
        )],
        ["date_range/bracket_names", DateRangeInput::Component.new(
          id: "filter_built_at",
          start_name: "filters[built_at_start]",
          end_name: "filters[built_at_end]",
          start_value: "2026-05-01",
          end_value: "2026-05-15"
        )],
        ["date_range/onclick_stripped", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          onclick: "alert('xss')"
        )],
        ["date_range/error_and_help", DateRangeInput::Component.new(
          id: "period",
          start_name: "start_date",
          end_name: "end_date",
          error: "Date range is required",
          help_text: "Select the inclusive reporting period."
        )]
      ]
    end

    def fixture_path(name)
      FIXTURE_DIR.join("#{name}.html")
    end

    def first_difference(expected, actual)
      limit = [expected.bytesize, actual.bytesize].min
      limit.times.find { |index| expected.getbyte(index) != actual.getbyte(index) } || limit
    end
  end
end
