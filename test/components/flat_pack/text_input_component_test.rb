# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TextInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_text_input_with_name
        render_inline(Component.new(name: "username"))

        assert_selector "input[type='text'][name='username']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "username", value: "john_doe"))

        assert_selector "input[value='john_doe']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "username", placeholder: "Enter username"))

        assert_selector "input[placeholder='Enter username']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "username", label: "Username"))

        assert_selector "label", text: "Username"
        assert_selector "input[type='text']"
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "username", label: "Username", id: "user-name-input"))

        assert_selector "label[for='user-name-input']"
        assert_selector "input#user-name-input"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "username", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "username", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "username", error: "Username is required"))

        assert_selector "p", text: "Username is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "username", error: "Invalid"))

        # Check that destructive border color is applied
        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "username", class: "custom-input-class"))

        assert_selector "input.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "username", data: {controller: "custom"}))

        assert_selector "input[data-controller='custom']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "username", aria: {label: "Custom username"}))

        assert_selector "input[aria-label='Custom username']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "username", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "username"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "username"))

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
        render_inline(Component.new(name: "username", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "username",
          value: "john",
          placeholder: "Enter name",
          disabled: false,
          required: true,
          label: "Username",
          class: "custom-class"
        ))

        assert_selector "label", text: "Username"
        assert_selector "input[type='text'][name='username']"
        assert_selector "input[value='john']"
        assert_selector "input[placeholder='Enter name']"
        assert_selector "input[required]"
        assert_selector "input.custom-class"
      end
    end
  end
end
