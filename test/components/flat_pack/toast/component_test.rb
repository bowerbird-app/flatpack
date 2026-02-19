# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toast
    class ComponentTest < ViewComponent::TestCase
      def test_renders_toast_with_message
        render_inline(Component.new(message: "Success!"))

        assert_text "Success!"
      end

      def test_renders_info_toast
        render_inline(Component.new(message: "Info", type: :info))

        assert_selector "div[role='status']"
        assert_text "Info"
      end

      def test_renders_success_toast
        render_inline(Component.new(message: "Success", type: :success))

        assert_text "Success"
      end

      def test_renders_warning_toast
        render_inline(Component.new(message: "Warning", type: :warning))

        assert_text "Warning"
      end

      def test_renders_error_toast
        render_inline(Component.new(message: "Error", type: :error))

        assert_text "Error"
      end

      def test_renders_toast_with_icon
        render_inline(Component.new(message: "Test"))

        assert_selector "svg"
      end

      def test_renders_dismiss_button_by_default
        render_inline(Component.new(message: "Test"))

        assert_selector "button[aria-label='Dismiss']"
      end

      def test_hides_dismiss_button_when_not_dismissible
        render_inline(Component.new(message: "Test", dismissible: false))

        refute_selector "button[aria-label='Dismiss']"
      end

      def test_toast_has_stimulus_controller
        render_inline(Component.new(message: "Test"))

        assert_selector "div[data-controller='flat-pack--toast']"
      end

      def test_toast_has_timeout_value
        render_inline(Component.new(message: "Test", timeout: 3000))

        assert_selector "div[data-flat-pack--toast-timeout-value='3000']"
      end

      def test_toast_has_aria_live
        render_inline(Component.new(message: "Test"))

        assert_selector "div[aria-live='polite']"
        assert_selector "div[aria-atomic='true']"
      end

      def test_raises_error_without_message
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_type
        assert_raises(ArgumentError) do
          Component.new(message: "Test", type: :invalid)
        end
      end

      def test_raises_error_for_negative_timeout
        assert_raises(ArgumentError) do
          Component.new(message: "Test", timeout: -1)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(message: "Test", class: "custom-class"))

        assert_selector "div.custom-class"
      end
    end
  end
end
