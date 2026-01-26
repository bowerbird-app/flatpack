# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PhoneInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_phone_input_with_name
        render_inline(Component.new(name: "phone"))

        assert_selector "input[type='tel'][name='phone']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "phone", value: "+1234567890"))

        assert_selector "input[value='+1234567890']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "phone", placeholder: "Enter phone number"))

        assert_selector "input[placeholder='Enter phone number']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "phone", label: "Phone Number"))

        assert_selector "label", text: "Phone Number"
        assert_selector "input[type='tel']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "phone", label: "Phone", id: "user-phone"))

        assert_selector "label[for='user-phone']"
        assert_selector "input#user-phone"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "phone", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "phone", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "phone", error: "Phone number is invalid"))

        assert_selector "p", text: "Phone number is invalid"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "phone", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-destructive)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "phone", class: "custom-phone-class"))

        assert_selector "input.custom-phone-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "phone", data: { format: "international" }))

        assert_selector "input[data-format='international']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "phone", aria: { label: "Contact phone" }))

        assert_selector "input[aria-label='Contact phone']"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "phone"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "phone"))

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

      def test_sanitizes_dangerous_attributes
        render_inline(Component.new(name: "phone", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "phone",
          value: "555-1234",
          placeholder: "123-456-7890",
          disabled: false,
          required: true,
          label: "Phone",
          class: "custom"
        ))

        assert_selector "label", text: "Phone"
        assert_selector "input[type='tel'][name='phone']"
        assert_selector "input[value='555-1234']"
        assert_selector "input[placeholder='123-456-7890']"
        assert_selector "input[required]"
        assert_selector "input.custom"
      end
    end
  end
end
