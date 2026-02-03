# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Switch
    class ComponentTest < ViewComponent::TestCase
      def test_renders_switch_with_name
        render_inline(Component.new(name: "notifications"))

        assert_selector "input[type='checkbox'][name='notifications']"
        assert_selector "div[role='switch']"
      end

      def test_renders_unchecked_switch_by_default
        render_inline(Component.new(name: "notifications"))

        refute_selector "input[checked]"
        assert_selector "div[role='switch'][aria-checked='false']"
      end

      def test_renders_checked_switch
        render_inline(Component.new(name: "notifications", checked: true))

        assert_selector "input[checked]"
        assert_selector "div[role='switch'][aria-checked='true']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "notifications", label: "Enable notifications"))

        assert_selector "span", text: "Enable notifications"
      end

      def test_renders_without_label
        render_inline(Component.new(name: "notifications"))

        refute_selector "span", text: "Enable notifications"
      end

      def test_renders_disabled_switch
        render_inline(Component.new(name: "notifications", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_switch
        render_inline(Component.new(name: "notifications", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error_message
        render_inline(Component.new(name: "notifications", error: "This field is required"))

        assert_selector "span", text: "This field is required"
      end

      def test_renders_small_size
        render_inline(Component.new(name: "notifications", size: :sm))

        assert_selector "input[type='checkbox']"
        assert_includes page.native.to_html, "h-5"
        assert_includes page.native.to_html, "w-9"
      end

      def test_renders_medium_size
        render_inline(Component.new(name: "notifications", size: :md))

        assert_selector "input[type='checkbox']"
        assert_includes page.native.to_html, "h-6"
        assert_includes page.native.to_html, "w-11"
      end

      def test_renders_large_size
        render_inline(Component.new(name: "notifications", size: :lg))

        assert_selector "input[type='checkbox']"
        assert_includes page.native.to_html, "h-7"
        assert_includes page.native.to_html, "w-12"
      end

      def test_default_size_is_medium
        render_inline(Component.new(name: "notifications"))

        assert_includes page.native.to_html, "h-6"
        assert_includes page.native.to_html, "w-11"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(name: "notifications", size: :xl)
        end
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(name: "notifications", class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(name: "notifications", data: {testid: "switch"}))

        assert_selector "input[data-testid='switch']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(name: "notifications", aria: {label: "Toggle notifications"}))

        assert_selector "input[aria-label='Toggle notifications']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(name: "notifications", id: "notification-switch"))

        assert_selector "input#notification-switch"
      end

      def test_input_has_value_attribute
        render_inline(Component.new(name: "notifications"))

        assert_selector "input[value='1']"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(name: "notifications", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end
    end
  end
end
