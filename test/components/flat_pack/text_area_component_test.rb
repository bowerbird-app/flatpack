# frozen_string_literal: true

require "test_helper"
require "json"

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

      def test_rich_text_mode_sets_dedicated_controller_and_targets
        render_inline(Component.new(name: "description", rich_text_editor: true))

        assert_selector "div[data-controller='flat-pack--rich-text-editor']"
        assert_selector "textarea[data-flat-pack--rich-text-editor-target='textarea']"
        refute_selector "div[data-controller='flat-pack--text-area']"
      end

      def test_rich_text_mode_serializes_allowlisted_options_only
        render_inline(Component.new(
          name: "description",
          rich_text_editor: true,
          rich_text_editor_options: {
            placeholder: "Write here",
            height: 240,
            balloon_toolbar: %w[Bold Italic Link],
            extra_plugins: %w[autogrow],
            remove_plugins: "resize,elementspath",
            content_css: ["flat_pack/ckeditor.css"],
            toolbar_groups: [{name: "basicstyles", groups: %w[basicstyles cleanup]}],
            on: "alert(1)"
          }
        ))

        config = JSON.parse(page.find("div[data-controller='flat-pack--rich-text-editor']")["data-flat-pack--rich-text-editor-config-value"])

        assert_equal "Write here", config["placeholder"]
        assert_equal "240px", config["height"]
        assert_equal ["Bold", "Italic", "Link"], config["balloonToolbar"]
        assert_equal ["autogrow"], config["extraPlugins"]
        assert_equal ["resize", "elementspath"], config["removePlugins"]
        assert_equal ["flat_pack/ckeditor.css"], config["contentsCss"]
        assert_equal [{"name" => "basicstyles", "groups" => ["basicstyles", "cleanup"]}], config["toolbarGroups"]
        refute_includes config.keys, "on"
      end

      def test_rich_text_mode_preserves_accessibility_and_error_state
        render_inline(Component.new(
          name: "description",
          id: "description-field",
          label: "Description",
          error: "Description is required",
          required: true,
          rich_text_editor: true
        ))

        assert_selector "label[for='description-field']", text: "Description"
        assert_selector "textarea#description-field[required][aria-invalid='true'][aria-describedby='description-field_error']"
        assert_selector "p#description-field_error", text: "Description is required"
      end

      def test_rich_text_mode_sanitizes_initial_html_value
        render_inline(Component.new(
          name: "description",
          rich_text_editor: true,
          value: "<script>alert('xss')</script><p><strong>Safe</strong> copy</p>"
        ))

        html = page.native.to_html
        refute_includes html, "<script>"
        assert_includes html, "<p><strong>Safe</strong> copy</p>"
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
