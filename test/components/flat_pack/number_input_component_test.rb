# frozen_string_literal: true

require "test_helper"

module FlatPack
  module NumberInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_number_input_with_name
        render_inline(Component.new(name: "quantity"))

        assert_selector "input[type='number'][name='quantity']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "quantity", value: 42))

        assert_selector "input[value='42']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "quantity", placeholder: "Enter quantity"))

        assert_selector "input[placeholder='Enter quantity']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "quantity", label: "Quantity"))

        assert_selector "label", text: "Quantity"
        assert_selector "input[type='number']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "quantity", label: "Quantity", id: "quantity-input"))

        assert_selector "label[for='quantity-input']"
        assert_selector "input#quantity-input"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "quantity", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "quantity", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "quantity", error: "Quantity is required"))

        assert_selector "p", text: "Quantity is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "quantity", error: "Invalid"))

        # Check that destructive border color is applied
        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "quantity", class: "custom-input-class"))

        assert_selector "input.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "quantity", data: {controller: "custom"}))

        assert_selector "input[data-controller='custom']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "quantity", aria: {label: "Custom quantity"}))

        assert_selector "input[aria-label='Custom quantity']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "quantity", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "quantity"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "quantity"))

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
        render_inline(Component.new(name: "quantity", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_min_attribute
        render_inline(Component.new(name: "quantity", min: 0))

        assert_selector "input[min='0']"
      end

      def test_renders_with_max_attribute
        render_inline(Component.new(name: "quantity", max: 100))

        assert_selector "input[max='100']"
      end

      def test_renders_with_step_attribute
        render_inline(Component.new(name: "quantity", step: 5))

        assert_selector "input[step='5']"
      end

      def test_default_step_is_one
        render_inline(Component.new(name: "quantity"))

        assert_selector "input[step='1']"
      end

      def test_renders_with_min_max_and_step
        render_inline(Component.new(name: "quantity", min: 0, max: 100, step: 10))

        assert_selector "input[min='0'][max='100'][step='10']"
      end

      def test_raises_error_with_negative_step
        assert_raises(ArgumentError, match: /step must be a positive number/) do
          Component.new(name: "quantity", step: -1)
        end
      end

      def test_raises_error_with_zero_step
        assert_raises(ArgumentError, match: /step must be a positive number/) do
          Component.new(name: "quantity", step: 0)
        end
      end

      def test_accepts_decimal_step
        render_inline(Component.new(name: "quantity", step: 0.5))

        assert_selector "input[step='0.5']"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "quantity",
          value: 10,
          placeholder: "Enter quantity",
          disabled: false,
          required: true,
          label: "Quantity",
          min: 1,
          max: 100,
          step: 5,
          class: "custom-class"
        ))

        assert_selector "label", text: "Quantity"
        assert_selector "input[type='number'][name='quantity']"
        assert_selector "input[value='10']"
        assert_selector "input[placeholder='Enter quantity']"
        assert_selector "input[required]"
        assert_selector "input[min='1']"
        assert_selector "input[max='100']"
        assert_selector "input[step='5']"
        assert_selector "input.custom-class"
      end
    end
  end
end
