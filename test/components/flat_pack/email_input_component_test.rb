# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmailInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_email_input_with_name
        render_inline(Component.new(name: "email"))

        assert_selector "input[type='email'][name='email']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "email", value: "user@example.com"))

        assert_selector "input[value='user@example.com']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "email", placeholder: "Enter your email"))

        assert_selector "input[placeholder='Enter your email']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "email", label: "Email Address"))

        assert_selector "label", text: "Email Address"
        assert_selector "input[type='email']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "email", label: "Email", id: "user-email"))

        assert_selector "label[for='user-email']"
        assert_selector "input#user-email"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "email", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "email", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "email", error: "Email is invalid"))

        assert_selector "p", text: "Email is invalid"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "email", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "email", class: "custom-email-class"))

        assert_selector "input.custom-email-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "email", data: {validate: "email"}))

        assert_selector "input[data-validate='email']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "email", aria: {label: "User email address"}))

        assert_selector "input[aria-label='User email address']"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "email"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "email"))

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
        render_inline(Component.new(name: "email", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "email",
          value: "test@example.com",
          placeholder: "your@email.com",
          disabled: false,
          required: true,
          label: "Email",
          class: "custom"
        ))

        assert_selector "label", text: "Email"
        assert_selector "input[type='email'][name='email']"
        assert_selector "input[value='test@example.com']"
        assert_selector "input[placeholder='your@email.com']"
        assert_selector "input[required]"
        assert_selector "input.custom"
      end
    end
  end
end
