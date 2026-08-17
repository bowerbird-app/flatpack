# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toast
    class ComponentTest < ViewComponent::TestCase
      def test_renders_toast_with_text
        render_inline(Component.new(text: "Success!"))

        assert_text "Success!"
      end

      def test_renders_info_toast
        render_inline(Component.new(text: "Info", style: :info))

        assert_selector "div[role='status']"
        assert_text "Info"
      end

      def test_renders_success_toast
        render_inline(Component.new(text: "Success", style: :success))

        assert_text "Success"
      end

      def test_renders_warning_toast
        render_inline(Component.new(text: "Warning", style: :warning))

        assert_text "Warning"
      end

      def test_renders_danger_toast
        render_inline(Component.new(text: "Danger", style: :danger))

        assert_text "Danger"
      end

      def test_renders_toast_with_icon
        render_inline(Component.new(text: "Test"))

        assert_selector "svg"
      end

      def test_renders_dismiss_button_by_default
        render_inline(Component.new(text: "Test"))

        assert_selector "button[aria-label='Dismiss']"
      end

      def test_hides_dismiss_button_when_not_dismissible
        render_inline(Component.new(text: "Test", dismissible: false))

        refute_selector "button[aria-label='Dismiss']"
      end

      def test_toast_has_stimulus_controller
        render_inline(Component.new(text: "Test"))

        assert_selector "div[data-controller='flat-pack--toast']"
      end

      def test_toast_has_timeout_value
        render_inline(Component.new(text: "Test", timeout: 3000))

        assert_selector "div[data-flat-pack--toast-timeout-value='3000']"
      end

      def test_toast_has_aria_live
        render_inline(Component.new(text: "Test"))

        assert_selector "div[aria-live='polite']"
        assert_selector "div[aria-atomic='true']"
      end

      def test_raises_error_without_text
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_style
        assert_raises(ArgumentError) do
          Component.new(text: "Test", style: :invalid)
        end
      end

      def test_raises_error_for_negative_timeout
        assert_raises(ArgumentError) do
          Component.new(text: "Test", timeout: -1)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(text: "Test", class: "custom-class"))

        assert_selector "div.custom-class"
      end
    end
  end
end
