# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Flash
    class ComponentTest < ViewComponent::TestCase
      def test_maps_default_keys_to_alert_styles
        render_inline(Component.new(flash: sample_flash, as: :alert))

        assert_style "notice", "bg-[var(--alert-success-background-color)]", role: "alert"
        assert_style "alert", "bg-[var(--alert-danger-background-color)]", role: "alert"
        assert_style "warning", "bg-[var(--alert-warning-background-color)]", role: "alert"
        assert_style "info", "bg-[var(--alert-info-background-color)]", role: "alert"
        assert_style "success", "bg-[var(--alert-success-background-color)]", role: "alert"
        assert_style "error", "bg-[var(--alert-danger-background-color)]", role: "alert"
        assert_style "danger", "bg-[var(--alert-danger-background-color)]", role: "alert"
        assert_style "other", "bg-[var(--alert-info-background-color)]", role: "alert"
      end

      def test_maps_default_keys_to_toast_styles
        render_inline(Component.new(flash: sample_flash, as: :toast))

        assert_selector ".fp-toast-region"
        assert_style "notice", "bg-[var(--toast-success-background-color)]", role: "status"
        assert_style "alert", "bg-[var(--toast-danger-background-color)]", role: "status"
        assert_style "warning", "bg-[var(--toast-warning-background-color)]", role: "status"
        assert_style "info", "bg-[var(--toast-info-background-color)]", role: "status"
        assert_style "success", "bg-[var(--toast-success-background-color)]", role: "status"
        assert_style "error", "bg-[var(--toast-danger-background-color)]", role: "status"
        assert_style "danger", "bg-[var(--toast-danger-background-color)]", role: "status"
        assert_style "other", "bg-[var(--toast-info-background-color)]", role: "status"
        assert_selector "[data-controller='flat-pack--toast']", count: 8
        assert_selector "[data-flat-pack--toast-timeout-value='5000']", count: 8
        refute_includes rendered_content, "flat-pack--flash"
      end

      def test_styles_override_merges_over_the_defaults
        render_inline(Component.new(
          flash: {notice: "Kept", saved: "Custom"},
          as: :alert,
          styles: {"notice" => "warning", "saved" => "success"}
        ))

        assert_style "Kept", "bg-[var(--alert-warning-background-color)]", role: "alert"
        assert_style "Custom", "bg-[var(--alert-success-background-color)]", role: "alert"
      end

      def test_toast_mode_uses_the_same_style_override
        render_inline(Component.new(
          flash: {saved: "Custom"},
          as: :toast,
          styles: {saved: :success}
        ))

        assert_style "Custom", "bg-[var(--toast-success-background-color)]", role: "status"
      end

      def test_skips_blank_values
        render_inline(Component.new(
          flash: {notice: "  ", alert: "", info: nil, warning: [], success: [nil, "", "   "]},
          as: :alert
        ))

        assert_equal "", rendered_content.strip
      end

      def test_renders_each_array_entry_and_skips_blanks_inside_it
        render_inline(Component.new(flash: {alert: ["First", " ", nil, "Second"]}, as: :alert))

        assert_selector "[role='alert']", count: 2
        assert_match(/First.*Second/m, page.text)
      end

      def test_escapes_string_and_html_safe_messages
        render_inline(Component.new(
          flash: {
            notice: "<script>alert(1)</script>",
            alert: "<b>bold</b>".html_safe
          },
          as: :alert
        ))

        html = rendered_content

        refute_selector "script"
        refute_selector "b"
        assert_includes html, "&lt;script&gt;alert(1)&lt;/script&gt;"
        assert_includes html, "&lt;b&gt;bold&lt;/b&gt;"
        refute_includes html, "<b>bold</b>"
        refute_includes html, "<script>alert(1)</script>"
      end

      def test_escapes_toast_messages
        render_inline(Component.new(flash: {notice: "<b>bold</b>".html_safe}, as: :toast))

        refute_selector "b"
        assert_includes rendered_content, "&lt;b&gt;bold&lt;/b&gt;"
      end

      def test_skips_values_that_are_not_strings_or_arrays
        render_inline(Component.new(flash: {notice: "Hi", picker: {id: 1}}, as: :alert))

        assert_selector "[role='alert']", count: 1
        assert_text "Hi"
        refute_includes rendered_content, "{:id"
      end

      def test_accepts_string_keys_and_a_flash_hash
        flash_hash = ActionDispatch::Flash::FlashHash.new
        flash_hash[:notice] = "From the hash"
        flash_hash["alert"] = ["One", "Two"]

        render_inline(Component.new(flash: flash_hash, as: :toast))

        assert_style "From the hash", "bg-[var(--toast-success-background-color)]", role: "status"
        assert_style "One", "bg-[var(--toast-danger-background-color)]", role: "status"
        assert_style "Two", "bg-[var(--toast-danger-background-color)]", role: "status"
      end

      def test_alert_mode_stacks_with_spacing_and_forwards_attributes
        render_inline(Component.new(flash: {notice: "Hi", alert: "No"}, as: :alert, id: "flash-stack", class: "mb-4"))

        stack = page.find("#flash-stack")

        assert_includes stack[:class], "flex"
        assert_includes stack[:class], "flex-col"
        assert_includes stack[:class], "gap-4"
        assert_includes stack[:class], "mb-4"
        assert_selector "#flash-stack [role='alert']", count: 2
        refute_selector ".fp-toast-region"
      end

      def test_toast_mode_forwards_attributes_to_the_region
        render_inline(Component.new(flash: {notice: "Hi"}, as: :toast, id: "flash-toasts"))

        assert_selector "#flash-toasts.fp-toast-region[aria-live='polite']"
        assert_selector "#flash-toasts [data-controller='flat-pack--toast']"
      end

      def test_raises_for_an_unknown_mode
        error = assert_raises(ArgumentError) do
          Component.new(flash: {notice: "Hi"}, as: :banner)
        end

        assert_includes error.message, "Invalid as"
      end

      def test_raises_for_an_invalid_style_override
        error = assert_raises(ArgumentError) do
          Component.new(flash: {notice: "Hi"}, as: :alert, styles: {notice: :primary})
        end

        assert_includes error.message, "Invalid style"
      end

      def test_raises_when_styles_is_not_a_hash
        assert_raises(ArgumentError) do
          Component.new(flash: {notice: "Hi"}, as: :alert, styles: [:success])
        end
      end

      def test_raises_when_flash_is_missing_or_not_a_hash
        assert_raises(ArgumentError) do
          Component.new(as: :alert)
        end

        assert_raises(ArgumentError) do
          Component.new(flash: nil, as: :alert)
        end

        assert_raises(ArgumentError) do
          Component.new(flash: "Hi", as: :alert)
        end
      end

      private

      def sample_flash
        {
          "notice" => "notice",
          :alert => "alert",
          :warning => "warning",
          :info => "info",
          :success => "success",
          :error => "error",
          :danger => "danger",
          :other => "other"
        }
      end

      def assert_style(text, class_name, role:)
        node = page.find("[role='#{role}']", text: text)
        assert_includes node[:class], class_name
      end
    end
  end
end
