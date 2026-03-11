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

        assert_selector "div[data-controller='flat-pack--text-area']"
        assert_selector "textarea[data-flat-pack--text-area-target='textarea']"
        assert_selector "div[data-flat-pack--text-area-autogrow-value='true']"
        assert_selector "div[data-flat-pack--text-area-submit-on-enter-value='false']"
      end

      def test_has_auto_expand_action
        render_inline(Component.new(name: "description"))

        assert_selector "textarea[data-action='input->flat-pack--text-area#autoExpand input->flat-pack--text-area#updateCharacterCount']"
      end

      def test_can_disable_auto_expand_action
        render_inline(Component.new(name: "description", autogrow: false))

        assert_selector "div[data-flat-pack--text-area-autogrow-value='false']"
        assert_selector "textarea[data-action='input->flat-pack--text-area#updateCharacterCount']"
      end

      def test_can_submit_on_enter
        render_inline(Component.new(name: "description", submit_on_enter: true))

        assert_selector "div[data-flat-pack--text-area-submit-on-enter-value='true']"
        assert_selector "textarea[data-action='input->flat-pack--text-area#autoExpand input->flat-pack--text-area#updateCharacterCount keydown->flat-pack--text-area#handleKeydown']"
      end

      def test_renders_character_count_when_enabled
        render_inline(Component.new(name: "description", character_count: true, value: "Hello"))

        assert_selector "p[id$='_character_count']", text: "5 characters"
      end

      def test_renders_character_count_with_max
        render_inline(Component.new(name: "description", character_count: true, max_characters: 120, value: "Hello"))

        assert_selector "p[id$='_character_count']", text: "5/120 characters"
      end

      def test_renders_character_count_data_attributes
        render_inline(Component.new(
          name: "description",
          character_count: true,
          min_characters: 10,
          max_characters: 200
        ))

        assert_selector "div[data-flat-pack--text-area-character-count-enabled-value='true']"
        assert_selector "div[data-flat-pack--text-area-min-characters-value='10']"
        assert_selector "div[data-flat-pack--text-area-max-characters-value='200']"
      end

      def test_does_not_render_character_count_when_disabled
        render_inline(Component.new(name: "description", character_count: false))

        refute_selector "p[id$='_character_count']"
      end

      def test_raises_error_with_negative_min_characters
        assert_raises(ArgumentError) do
          Component.new(name: "description", character_count: true, min_characters: -1)
        end
      end

      def test_raises_error_with_negative_max_characters
        assert_raises(ArgumentError) do
          Component.new(name: "description", character_count: true, max_characters: -1)
        end
      end

      def test_raises_error_when_min_is_greater_than_max
        assert_raises(ArgumentError) do
          Component.new(name: "description", character_count: true, min_characters: 120, max_characters: 100)
        end
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
        assert_includes html, "border-warning"
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

      def test_renders_rich_text_editor_shell
        render_inline(Component.new(
          name: "article[body]",
          label: "Body",
          value: {type: "doc", content: [{type: "paragraph", content: [{type: "text", text: "Hello"}]}]},
          rich_text: true
        ))

        assert_selector "div[data-controller='flat-pack--tiptap']"
        assert_selector "div[data-flat-pack--tiptap-target='uiRoot'][data-flat-pack--tiptap-ui-role='root']"
        assert_selector "div[role='toolbar'][data-flat-pack--tiptap-ui-role='toolbar']"
        assert_selector "div[role='textbox'][data-flat-pack--tiptap-target='editor']"
        assert_selector "input[type='hidden'][name='article[body]'][data-flat-pack--tiptap-target='input']", visible: false
        refute_selector "div[data-controller='flat-pack--tiptap'] textarea:not([hidden])"
      end

      def test_rich_text_renders_hidden_field_with_serialized_json
        render_inline(Component.new(
          name: "article[body]",
          value: "Hello world",
          rich_text: true
        ))

        value = page.find("input[type='hidden'][name='article[body]']", visible: false).value
        parsed = JSON.parse(value)

        assert_equal "doc", parsed["type"]
        assert_includes parsed.to_s, "Hello world"
      end

      def test_rich_text_supports_hidden_textarea_output
        render_inline(Component.new(
          name: "article[body]",
          rich_text: true,
          rich_text_options: {output_input_type: :hidden_textarea}
        ))

        assert_selector "textarea.hidden[name='article[body]'][data-flat-pack--tiptap-target='input']", visible: false
      end

      def test_rich_text_serializes_bubble_menu_and_preset_configuration
        render_inline(Component.new(
          name: "article[body]",
          rich_text: true,
          rich_text_options: {preset: :content, bubble_menu: true}
        ))

        config = JSON.parse(page.find("div[data-controller='flat-pack--tiptap']")["data-flat-pack--tiptap-config-value"])

        assert_equal "content", config["preset"]
        assert_equal true, config["bubble_menu"]
        assert_equal true, config.dig("extensions", "table_kit")
        assert_equal true, config.dig("extensions", "bubble_menu")
        assert_equal "adaptive", config.dig("ui", "mode")
        assert_equal "flatpack", config.dig("ui", "theme")
      end

      def test_rich_text_supports_disabled_required_error_and_custom_classes
        render_inline(Component.new(
          name: "article[body]",
          rich_text: true,
          label: "Body",
          required: true,
          disabled: true,
          error: "Body is required",
          class: "custom-rich-text"
        ))

        assert_selector "label", text: "Body"
        assert_selector "div[role='textbox'].custom-rich-text[aria-required='true'][aria-disabled='true'][aria-invalid='true']"
        assert_selector "p", text: "Body is required"
        assert_selector "input[type='hidden'][disabled]", visible: false
      end

      def test_rich_text_uses_placeholder_override
        render_inline(Component.new(
          name: "article[body]",
          placeholder: "Component placeholder",
          rich_text: true,
          rich_text_options: {placeholder: "Rich placeholder"}
        ))

        config = JSON.parse(page.find("div[data-controller='flat-pack--tiptap']")["data-flat-pack--tiptap-config-value"])
        assert_equal "Rich placeholder", config["placeholder"]
      end

      def test_rich_text_rejects_invalid_option_type
        error = assert_raises(ArgumentError) do
          Component.new(name: "article[body]", rich_text: true, rich_text_options: "oops")
        end

        assert_includes error.message, "rich_text_options must be a Hash"
      end

      def test_rich_text_rejects_invalid_enum_values
        error = assert_raises(ArgumentError) do
          Component.new(name: "article[body]", rich_text: true, rich_text_options: {format: :markdown})
        end

        assert_includes error.message, "rich_text_options.format"
      end

      def test_rich_text_rejects_framework_specific_wrappers
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "article[body]",
            rich_text: true,
            rich_text_options: {extensions: {drag_handle_react: true}}
          )
        end

        assert_includes error.message, "framework-specific TipTap wrapper"
      end

      def test_rich_text_rejects_invalid_ui_options
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "article[body]",
            rich_text: true,
            rich_text_options: {ui: "nope"}
          )
        end

        assert_includes error.message, "rich_text_options.ui must be a Hash"
      end
    end
  end
end
