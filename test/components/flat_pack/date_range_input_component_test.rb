# frozen_string_literal: true

require "test_helper"

module FlatPack
  module DateRangeInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_hidden_range_inputs_with_required_names
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date"
        ))

        assert_selector "input[type='hidden'][name='start_date']", visible: :all
        assert_selector "input[type='hidden'][name='end_date']", visible: :all
        assert_selector "input[type='text'][readonly][role='button'][placeholder='Select date range']"
      end

      def test_renders_with_start_and_end_values
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          start_value: "2026-05-02",
          end_value: "2026-05-30"
        ))

        assert_selector "input[type='hidden'][name='start_date'][value='2026-05-02']", visible: :all
        assert_selector "input[type='hidden'][name='end_date'][value='2026-05-30']", visible: :all
        assert_selector "input[type='text'][value='2026-05-02 to 2026-05-30']"
      end

      def test_renders_preset_label_when_values_match_today_preset
        today = Date.current.iso8601

        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          start_value: today,
          end_value: today
        ))

        assert_selector "input[type='text'][value='Today']"
        assert_selector "div[data-flat-pack--flatpack-date-picker-preset-key-value='today']", visible: :all
      end

      def test_exposes_preset_label_map_for_stimulus
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date"
        ))

        labels_payload = page.first("div[data-flat-pack--flatpack-date-picker-preset-labels-value]", visible: :all)["data-flat-pack--flatpack-date-picker-preset-labels-value"]
        assert_includes labels_payload, "last_week"
        assert_includes labels_payload, "Last week"
        assert_includes labels_payload, "last_4_weeks"
        assert_includes labels_payload, "Last 4 weeks"
      end

      def test_renders_last_4_weeks_between_last_week_and_this_month
        render_inline(Component.new(start_name: "period_start", end_name: "period_end"))

        preset_labels = page.all("button[data-flat-pack-date-picker-command='preset']", visible: :all).map { |button| button.text.strip }
        assert_equal ["Last week", "Last 4 weeks", "This month"], preset_labels.slice(4, 3)
      end

      def test_formats_date_objects
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          start_value: Date.new(2026, 5, 1),
          end_value: Date.new(2026, 5, 31)
        ))

        assert_selector "input[type='hidden'][name='start_date'][value='2026-05-01']", visible: :all
        assert_selector "input[type='hidden'][name='end_date'][value='2026-05-31']", visible: :all
      end

      def test_renders_with_label
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          label: "Date Range"
        ))

        assert_selector "label", text: "Date Range"
      end

      def test_renders_help_text
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          id: "period",
          help_text: "Select the inclusive reporting period."
        ))

        assert_selector "p#period_help_text", text: "Select the inclusive reporting period."
        assert_selector "input[type='text'][aria-describedby='period_help_text']"
      end

      def test_renders_with_error
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          error: "Date range is required"
        ))

        assert_selector "p", text: "Date range is required"
        assert_selector "input[aria-invalid='true']"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          class: "custom-input-class"
        ))

        assert_selector "input.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          data: {controller: "custom"}
        ))

        assert_selector "div[data-controller~='custom']"
        assert_selector "div[data-controller~='flat-pack--flatpack-date-picker']"
      end

      def test_renders_mobile_list_and_calendar_targets
        render_inline(Component.new(start_name: "period_start", end_name: "period_end"))

        assert_selector "[data-flat-pack--flatpack-date-picker-target='listView'].flat-pack-date-picker-list-view", visible: :all
        assert_selector "[data-flat-pack--flatpack-date-picker-target='calendarView'].flat-pack-date-picker-calendar-view.hidden.md\\:grid", visible: :all
      end

      def test_renders_pick_in_calendar_as_last_list_action
        render_inline(Component.new(start_name: "period_start", end_name: "period_end"))

        assert_selector "button[data-flat-pack-date-picker-command='show-calendar']", text: "Pick in Calendar", visible: :all
        assert_selector "button[data-flat-pack-date-picker-command='show-ranges']", text: "Back to Date Range", visible: :all
      end

      def test_renders_shared_cancel_and_apply_actions
        render_inline(Component.new(start_name: "period_start", end_name: "period_end"))

        assert_selector "button[data-flat-pack-date-picker-command='cancel']", text: "Cancel", visible: :all
        assert_selector "button[data-flat-pack-date-picker-command='apply']", text: "Apply", visible: :all
      end

      def test_renders_mobile_fullscreen_panel_classes
        render_inline(Component.new(start_name: "period_start", end_name: "period_end"))

        assert_selector "##{css_escape(panel_dom_id)}.inset-0.h-dvh.w-screen.md\\:inset-auto.md\\:w-auto.md\\:h-auto", visible: :all
      end

      def test_raises_error_without_start_name
        assert_raises(ArgumentError) do
          Component.new(start_name: nil, end_name: "end_date")
        end
      end

      def test_raises_error_without_end_name
        assert_raises(ArgumentError) do
          Component.new(start_name: "start_date", end_name: "")
        end
      end

      def test_sanitizes_dangerous_onclick_attribute
        render_inline(Component.new(
          start_name: "start_date",
          end_name: "end_date",
          onclick: "alert('xss')"
        ))

        refute_selector "input[onclick]"
      end

      private

      def panel_dom_id
        page.first("[data-flat-pack--flatpack-date-picker-target='panel']", visible: :all)[:id]
      end

      def css_escape(identifier)
        identifier.gsub(".", "\\\\.")
      end
    end
  end
end
