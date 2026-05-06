# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TextArea
    # Tests for the new rich_text: true mode and RichTextOptions validation.
    # Plain textarea regression coverage is in text_area_component_test.rb.
    class RichTextComponentTest < ViewComponent::TestCase
      # ── Plain mode regressions ─────────────────────────────────────────────

      def test_plain_mode_still_renders_textarea
        render_inline(Component.new(name: "body"))
        assert_selector "textarea[name='body']"
        refute_selector "[data-controller='flat-pack--tiptap']"
      end

      def test_plain_mode_preserves_autogrow_data_attribute
        render_inline(Component.new(name: "body", autogrow: true))
        assert_selector "div[data-flat-pack--text-area-autogrow-value='true']"
      end

      def test_plain_mode_preserves_character_count
        render_inline(Component.new(name: "body", character_count: true, value: "hi"))
        assert_selector "p[id$='_character_count']", text: "2 characters"
      end

      def test_plain_mode_preserves_error_state
        render_inline(Component.new(name: "body", error: "Required"))
        assert_selector "textarea[aria-invalid='true']"
        assert_selector "p.mt-1.text-sm", text: "Required"
      end

      def test_plain_mode_rows_validation_still_works
        assert_raises(ArgumentError) { Component.new(name: "body", rows: 0) }
      end

      def test_plain_mode_character_limit_validation_still_works
        assert_raises(ArgumentError) do
          Component.new(name: "body", character_count: true, min_characters: 100, max_characters: 50)
        end
      end

      # ── Rich text mode — basic rendering ──────────────────────────────────

      def test_rich_text_mode_uses_tiptap_controller
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-controller='flat-pack--tiptap']"
      end

      def test_rich_text_mode_does_not_render_native_textarea
        render_inline(Component.new(name: "body", rich_text: true))
        refute_selector "textarea"
      end

      def test_rich_text_mode_renders_editor_container
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-flat-pack--tiptap-target='editorContainer']"
      end

      def test_rich_text_mode_renders_toolbar_by_default
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-flat-pack--tiptap-target='toolbar']"
      end

      def test_rich_text_mode_toolbar_none_hides_toolbar
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {toolbar: :none}))
        refute_selector "div[data-flat-pack--tiptap-target='toolbar']"
      end

      def test_rich_text_mode_renders_bubble_menu_by_default
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-flat-pack--tiptap-target='bubbleMenu']"
      end

      def test_rich_text_mode_no_floating_menu_by_default
        render_inline(Component.new(name: "body", rich_text: true))
        refute_selector "div[data-flat-pack--tiptap-target='floatingMenu']"
      end

      def test_rich_text_mode_floating_menu_rendered_when_enabled
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {floating_menu: true}))
        assert_selector "div[data-flat-pack--tiptap-target='floatingMenu']"
      end

      def test_rich_text_mode_bubble_menu_hidden_when_disabled
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {bubble_menu: false}))
        refute_selector "div[data-flat-pack--tiptap-target='bubbleMenu']"
      end

      # ── Hidden submission field ────────────────────────────────────────────

      def test_rich_text_mode_renders_hidden_field
        render_inline(Component.new(name: "post[body]", rich_text: true))
        assert_selector "input[type='hidden'][name='post[body]']", visible: false
      end

      def test_rich_text_mode_hidden_field_has_tiptap_target
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "input[data-flat-pack--tiptap-target='hiddenField']", visible: false
      end

      def test_rich_text_mode_hidden_field_contains_initial_value
        content = '{"type":"doc","content":[]}'
        render_inline(Component.new(name: "body", rich_text: true, value: content))
        # Initial value is passed via the Stimulus value attr on the wrapper,
        # not written directly on the hidden field until JS syncs.
        wrapper = page.find("[data-flat-pack--tiptap-value-value]", visible: false)
        assert_equal content, wrapper["data-flat-pack--tiptap-value-value"]
      end

      def test_rich_text_mode_disabled_disables_hidden_field
        render_inline(Component.new(name: "body", rich_text: true, disabled: true))
        assert_selector "input[type='hidden'][disabled]", visible: false
      end

      # ── Label and error ────────────────────────────────────────────────────

      def test_rich_text_mode_renders_label
        render_inline(Component.new(name: "body", rich_text: true, label: "Post body"))
        assert_selector "label", text: "Post body"
      end

      def test_rich_text_mode_label_for_matches_editor_id
        render_inline(Component.new(name: "body", rich_text: true, label: "Body", id: "post-body"))
        assert_selector "label[for='post-body']"
      end

      def test_rich_text_mode_renders_error_message
        render_inline(Component.new(name: "body", rich_text: true, error: "Body is required"))
        assert_selector "p.mt-1.text-sm", text: "Body is required"
      end

      def test_rich_text_mode_error_class_on_wrapper
        render_inline(Component.new(name: "body", rich_text: true, error: "Required"))
        assert_selector ".flat-pack-richtext--error"
      end

      def test_rich_text_mode_error_class_on_editor_container
        render_inline(Component.new(name: "body", rich_text: true, error: "Required"))
        assert_selector "div.flat-pack-richtext-editor.border-warning"
      end

      def test_rich_text_mode_no_error_uses_border_class
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div.flat-pack-richtext-editor"
        refute_selector "div.flat-pack-richtext-editor.border-warning"
      end

      # ── Stimulus controller data attributes ────────────────────────────────

      def test_rich_text_mode_passes_options_json_to_controller
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-flat-pack--tiptap-options-value]"
      end

      def test_rich_text_mode_options_json_includes_preset
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {preset: :content}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "content", json["preset"]
      end

      def test_rich_text_mode_options_json_includes_format
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {format: :html}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "html", json["format"]
      end

      def test_rich_text_mode_passes_editor_id_value
        render_inline(Component.new(name: "body", rich_text: true, id: "my-editor"))
        assert_selector "div[data-flat-pack--tiptap-editor-id-value='my-editor']"
      end

      def test_rich_text_mode_passes_placeholder_value
        render_inline(Component.new(name: "body", rich_text: true, placeholder: "Write here…"))
        assert_selector "div[data-flat-pack--tiptap-placeholder-value='Write here…']"
      end

      def test_rich_text_mode_passes_disabled_value
        render_inline(Component.new(name: "body", rich_text: true, disabled: true))
        assert_selector "div[data-flat-pack--tiptap-disabled-value='true']"
      end

      def test_rich_text_mode_passes_required_value
        render_inline(Component.new(name: "body", rich_text: true, required: true))
        assert_selector "div[data-flat-pack--tiptap-required-value='true']"
      end

      def test_rich_text_mode_passes_has_error_true_when_error_present
        render_inline(Component.new(name: "body", rich_text: true, error: "Required"))
        assert_selector "div[data-flat-pack--tiptap-has-error-value='true']"
      end

      def test_rich_text_mode_has_error_false_when_no_error
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector "div[data-flat-pack--tiptap-has-error-value='false']"
      end

      def test_rich_text_mode_passes_error_id_when_error_present
        render_inline(Component.new(name: "body", rich_text: true, id: "body-field", error: "Required"))
        assert_selector "div[data-flat-pack--tiptap-error-id-value='body-field_error']"
      end

      def test_rich_text_mode_initial_value_passed_to_controller
        render_inline(Component.new(name: "body", rich_text: true, value: '{"type":"doc"}'))
        assert_selector "div[data-flat-pack--tiptap-value-value='{\"type\":\"doc\"}']"
      end

      # ── Character count in rich text mode ─────────────────────────────────

      def test_rich_text_character_count_not_rendered_by_default
        render_inline(Component.new(name: "body", rich_text: true))
        refute_selector "[data-flat-pack--tiptap-target='characterCount']"
      end

      def test_rich_text_character_count_rendered_when_enabled_via_prop
        render_inline(Component.new(name: "body", rich_text: true, character_count: true))
        assert_selector "p[data-flat-pack--tiptap-target='characterCount']"
      end

      def test_rich_text_character_count_rendered_when_enabled_via_options
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {character_count: true}))
        assert_selector "p[data-flat-pack--tiptap-target='characterCount']"
      end

      # ── Disabled and required state ────────────────────────────────────────

      def test_rich_text_disabled_adds_class_to_wrapper
        render_inline(Component.new(name: "body", rich_text: true, disabled: true))
        assert_selector ".flat-pack-richtext--disabled"
      end

      def test_rich_text_required_adds_class_to_wrapper
        render_inline(Component.new(name: "body", rich_text: true, required: true))
        assert_selector ".flat-pack-richtext--required"
      end

      # ── Wrapper and CSS classes ────────────────────────────────────────────

      def test_rich_text_wrapper_has_correct_classes
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector ".flat-pack-input-wrapper.flat-pack-richtext-wrapper"
      end

      def test_rich_text_custom_class_applied_to_wrapper
        render_inline(Component.new(name: "body", rich_text: true, class: "my-editor"))
        assert_selector ".flat-pack-richtext-wrapper.my-editor"
      end

      def test_rich_text_editor_container_has_correct_class
        render_inline(Component.new(name: "body", rich_text: true))
        assert_selector ".flat-pack-richtext-editor"
      end

      # ── Preset options serialization ───────────────────────────────────────

      def test_bubble_menu_true_reflected_in_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {bubble_menu: true}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal true, json["bubble_menu"]
      end

      def test_bubble_menu_false_reflected_in_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {bubble_menu: false}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal false, json["bubble_menu"]
      end

      def test_minimal_preset_reflected_in_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {preset: :minimal}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "minimal", json["preset"]
      end

      def test_full_preset_reflected_in_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {preset: :full}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "full", json["preset"]
      end

      def test_html_format_reflected_in_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {format: :html}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "html", json["format"]
      end

      def test_html_format_is_default_in_options_json
        render_inline(Component.new(name: "body", rich_text: true))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "html", json["format"]
      end

      def test_json_format_explicit_still_works
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {format: :json}))
        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])
        assert_equal "json", json["format"]
      end

      def test_addons_are_serialized_into_options_json
        render_inline(Component.new(name: "body", rich_text: true, rich_text_options: {
          addons: [
            :task_item_plus,
            {name: :callout_box, options: {tone: "info"}}
          ]
        }))

        wrapper = page.find("[data-flat-pack--tiptap-options-value]")
        json = JSON.parse(wrapper["data-flat-pack--tiptap-options-value"])

        assert_equal [
          "task_item_plus",
          {"name" => "callout_box", "options" => {"tone" => "info"}}
        ], json["addons"]
      end

      # ── RichTextOptions validation ─────────────────────────────────────────

      def test_invalid_format_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {format: :xml})
        end
      end

      def test_invalid_preset_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {preset: :super})
        end
      end

      def test_invalid_toolbar_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {toolbar: :mega})
        end
      end

      def test_custom_toolbar_array_is_valid
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rich_text_options: {toolbar: ["bold", "italic"]})
        end
      end

      def test_invalid_bubble_menu_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {bubble_menu: "yes"})
        end
      end

      def test_invalid_readonly_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {readonly: "1"})
        end
      end

      def test_invalid_extensions_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {extensions: "all"})
        end
      end

      def test_invalid_addons_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {addons: "callout"})
        end
      end

      def test_invalid_addon_descriptor_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {addons: [123]})
        end
      end

      def test_invalid_addon_hash_without_name_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {addons: [{options: {}}]})
        end
      end

      def test_invalid_addon_hash_options_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {
            addons: [{name: :callout_box, options: "bad"}]
          })
        end
      end

      def test_string_keys_are_normalized
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rich_text_options: {"format" => "json", "preset" => "minimal"})
        end
      end

      def test_string_enum_values_are_normalized
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rich_text_options: {format: "html", preset: "content"})
        end
      end

      def test_mentions_hash_config_is_valid
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rich_text_options: {
            preset: :full, mentions: {suggestion: {}}
          })
        end
      end

      def test_collaboration_hash_config_is_valid
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rich_text_options: {
            preset: :full, collaboration: {provider: nil}
          })
        end
      end

      def test_invalid_placeholder_type_raises_argument_error
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: {placeholder: 42})
        end
      end

      def test_rich_text_options_hash_required
        assert_raises(ArgumentError) do
          Component.new(name: "body", rich_text: true, rich_text_options: "bad")
        end
      end

      # ── Rows validation skipped in rich text mode ──────────────────────────

      def test_rows_zero_allowed_in_rich_text_mode
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true, rows: 0)
        end
      end

      def test_character_limit_order_not_validated_in_rich_text_mode
        assert_nothing_raised do
          Component.new(name: "body", rich_text: true,
            character_count: true, min_characters: 100, max_characters: 50)
        end
      end
    end
  end
end
