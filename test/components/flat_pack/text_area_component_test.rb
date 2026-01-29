# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TextArea
    class ComponentTest < ViewComponent::TestCase
      def test_renders_textarea_with_name
        render_inline(Component.new(name: "description"))

        assert_selector "textarea[name='description']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "description", value: "Some text content"))

        assert_selector "textarea", text: "Some text content"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "description", placeholder: "Enter description"))

        assert_selector "textarea[placeholder='Enter description']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "description", label: "Description"))

        assert_selector "label", text: "Description"
        assert_selector "textarea"
      end

      def test_label_for_attribute_matches_textarea_id
        render_inline(Component.new(name: "description", label: "Description", id: "user-description"))

        assert_selector "label[for='user-description']"
        assert_selector "textarea#user-description"
      end

      def test_renders_with_default_rows
        render_inline(Component.new(name: "description"))

        assert_selector "textarea[rows='3']"
      end

      def test_renders_with_custom_rows
        render_inline(Component.new(name: "description", rows: 5))

        assert_selector "textarea[rows='5']"
      end

      def test_raises_error_with_invalid_rows
        assert_raises(ArgumentError) do
          Component.new(name: "description", rows: 0)
        end
      end

      def test_raises_error_with_negative_rows
        assert_raises(ArgumentError) do
          Component.new(name: "description", rows: -1)
        end
      end

      def test_has_stimulus_controller
        render_inline(Component.new(name: "description"))

        assert_selector "textarea[data-controller='flat-pack--text-area']"
        assert_selector "textarea[data-flat-pack--text-area-target='textarea']"
      end

      def test_has_auto_expand_action
        render_inline(Component.new(name: "description"))

        assert_selector "textarea[data-action='input->flat-pack--text-area#autoExpand']"
      end

      def test_has_resize_none_class
        render_inline(Component.new(name: "description"))

        html = page.native.to_html
        assert_includes html, "resize-none"
      end

      def test_renders_disabled_textarea
        render_inline(Component.new(name: "description", disabled: true))

        assert_selector "textarea[disabled]"
      end

      def test_renders_required_textarea
        render_inline(Component.new(name: "description", required: true))

        assert_selector "textarea[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "description", error: "Description is required"))

        assert_selector "p", text: "Description is required"
        assert_selector "textarea[aria-invalid='true']"
        assert_selector "textarea[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "description", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "description", class: "custom-textarea"))

        assert_selector "textarea.custom-textarea"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "description", data: {maxlength: "500"}))

        assert_selector "textarea[data-maxlength='500']"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "description"))

        assert_selector "textarea.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "description"))

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
        render_inline(Component.new(name: "description", onclick: "alert('xss')"))

        refute_selector "textarea[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "description",
          value: "Initial text",
          placeholder: "Enter text",
          disabled: false,
          required: true,
          label: "Description",
          rows: 5,
          class: "custom"
        ))

        assert_selector "label", text: "Description"
        assert_selector "textarea[name='description']", text: "Initial text"
        assert_selector "textarea[placeholder='Enter text']"
        assert_selector "textarea[required]"
        assert_selector "textarea[rows='5']"
        assert_selector "textarea.custom"
      end
    end
  end
end
