# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TimeInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_time_input_with_name
        render_inline(Component.new(name: "starts_at"))

        assert_selector "input[type='time'][name='starts_at']"
      end

      def test_renders_with_string_value
        render_inline(Component.new(name: "starts_at", value: "10:30"))

        assert_selector "input[value='10:30']"
      end

      def test_renders_with_time_object_value
        time = Time.new(2024, 1, 15, 10, 30, 0)
        render_inline(Component.new(name: "starts_at", value: time))

        assert_selector "input[value='10:30']"
      end

      def test_renders_with_datetime_object_value
        datetime = DateTime.new(2024, 1, 15, 10, 30, 0)
        render_inline(Component.new(name: "starts_at", value: datetime))

        assert_selector "input[value='10:30']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "starts_at", placeholder: "Select time"))

        assert_selector "input[placeholder='Select time']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "starts_at", label: "Start Time"))

        assert_selector "label", text: "Start Time"
        assert_selector "input[type='time']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "starts_at", label: "Start Time", id: "starts-at-input"))

        assert_selector "label[for='starts-at-input']"
        assert_selector "input#starts-at-input"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "starts_at", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "starts_at", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "starts_at", error: "Start time is required"))

        assert_selector "p", text: "Start time is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "starts_at", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-warning"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "starts_at", class: "custom-input-class"))

        assert_selector "input.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "starts_at", data: {controller: "custom"}))

        assert_selector "input[data-controller~='custom']"
        assert_selector "input[data-controller~='flat-pack--date-input']"
      end

      def test_renders_with_default_controller
        render_inline(Component.new(name: "starts_at"))

        assert_selector "input[data-controller~='flat-pack--date-input']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "starts_at", aria: {label: "Custom time"}))

        assert_selector "input[aria-label='Custom time']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "starts_at", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "starts_at"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "starts_at"))

        assert_selector "div.flat-pack-input-wrapper"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new(name: nil)
        end
      end

      def test_raises_error_with_empty_name
        assert_raises(ArgumentError) do
          Component.new(name: "")
        end
      end

      def test_sanitizes_dangerous_onclick_attribute
        render_inline(Component.new(name: "starts_at", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_min_time_string
        render_inline(Component.new(name: "starts_at", min: "09:00"))

        assert_selector "input[min='09:00']"
      end

      def test_renders_with_max_time_string
        render_inline(Component.new(name: "starts_at", max: "17:00"))

        assert_selector "input[max='17:00']"
      end

      def test_renders_with_min_time_object
        min_time = Time.new(2024, 1, 1, 9, 0, 0)
        render_inline(Component.new(name: "starts_at", min: min_time))

        assert_selector "input[min='09:00']"
      end

      def test_renders_with_max_time_object
        max_time = Time.new(2024, 1, 1, 17, 0, 0)
        render_inline(Component.new(name: "starts_at", max: max_time))

        assert_selector "input[max='17:00']"
      end

      def test_renders_with_min_and_max
        render_inline(Component.new(
          name: "starts_at",
          min: "09:00",
          max: "17:00"
        ))

        assert_selector "input[min='09:00'][max='17:00']"
      end

      def test_handles_nil_value
        render_inline(Component.new(name: "starts_at", value: nil))

        assert_selector "input[type='time'][name='starts_at']"
        refute_selector "input[value]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "starts_at",
          value: "10:30",
          placeholder: "Select time",
          disabled: false,
          required: true,
          label: "Start Time",
          min: "09:00",
          max: "17:00",
          class: "custom-class"
        ))

        assert_selector "label", text: "Start Time"
        assert_selector "input[type='time'][name='starts_at']"
        assert_selector "input[value='10:30']"
        assert_selector "input[placeholder='Select time']"
        assert_selector "input[required]"
        assert_selector "input[min='09:00']"
        assert_selector "input[max='17:00']"
        assert_selector "input.custom-class"
      end
    end
  end
end