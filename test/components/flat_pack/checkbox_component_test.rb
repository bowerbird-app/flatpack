# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Checkbox
    class ComponentTest < ViewComponent::TestCase
      def test_renders_checkbox_with_name
        render_inline(Component.new(name: "agree"))

        assert_selector "input[type='checkbox'][name='agree']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "agree", value: "yes"))

        assert_selector "input[value='yes']"
      end

      def test_renders_checked
        render_inline(Component.new(name: "agree", checked: true))

        assert_selector "input[checked]"
      end

      def test_renders_unchecked_by_default
        render_inline(Component.new(name: "agree"))

        refute_selector "input[checked]"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "agree", label: "I agree to terms"))

        assert_selector "label", text: "I agree to terms"
        assert_selector "input[type='checkbox']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "agree", label: "I agree", id: "agree-checkbox"))

        assert_selector "label[for='agree-checkbox']"
        assert_selector "input#agree-checkbox"
      end

      def test_renders_disabled_checkbox
        render_inline(Component.new(name: "agree", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_checkbox
        render_inline(Component.new(name: "agree", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "agree", error: "You must agree to continue"))

        assert_selector "p", text: "You must agree to continue"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "agree", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-warning"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "agree", class: "custom-checkbox"))

        assert_selector "input.custom-checkbox"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "agree", data: {controller: "custom"}))

        assert_selector "input[data-controller='custom']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "agree", aria: {label: "Custom agree"}))

        assert_selector "input[aria-label='Custom agree']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "agree", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_base_flat_pack_checkbox_class
        render_inline(Component.new(name: "agree"))

        assert_selector "input.flat-pack-checkbox"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "agree"))

        assert_selector "div.flat-pack-checkbox-wrapper"
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
        render_inline(Component.new(name: "agree", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_disabled_label_has_disabled_styles
        render_inline(Component.new(name: "agree", label: "Agree", disabled: true))

        html = page.native.to_html
        assert_includes html, "opacity-50"
        assert_includes html, "cursor-not-allowed"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "agree",
          value: "accepted",
          checked: true,
          label: "I agree",
          disabled: false,
          required: true,
          class: "custom-class"
        ))

        assert_selector "label", text: "I agree"
        assert_selector "input[type='checkbox'][name='agree']"
        assert_selector "input[value='accepted']"
        assert_selector "input[checked]"
        assert_selector "input[required]"
        assert_selector "input.custom-class"
      end
    end
  end
end
