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

      def test_renders_help_text_with_character_count_style
        render_inline(Component.new(name: "username", help_text: "Use your public profile name."))

        assert_selector "p[id$='_help_text']", text: "Use your public profile name."
        help_text = page.find("p[id$='_help_text']")
        assert_includes help_text[:class], "mt-1"
        assert_includes help_text[:class], "text-xs"
        assert_includes help_text[:class], "text-[var(--surface-muted-content-color)]"
      end

      def test_does_not_render_blank_help_text
        render_inline(Component.new(name: "username", help_text: "   "))

        refute_selector "p[id$='_help_text']"
      end

      def test_help_text_is_in_aria_describedby
        render_inline(Component.new(name: "username", id: "username", help_text: "Use your public profile name."))

        assert_selector "input[aria-describedby='username_help_text']"
      end

      def test_help_text_and_error_are_both_in_aria_describedby
        render_inline(Component.new(name: "username", id: "username", help_text: "Use your public profile name.", error: "Username is required"))

        assert_selector "input[aria-describedby='username_help_text username_error'][aria-invalid='true']"
      end

      def test_help_text_escapes_html_content
        render_inline(Component.new(name: "username", help_text: "<strong>Use text only</strong>"))

        assert_text "<strong>Use text only</strong>"
        refute_selector "p[id$='_help_text'] strong"
      end

      def test_raises_error_with_html_safe_help_text
        assert_raises(ArgumentError) do
          Component.new(name: "username", help_text: "<strong>Use text only</strong>".html_safe)
        end
      end

      def test_raises_error_with_non_text_help_text
        assert_raises(ArgumentError) do
          Component.new(name: "username", help_text: {text: "Use your public profile name."})
        end
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "username", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-error)]"
        assert_includes html, "text-[var(--color-error)]"
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

      def test_renders_character_count_when_enabled
        render_inline(Component.new(name: "headline", character_count: true, value: "Hello"))

        assert_selector "p[id$='_character_count']", text: "5 characters"
      end

      def test_renders_character_count_with_max
        render_inline(Component.new(name: "headline", character_count: true, max_characters: 60, value: "Hello"))

        assert_selector "p[id$='_character_count']", text: "5/60 characters"
      end

      def test_renders_character_count_data_attributes
        render_inline(Component.new(
          name: "headline",
          character_count: true,
          min_characters: 10,
          max_characters: 60
        ))

        assert_selector "div[data-controller='flat-pack--text-input']"
        assert_selector "div[data-flat-pack--text-input-character-count-enabled-value='true']"
        assert_selector "div[data-flat-pack--text-input-min-characters-value='10']"
        assert_selector "div[data-flat-pack--text-input-max-characters-value='60']"
        assert_selector "input[data-flat-pack--text-input-target='input']"
        assert_selector "input[data-action='input->flat-pack--text-input#updateCharacterCount']"
      end

      def test_renders_quick_copy_button_and_input_actions
        render_inline(Component.new(name: "api_key", value: "abc123", quick_copy: true))

        assert_selector "div[data-controller='flat-pack--text-input']"
        assert_selector "div[data-flat-pack--text-input-quick-copy-enabled-value='true']"
        assert_selector "input[data-flat-pack--text-input-target='input']"
        assert_selector "input[data-action='click->flat-pack--text-input#copyFromInput']"
        assert_selector "button[aria-label='Copy input value'][data-action='click->flat-pack--text-input#copyFromButton']"
        assert_selector "svg[data-flat-pack--icon-name-value='clipboard-document']"
      end

      def test_combines_character_count_and_quick_copy_actions
        render_inline(Component.new(name: "headline", character_count: true, quick_copy: true))

        assert_selector "div[data-flat-pack--text-input-character-count-enabled-value='true']"
        assert_selector "div[data-flat-pack--text-input-quick-copy-enabled-value='true']"
        assert_selector "input[data-action='input->flat-pack--text-input#updateCharacterCount click->flat-pack--text-input#copyFromInput']"
      end

      def test_quick_copy_button_is_disabled_with_disabled_input
        render_inline(Component.new(name: "api_key", value: "abc123", quick_copy: true, disabled: true))

        assert_selector "button[disabled][aria-label='Copy input value']"
      end

      def test_quick_copy_renders_readonly_input
        render_inline(Component.new(name: "api_key", value: "abc123", quick_copy: true))

        assert_selector "input[readonly]"
      end

      def test_does_not_render_character_count_when_disabled
        render_inline(Component.new(name: "headline", character_count: false))

        refute_selector "p[id$='_character_count']"
        refute_selector "div[data-controller='flat-pack--text-input']"
      end

      def test_raises_error_with_negative_min_characters
        assert_raises(ArgumentError) do
          Component.new(name: "headline", character_count: true, min_characters: -1)
        end
      end

      def test_raises_error_with_negative_max_characters
        assert_raises(ArgumentError) do
          Component.new(name: "headline", character_count: true, max_characters: -1)
        end
      end

      def test_raises_error_when_min_is_greater_than_max
        assert_raises(ArgumentError) do
          Component.new(name: "headline", character_count: true, min_characters: 80, max_characters: 60)
        end
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
