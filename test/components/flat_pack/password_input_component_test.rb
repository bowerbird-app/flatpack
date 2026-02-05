# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PasswordInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_password_input_with_name
        render_inline(Component.new(name: "password"))

        assert_selector "input[type='password'][name='password']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "password", value: "secret123"))

        assert_selector "input[value='secret123']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "password", placeholder: "Enter password"))

        assert_selector "input[placeholder='Enter password']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "password", label: "Password"))

        assert_selector "label", text: "Password"
        assert_selector "input[type='password']"
      end

      def test_renders_toggle_button
        render_inline(Component.new(name: "password"))

        assert_selector "button[type='button'][aria-label='Toggle password visibility']"
      end

      def test_has_stimulus_controller
        render_inline(Component.new(name: "password"))

        assert_selector "div[data-controller='flat-pack--password-input']"
        assert_selector "input[data-flat-pack--password-input-target='input']"
      end

      def test_toggle_button_has_correct_data_attributes
        render_inline(Component.new(name: "password"))

        assert_selector "button[data-action='flat-pack--password-input#toggle']"
        assert_selector "button[data-flat-pack--password-input-target='toggle']"
      end

      def test_renders_eye_icons
        render_inline(Component.new(name: "password"))

        # Should have both eye and eye-off icons
        html = page.native.to_html
        assert_includes html, "lucide-eye"
        assert_includes html, "lucide-eye-off"
      end

      def test_eye_off_icon_initially_hidden
        render_inline(Component.new(name: "password"))

        # Eye-off icon should have hidden class initially
        html = page.native.to_html
        assert_match(/lucide-eye-off.*hidden/, html)
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "password", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "password", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "password", error: "Password is required"))

        assert_selector "p", text: "Password is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_input_has_padding_for_toggle_button
        render_inline(Component.new(name: "password"))

        html = page.native.to_html
        assert_includes html, "pr-10"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "password", class: "custom-class"))

        assert_selector "input.custom-class"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "password"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "password"))

        assert_selector "div.flat-pack-input-wrapper"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new(name: nil)
        end
      end

      def test_sanitizes_dangerous_attributes
        render_inline(Component.new(name: "password", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "password",
          value: "secret",
          placeholder: "Enter password",
          disabled: false,
          required: true,
          label: "Password",
          error: nil
        ))

        assert_selector "label", text: "Password"
        assert_selector "input[type='password'][name='password'][value='secret'][placeholder='Enter password'][required]"
        assert_selector "button[type='button']"
      end
    end
  end
end
