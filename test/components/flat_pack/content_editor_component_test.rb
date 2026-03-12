# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ContentEditor
    class ComponentTest < ViewComponent::TestCase
      # ── Stimulus controller wrapper ───────────────────────────────────────

      def test_renders_stimulus_controller_wrapper
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "div[data-controller='flat-pack--content-editor']"
      end

      def test_wrapper_has_update_url_value
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "div[data-flat-pack--content-editor-update-url-value='/articles/1']"
      end

      def test_wrapper_has_upload_url_value_when_provided
        render_inline(Component.new(update_url: "/articles/1", upload_url: "/articles/1/upload"))
        assert_selector "div[data-flat-pack--content-editor-upload-url-value='/articles/1/upload']"
      end

      def test_wrapper_omits_upload_url_attribute_when_nil
        render_inline(Component.new(update_url: "/articles/1"))
        refute_selector "div[data-flat-pack--content-editor-upload-url-value]"
      end

      def test_wrapper_has_field_name_value
        render_inline(Component.new(update_url: "/articles/1", field_name: "article[body]"))
        assert_selector "div[data-flat-pack--content-editor-field-name-value='article[body]']"
      end

      def test_wrapper_has_field_format_name_value
        render_inline(Component.new(update_url: "/articles/1", field_format_name: "article[body_format]"))
        assert_selector "div[data-flat-pack--content-editor-field-format-name-value='article[body_format]']"
      end

      # ── Action bar buttons ────────────────────────────────────────────────

      def test_renders_edit_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-flat-pack--content-editor-target='editBtn']"
        assert_selector "button[data-action='flat-pack--content-editor#enableEditing']"
      end

      def test_renders_save_button_hidden
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-flat-pack--content-editor-target='saveBtn'][hidden]", visible: false
        assert_selector "button[data-action='flat-pack--content-editor#save']", visible: false
      end

      def test_renders_cancel_button_hidden
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-flat-pack--content-editor-target='cancelBtn'][hidden]", visible: false
        assert_selector "button[data-action='flat-pack--content-editor#cancel']", visible: false
      end

      def test_action_bar_uses_primary_class_for_edit
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button.flat-pack-btn.flat-pack-btn--primary[data-flat-pack--content-editor-target='editBtn']"
      end

      def test_action_bar_uses_secondary_class_for_cancel
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button.flat-pack-btn.flat-pack-btn--secondary[data-flat-pack--content-editor-target='cancelBtn']", visible: false
      end

      # ── Balloon toolbar ───────────────────────────────────────────────────

      def test_renders_balloon_toolbar_when_toolbar_true
        render_inline(Component.new(update_url: "/articles/1", toolbar: true))
        assert_selector "div[data-flat-pack--content-editor-target='balloonToolbar']", visible: false
        assert_selector ".flat-pack-richtext-bubble-menu", visible: false
      end

      def test_omits_balloon_toolbar_when_toolbar_false
        render_inline(Component.new(update_url: "/articles/1", toolbar: false))
        refute_selector "div[data-flat-pack--content-editor-target='balloonToolbar']", visible: false
        refute_selector ".flat-pack-richtext-bubble-menu", visible: false
      end

      def test_toolbar_has_keep_selection_action
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector ".flat-pack-richtext-bubble-menu[data-action='mousedown->flat-pack--content-editor#keepSelection']", visible: false
      end

      def test_toolbar_is_hidden_by_default
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector ".flat-pack-richtext-bubble-menu[hidden]", visible: false
      end

      # ── Toolbar formatting buttons ────────────────────────────────────────

      def test_toolbar_contains_bold_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='bold']", visible: false
      end

      def test_toolbar_contains_italic_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='italic']", visible: false
      end

      def test_toolbar_contains_underline_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='underline']", visible: false
      end

      def test_toolbar_contains_strikethrough_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='strikeThrough']", visible: false
      end

      def test_toolbar_contains_heading_buttons
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='h1']", visible: false
        assert_selector "button[data-command='h2']", visible: false
        assert_selector "button[data-command='h3']", visible: false
      end

      def test_toolbar_contains_list_buttons
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='insertUnorderedList']", visible: false
        assert_selector "button[data-command='insertOrderedList']", visible: false
      end

      def test_toolbar_contains_blockquote_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='blockquote']", visible: false
      end

      def test_toolbar_contains_link_button
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "button[data-command='link']", visible: false
      end

      # ── Image upload button ───────────────────────────────────────────────

      def test_toolbar_contains_image_button_when_upload_url_present
        render_inline(Component.new(update_url: "/articles/1", upload_url: "/articles/1/upload"))
        assert_selector "button[data-action='flat-pack--content-editor#triggerImageUpload']", visible: false
      end

      def test_toolbar_contains_image_input_when_upload_url_present
        render_inline(Component.new(update_url: "/articles/1", upload_url: "/articles/1/upload"))
        assert_selector "input[type='file'][data-flat-pack--content-editor-target='imageInput']", visible: false
      end

      def test_toolbar_omits_image_button_when_upload_url_nil
        render_inline(Component.new(update_url: "/articles/1"))
        refute_selector "button[data-action='flat-pack--content-editor#triggerImageUpload']", visible: false
      end

      def test_toolbar_omits_image_input_when_upload_url_nil
        render_inline(Component.new(update_url: "/articles/1"))
        refute_selector "input[data-flat-pack--content-editor-target='imageInput']", visible: false
      end

      # ── Content region ────────────────────────────────────────────────────

      def test_content_region_has_display_content_target
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "div[data-flat-pack--content-editor-target='displayContent']"
      end

      def test_content_region_renders_yielded_html
        render_inline(Component.new(update_url: "/articles/1")) { "<p>Hello world</p>".html_safe }
        assert_selector "div[data-flat-pack--content-editor-target='displayContent'] p", text: "Hello world"
      end

      def test_content_class_applied_to_content_region
        render_inline(Component.new(update_url: "/articles/1", content_class: "prose max-w-none"))
        assert_selector "div.prose.max-w-none[data-flat-pack--content-editor-target='displayContent']"
      end

      def test_content_region_without_content_class
        render_inline(Component.new(update_url: "/articles/1"))
        assert_selector "div[data-flat-pack--content-editor-target='displayContent']"
      end
    end
  end
end
