# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chart
    class DefaultFilterComponentTest < ViewComponent::TestCase
      def test_renders_with_default_field_names
        render_inline(DefaultFilterComponent.new(status_lists: %w[active inactive]))

        assert_selector "input[type='hidden'][name='start_date']", visible: :all
        assert_selector "input[type='hidden'][name='end_date']", visible: :all
        assert_includes rendered_content, "w-[220px]"
        assert_selector "select[name='status']"
        assert_selector "select[name='status'] option[selected][value='']", text: "All"
      end

      def test_renders_with_custom_field_names
        render_inline(DefaultFilterComponent.new(
          start_date_name: "filters[started_on]",
          end_date_name: "filters[ended_on]",
          status_name: "filters[state]",
          status_lists: %w[active inactive]
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
          status_lists: ["active", "inactive"]
        ))

        assert_selector "input[type='hidden'][name='start_date'][value='2026-06-01']", visible: :all
        assert_selector "input[type='hidden'][name='end_date'][value='2026-06-30']", visible: :all
        assert_selector "select[name='status'] option[selected][value='inactive']", text: "inactive"
      end

      def test_accepts_hash_option_shape_for_status_lists
        render_inline(DefaultFilterComponent.new(
          status: "closed",
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
          status_lists: ["active", "inactive"]
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
    end
  end
end
