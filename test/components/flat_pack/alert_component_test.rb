# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Alert
    class ComponentTest < ViewComponent::TestCase
      def test_renders_alert_with_title
        render_inline(Component.new(title: "Success"))

        assert_selector "div[role='alert']"
        assert_selector "h3", text: "Success"
      end

      def test_renders_alert_with_description
        render_inline(Component.new(description: "Your changes have been saved."))

        assert_selector "div[role='alert']"
        assert_selector "p", text: "Your changes have been saved."
      end

      def test_renders_alert_with_title_and_description
        render_inline(Component.new(title: "Success", description: "Your changes have been saved."))

        assert_selector "div[role='alert']"
        assert_selector "h3", text: "Success"
        assert_selector "p", text: "Your changes have been saved."
      end

      def test_renders_info_style
        render_inline(Component.new(title: "Info", style: :info))

        assert_selector "div[role='alert']"
        assert_includes page.native.to_html, "border-blue-500"
        assert_includes page.native.to_html, "bg-blue-50"
      end

      def test_renders_success_style
        render_inline(Component.new(title: "Success", style: :success))

        assert_selector "div[role='alert']"
        assert_includes page.native.to_html, "border-green-500"
        assert_includes page.native.to_html, "bg-green-50"
      end

      def test_renders_warning_style
        render_inline(Component.new(title: "Warning", style: :warning))

        assert_selector "div[role='alert']"
        assert_includes page.native.to_html, "border-orange-500"
        assert_includes page.native.to_html, "bg-orange-50"
      end

      def test_renders_danger_style
        render_inline(Component.new(title: "Danger", style: :danger))

        assert_selector "div[role='alert']"
        assert_includes page.native.to_html, "border-red-500"
        assert_includes page.native.to_html, "bg-red-50"
      end

      def test_default_style_is_info
        render_inline(Component.new(title: "Default"))

        assert_includes page.native.to_html, "border-blue-500"
      end

      def test_renders_with_icon_by_default
        render_inline(Component.new(title: "With Icon"))

        assert_selector "svg"
      end

      def test_renders_without_icon_when_disabled
        render_inline(Component.new(title: "No Icon", icon: false))

        refute_selector "svg"
      end

      def test_renders_info_icon
        render_inline(Component.new(title: "Info", style: :info))

        assert_selector "svg"
      end

      def test_renders_success_icon
        render_inline(Component.new(title: "Success", style: :success))

        assert_selector "svg"
      end

      def test_renders_warning_icon
        render_inline(Component.new(title: "Warning", style: :warning))

        assert_selector "svg"
      end

      def test_renders_danger_icon
        render_inline(Component.new(title: "Danger", style: :danger))

        assert_selector "svg"
      end

      def test_renders_non_dismissible_by_default
        render_inline(Component.new(title: "Alert"))

        refute_selector "button[aria-label='Dismiss']"
      end

      def test_renders_dismissible_alert
        render_inline(Component.new(title: "Dismissible", dismissible: true))

        assert_selector "button[aria-label='Dismiss']"
        assert_selector "button[data-action='alert#dismiss']"
      end

      def test_dismissible_alert_has_controller_data
        render_inline(Component.new(title: "Dismissible", dismissible: true))

        assert_selector "div[data-controller='alert']"
        assert_selector "div[data-alert-target='alert']"
      end

      def test_non_dismissible_alert_has_no_controller_data
        render_inline(Component.new(title: "Not Dismissible"))

        refute_selector "div[data-controller='alert']"
      end

      def test_renders_with_slot_content
        render_inline(Component.new(style: :success)) do
          "<strong>Success!</strong> You've completed the tutorial.".html_safe
        end

        assert_selector "div[role='alert']"
        assert_selector "strong", text: "Success!"
        assert_text "You've completed the tutorial."
      end

      def test_slot_content_takes_precedence_over_title_and_description
        render_inline(Component.new(title: "Title", description: "Description")) do
          "Custom content"
        end

        assert_text "Custom content"
        refute_selector "h3", text: "Title"
        refute_selector "p", text: "Description"
      end

      def test_raises_error_for_invalid_style
        assert_raises(ArgumentError) do
          Component.new(title: "Invalid", style: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(title: "Custom", class: "custom-class"))

        assert_selector "div.custom-class[role='alert']"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(title: "Data", data: {testid: "alert"}))

        assert_selector "div[data-testid='alert']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(title: "Aria", aria: {live: "polite"}))

        assert_selector "div[aria-live='polite']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(title: "ID", id: "my-alert"))

        assert_selector "div#my-alert[role='alert']"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(title: "Alert", onclick: "alert('xss')"))

        refute_selector "div[onclick]"
      end

      def test_renders_empty_alert_with_slot
        render_inline(Component.new) do
          "Slot content only"
        end

        assert_selector "div[role='alert']"
        assert_text "Slot content only"
      end
    end
  end
end
