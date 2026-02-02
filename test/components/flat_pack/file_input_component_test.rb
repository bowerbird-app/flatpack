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
        assert_includes html, "border-[var(--color-warning)]"
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
        assert_text "Click to upload"
        assert_text "or drag and drop"
      end

      def test_renders_hidden_file_input
        render_inline(Component.new(name: "document"))

        assert_selector "input[type='file'].hidden"
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

        assert_selector "svg[viewBox='0 0 48 48']"
      end

      def test_renders_drag_and_drop_actions
        render_inline(Component.new(name: "document"))

        html = page.native.to_html
        assert_includes html, "dragover->flat-pack--file-input#dragOver"
        assert_includes html, "dragenter->flat-pack--file-input#dragEnter"
        assert_includes html, "dragleave->flat-pack--file-input#dragLeave"
        assert_includes html, "drop->flat-pack--file-input#drop"
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
    end
  end
end
