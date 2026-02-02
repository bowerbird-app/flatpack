# frozen_string_literal: true

require "test_helper"

module FlatPack
  module DateInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_date_input_with_name
        render_inline(Component.new(name: "birth_date"))

        assert_selector "input[type='date'][name='birth_date']"
      end

      def test_renders_with_string_value
        render_inline(Component.new(name: "birth_date", value: "2024-01-15"))

        assert_selector "input[value='2024-01-15']"
      end

      def test_renders_with_date_object_value
        date = Date.new(2024, 1, 15)
        render_inline(Component.new(name: "birth_date", value: date))

        assert_selector "input[value='2024-01-15']"
      end

      def test_renders_with_time_object_value
        time = Time.new(2024, 1, 15, 10, 30, 0)
        render_inline(Component.new(name: "birth_date", value: time))

        assert_selector "input[value='2024-01-15']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "birth_date", placeholder: "Select date"))

        assert_selector "input[placeholder='Select date']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "birth_date", label: "Birth Date"))

        assert_selector "label", text: "Birth Date"
        assert_selector "input[type='date']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "birth_date", label: "Birth Date", id: "birth-date-input"))

        assert_selector "label[for='birth-date-input']"
        assert_selector "input#birth-date-input"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "birth_date", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "birth_date", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "birth_date", error: "Date is required"))

        assert_selector "p", text: "Date is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "birth_date", error: "Invalid"))

        # Check that destructive border color is applied
        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "birth_date", class: "custom-input-class"))

        assert_selector "input.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "birth_date", data: {controller: "custom"}))

        assert_selector "input[data-controller='custom']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "birth_date", aria: {label: "Custom date"}))

        assert_selector "input[aria-label='Custom date']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "birth_date", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "birth_date"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "birth_date"))

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
        render_inline(Component.new(name: "birth_date", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_min_date_string
        render_inline(Component.new(name: "birth_date", min: "2024-01-01"))

        assert_selector "input[min='2024-01-01']"
      end

      def test_renders_with_max_date_string
        render_inline(Component.new(name: "birth_date", max: "2024-12-31"))

        assert_selector "input[max='2024-12-31']"
      end

      def test_renders_with_min_date_object
        min_date = Date.new(2024, 1, 1)
        render_inline(Component.new(name: "birth_date", min: min_date))

        assert_selector "input[min='2024-01-01']"
      end

      def test_renders_with_max_date_object
        max_date = Date.new(2024, 12, 31)
        render_inline(Component.new(name: "birth_date", max: max_date))

        assert_selector "input[max='2024-12-31']"
      end

      def test_renders_with_min_and_max
        render_inline(Component.new(
          name: "birth_date",
          min: "2024-01-01",
          max: "2024-12-31"
        ))

        assert_selector "input[min='2024-01-01'][max='2024-12-31']"
      end

      def test_handles_nil_value
        render_inline(Component.new(name: "birth_date", value: nil))

        assert_selector "input[type='date'][name='birth_date']"
        refute_selector "input[value]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "birth_date",
          value: "2024-01-15",
          placeholder: "Select date",
          disabled: false,
          required: true,
          label: "Birth Date",
          min: "2000-01-01",
          max: "2024-12-31",
          class: "custom-class"
        ))

        assert_selector "label", text: "Birth Date"
        assert_selector "input[type='date'][name='birth_date']"
        assert_selector "input[value='2024-01-15']"
        assert_selector "input[placeholder='Select date']"
        assert_selector "input[required]"
        assert_selector "input[min='2000-01-01']"
        assert_selector "input[max='2024-12-31']"
        assert_selector "input.custom-class"
      end
    end
  end
end
