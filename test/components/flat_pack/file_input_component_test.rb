# frozen_string_literal: true

require "test_helper"

module FlatPack
  module FileInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_file_input_with_name
        render_inline(Component.new(name: "document"))

        assert_selector "input[type='file'][name='document']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "document", label: "Upload Document"))

        assert_selector "label", text: "Upload Document"
        assert_selector "input[type='file']"
      end

      def test_renders_help_text
        render_inline(Component.new(name: "document", id: "document", help_text: "Upload a PDF smaller than 5 MB."))

        assert_selector "p#document_help_text", text: "Upload a PDF smaller than 5 MB."
        assert_selector "input[aria-describedby='document_help_text']", visible: :all
      end

      def test_label_for_attribute_matches_input_id
        render_inline(Component.new(name: "document", label: "Document", id: "doc-input"))

        assert_selector "label[for='doc-input']"
        assert_selector "input#doc-input"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "document", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "document", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "document", error: "File is required"))

        assert_selector "p", text: "File is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "document", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-error)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "document", class: "custom-input-class"))

        assert_selector "div.custom-input-class"
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "document", data: {test: "value"}))

        assert_selector "input[data-test='value']"
      end

      def test_renders_with_custom_id
        render_inline(Component.new(name: "document", id: "my-custom-id"))

        assert_selector "input#my-custom-id"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "document"))

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
        render_inline(Component.new(name: "document", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_accept_attribute
        render_inline(Component.new(name: "document", accept: "image/*"))

        assert_selector "input[accept='image/*']"
      end

      def test_renders_with_multiple_attribute
        render_inline(Component.new(name: "documents", multiple: true))

        assert_selector "input[multiple]"
      end

      def test_renders_without_multiple_by_default
        render_inline(Component.new(name: "document"))

        refute_selector "input[multiple]"
      end

      def test_renders_dropzone
        render_inline(Component.new(name: "document"))

        assert_selector "div[data-controller='flat-pack--file-input']"
        assert_text "Upload a file"
        assert_text "or drag and drop"
      end

      def test_renders_hidden_file_input
        render_inline(Component.new(name: "document"))

        assert_selector "input[type='file'].hidden"
      end

      def test_renders_upload_trigger_button
        render_inline(Component.new(name: "document"))

        assert_selector "button[type='button'][data-action='flat-pack--file-input#clickInput']", text: "Upload a file"
      end

      def test_renders_stimulus_controller
        render_inline(Component.new(name: "document"))

        assert_selector "[data-controller='flat-pack--file-input']"
      end

      def test_renders_stimulus_targets
        render_inline(Component.new(name: "document"))

        assert_selector "[data-flat-pack--file-input-target='input']"
        assert_selector "[data-flat-pack--file-input-target='fileList']"
      end

      def test_renders_preview_target_when_preview_enabled
        render_inline(Component.new(name: "document", preview: true))

        assert_selector "[data-flat-pack--file-input-target='preview']"
      end

      def test_does_not_render_preview_target_when_preview_disabled
        render_inline(Component.new(name: "document", preview: false))

        refute_selector "[data-flat-pack--file-input-target='preview']"
      end

      def test_renders_with_max_size
        render_inline(Component.new(name: "document", max_size: 5_242_880)) # 5MB

        assert_selector "[data-flat-pack--file-input-max-size-value='5242880']"
      end

      def test_displays_max_size_in_constraints
        render_inline(Component.new(name: "document", max_size: 5_242_880))

        assert_text "Max size: 5.0MB"
      end

      def test_displays_accept_types_in_constraints
        render_inline(Component.new(name: "document", accept: "image/png, image/jpeg"))

        assert_text "image/png, image/jpeg"
      end

      def test_displays_combined_constraints
        render_inline(Component.new(
          name: "document",
          accept: "image/*",
          max_size: 1_048_576
        ))

        assert_text "image/*"
        assert_text "Max size: 1.0MB"
      end

      def test_raises_error_with_negative_max_size
        assert_raises(ArgumentError, match: /max_size must be a positive number/) do
          Component.new(name: "document", max_size: -1)
        end
      end

      def test_raises_error_with_zero_max_size
        assert_raises(ArgumentError, match: /max_size must be a positive number/) do
          Component.new(name: "document", max_size: 0)
        end
      end

      def test_raises_error_with_dangerous_exe_extension
        assert_raises(ArgumentError, match: /File type .exe is not allowed/) do
          Component.new(name: "document", accept: ".exe")
        end
      end

      def test_raises_error_with_dangerous_bat_extension
        assert_raises(ArgumentError, match: /File type .bat is not allowed/) do
          Component.new(name: "document", accept: ".bat")
        end
      end

      def test_raises_error_with_dangerous_sh_extension
        assert_raises(ArgumentError, match: /File type .sh is not allowed/) do
          Component.new(name: "document", accept: ".sh")
        end
      end

      def test_raises_error_with_dangerous_js_extension
        assert_raises(ArgumentError, match: /File type .js is not allowed/) do
          Component.new(name: "document", accept: ".js")
        end
      end

      def test_accepts_safe_image_types
        assert_nothing_raised do
          render_inline(Component.new(name: "document", accept: "image/png,image/jpeg,image/gif"))
        end

        assert_selector "input[accept='image/png,image/jpeg,image/gif']"
      end

      def test_accepts_safe_document_types
        assert_nothing_raised do
          render_inline(Component.new(name: "document", accept: ".pdf,.doc,.docx"))
        end

        assert_selector "input[accept='.pdf,.doc,.docx']"
      end

      def test_formats_file_size_bytes
        render_inline(Component.new(name: "document", max_size: 500))

        assert_text "Max size: 500B"
      end

      def test_formats_file_size_kilobytes
        render_inline(Component.new(name: "document", max_size: 10_240))

        assert_text "Max size: 10.0KB"
      end

      def test_formats_file_size_megabytes
        render_inline(Component.new(name: "document", max_size: 10_485_760))

        assert_text "Max size: 10.0MB"
      end

      def test_renders_upload_icon
        render_inline(Component.new(name: "document"))

        assert_selector "svg[viewbox='0 0 24 24']"
      end

      def test_renders_drag_and_drop_actions
        render_inline(Component.new(name: "document"))

        html = page.native.to_html
        assert_includes html, "dragover-&gt;flat-pack--file-input#dragOver"
        assert_includes html, "dragenter-&gt;flat-pack--file-input#dragEnter"
        assert_includes html, "dragleave-&gt;flat-pack--file-input#dragLeave"
        assert_includes html, "drop-&gt;flat-pack--file-input#drop"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "document",
          disabled: false,
          required: true,
          label: "Upload Document",
          accept: "application/pdf",
          multiple: true,
          max_size: 5_242_880,
          preview: true,
          class: "custom-class"
        ))

        assert_selector "label", text: "Upload Document"
        assert_selector "input[type='file'][name='document']"
        assert_selector "input[required]"
        assert_selector "input[accept='application/pdf']"
        assert_selector "input[multiple]"
        assert_selector "div.custom-class"
        assert_selector "[data-flat-pack--file-input-max-size-value='5242880']"
        assert_selector "[data-flat-pack--file-input-preview-value='true']"
        assert_selector "[data-flat-pack--file-input-multiple-value='true']"
      end

      def test_defaults_to_dropzone_variant
        render_inline(Component.new(name: "document"))

        assert_selector "[data-flat-pack--file-input-target='fileList']"
        assert_text "Upload a file"
        assert_text "or drag and drop"
        refute_selector "input.sr-only", visible: :all
      end

      def test_button_variant_renders_one_tab_stop_and_skips_the_file_list
        render_inline(Component.new(name: "document", variant: :button, text: "Choose a file", id: "pick"))

        assert_selector "button", text: "Choose a file", count: 1
        assert_selector "button[data-action='flat-pack--file-input#clickInput'][data-flat-pack--file-input-target='button']"
        assert_selector "input#pick.sr-only[type='file'][tabindex='-1']", visible: :all
        assert_selector "input#pick[aria-label='Choose a file']", visible: :all
        refute_selector "input.hidden", visible: :all
        refute_selector "[data-flat-pack--file-input-target='fileList']"
        refute_selector "[data-flat-pack--file-input-target='preview']"
        refute_text "or drag and drop"
        assert_equal 1, page.all("a, button, input:not([tabindex='-1']), select, textarea", visible: :all).size
      end

      def test_button_variant_uses_choose_copy_when_text_is_omitted
        render_inline(Component.new(name: "document", variant: :button))

        assert_selector "button", text: "Choose a file"
      end

      def test_button_variant_passes_style_size_round_and_icon_to_button
        render_inline(Component.new(
          name: "document",
          variant: :button,
          text: "Choose",
          style: :secondary,
          size: :sm,
          round: true,
          icon: "arrow-up-tray",
          class: "custom-file-button"
        ))

        assert_selector "button.custom-file-button[data-fp-style='secondary']", text: "Choose"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-sm)]"
        assert_includes page.native.to_html, "rounded-[var(--button-round-border-radius)]"
        assert_selector "button svg"
        assert_selector "[data-flat-pack--file-input-show-list-value='false']"
      end

      def test_button_variant_disables_the_button_and_the_input
        render_inline(Component.new(name: "document", variant: :button, text: "Choose", disabled: true))

        assert_selector "button[disabled]", text: "Choose"
        assert_selector "input[disabled]", visible: :all
      end

      def test_actions_slot_renders_beside_the_dropzone
        component = Component.new(name: "document")
        component.actions { "Host progress" }
        render_inline(component)

        assert_selector "[data-flat-pack-file-input-actions]", text: "Host progress"
        refute_selector "[data-controller='flat-pack--file-input'] [data-flat-pack-file-input-actions]"
      end

      def test_actions_slot_renders_beside_the_button
        component = Component.new(name: "document", variant: :button, text: "Choose")
        component.actions { "Host progress" }
        render_inline(component)

        assert_selector "[data-flat-pack-file-input-actions]", text: "Host progress"
        refute_selector "[data-controller='flat-pack--file-input'] [data-flat-pack-file-input-actions]"
      end

      def test_max_files_exposes_the_cap_and_an_accessible_message
        render_inline(Component.new(name: "document", id: "doc", max_files: 2, help_text: "Keep it small."))

        assert_selector "[data-flat-pack--file-input-max-files-value='2']"
        assert_selector "[data-flat-pack--file-input-limit-message-value='Only the first 2 files were kept.']"
        assert_selector "p#doc_limit.hidden[role='status'][aria-live='polite']", visible: :all
        assert_selector "input[aria-describedby='doc_help_text doc_limit']", visible: :all
      end

      def test_max_files_one_uses_the_singular_message
        render_inline(Component.new(name: "document", variant: :button, text: "Choose", max_files: 1, id: "solo"))

        assert_selector "[data-flat-pack--file-input-limit-message-value='Only the first file was kept.']"
        assert_selector "input#solo[aria-describedby='solo_limit']", visible: :all
      end

      def test_raises_for_an_unknown_variant
        error = assert_raises(ArgumentError) { Component.new(name: "document", variant: :tape) }

        assert_match(/variant must be one of: dropzone, button/, error.message)
      end

      def test_raises_when_max_files_is_not_a_positive_integer
        assert_raises(ArgumentError, match: /max_files must be a positive integer/) do
          Component.new(name: "document", max_files: 0)
        end

        assert_raises(ArgumentError, match: /max_files must be a positive integer/) do
          Component.new(name: "document", max_files: 2.5)
        end
      end

      def test_dropzone_renders_the_file_list_by_default
        render_inline(Component.new(name: "document", preview: true))

        assert_selector "[data-flat-pack--file-input-target='fileList']", visible: :all
        assert_selector "[data-flat-pack--file-input-target='preview']", visible: :all
        assert_selector "[data-flat-pack--file-input-show-list-value='true']"
      end

      def test_show_file_list_false_omits_list_markup
        render_inline(Component.new(name: "stems", id: "stems", preview: true, show_file_list: false, multiple: true))

        refute_selector "[data-flat-pack--file-input-target='fileList']", visible: :all
        refute_selector "[data-flat-pack--file-input-target='preview']", visible: :all
        assert_selector "[data-flat-pack--file-input-show-list-value='false']"
        assert_selector "[data-flat-pack--file-input-preview-value='false']"
        assert_selector "input#stems[type='file'][multiple]", visible: :all
        assert_text "Upload a file"
        assert_text "or drag and drop"
      end

      def test_button_variant_has_no_file_list_when_show_file_list_is_true
        render_inline(Component.new(name: "document", variant: :button, text: "Choose", show_file_list: true))

        refute_selector "[data-flat-pack--file-input-target='fileList']", visible: :all
        refute_selector "[data-flat-pack--file-input-target='preview']", visible: :all
        assert_selector "[data-flat-pack--file-input-show-list-value='false']"
      end

      def test_raises_when_button_options_are_used_on_the_dropzone
        error = assert_raises(ArgumentError) do
          Component.new(name: "document", text: "Choose", style: :primary)
        end

        assert_match(/text, style are only for variant: :button/, error.message)
      end
    end
  end
end
