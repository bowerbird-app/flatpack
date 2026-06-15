# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chart
    class DefaultFilterComponentTest < ViewComponent::TestCase
      def test_renders_with_default_field_names
        render_inline(DefaultFilterComponent.new(
          status_lists: %w[active inactive],
          minimized: false
        ))

        assert_selector "input[type='hidden'][name='start_date']", visible: :all
        assert_selector "input[type='hidden'][name='end_date']", visible: :all
        assert_includes rendered_content, "w-[220px]"
        assert_selector "label", text: "Date Range"
        assert_selector "select[name='status']"
        assert_selector "label", text: "Status"
        assert_selector "select[name='status'] option[selected][value='']", text: "All"
      end

      def test_hides_labels_when_hide_labels_is_true
        render_inline(DefaultFilterComponent.new(
          status_lists: %w[active inactive],
          hide_labels: true,
          minimized: false
        ))

        assert_selector "input[type='hidden'][name='start_date']", visible: :all
        assert_selector "input[type='hidden'][name='end_date']", visible: :all
        assert_selector "select[name='status']"
        assert_no_selector "label", text: "Date Range"
        assert_no_selector "label", text: "Status"
      end

      def test_renders_with_custom_field_names
        render_inline(DefaultFilterComponent.new(
          start_date_name: "filters[started_on]",
          end_date_name: "filters[ended_on]",
          status_name: "filters[state]",
          status_lists: %w[active inactive],
          minimized: false
        ))

        assert_selector "input[type='hidden'][name='filters[started_on]']", visible: :all
        assert_selector "input[type='hidden'][name='filters[ended_on]']", visible: :all
        assert_selector "select[name='filters[state]']"
      end

      def test_applies_start_end_and_status_values
        render_inline(DefaultFilterComponent.new(
          start_date_value: "2026-06-01",
          end_date_value: "2026-06-30",
          status: "inactive",
          status_lists: ["active", "inactive"],
          minimized: false
        ))

        assert_selector "input[type='hidden'][name='start_date'][value='2026-06-01']", visible: :all
        assert_selector "input[type='hidden'][name='end_date'][value='2026-06-30']", visible: :all
        assert_selector "select[name='status'] option[selected][value='inactive']", text: "inactive"
      end

      def test_accepts_hash_option_shape_for_status_lists
        render_inline(DefaultFilterComponent.new(
          status: "closed",
          minimized: false,
          status_lists: [
            {label: "Open", value: "open"},
            {label: "Closed", value: "closed"}
          ]
        ))

        assert_selector "select[name='status'] option[value='open']", text: "Open"
        assert_selector "select[name='status'] option[selected][value='closed']", text: "Closed"
      end

      def test_hides_status_dropdown_when_status_name_is_nil
        render_inline(DefaultFilterComponent.new(
          status_name: nil,
          status_lists: ["active", "inactive"],
          minimized: false
        ))

        assert_selector "input[type='hidden'][name='start_date']", visible: :all
        assert_selector "input[type='hidden'][name='end_date']", visible: :all
        assert_no_selector "select"
      end

      def test_raises_for_invalid_status_lists
        assert_raises(ArgumentError) do
          DefaultFilterComponent.new(status_lists: nil)
        end
      end

      def test_is_minimized_by_default
        render_inline(DefaultFilterComponent.new(status_lists: ["active", "inactive"]))

        assert_selector "button", text: "Filter"
        assert_selector "div#chart-default-filter-modal"
        assert_selector "div.hidden.md\\:block form"
      end

      def test_supports_minimized_mode
        render_inline(DefaultFilterComponent.new(
          status_lists: ["active", "inactive"],
          status: "active",
          minimized: true,
          minimized_options: {
            id: "chart-default-filter",
            form_url: "/demo/charts/default_filter",
            turbo_frame: "chart-default-filter-frame",
            active_count: 1,
            reset_url: "/demo/charts/default_filter"
          }
        ))

        assert_selector "button span", text: "Filter"
        assert_selector "button span.rounded-full", text: "1"
        assert_selector "div#chart-default-filter-modal"
        assert_selector "div.hidden.md\\:block form[data-turbo-frame='chart-default-filter-frame']"
      end

      def test_supports_minimized_mode_without_explicit_form_url_or_turbo_frame
        render_inline(DefaultFilterComponent.new(
          status_lists: ["active", "inactive"],
          minimized: true,
          minimized_options: {id: "chart-default-filter"}
        ))

        assert_selector "button", text: "Filter"
        assert_selector "div#chart-default-filter-modal"
      end
    end
  end
end
