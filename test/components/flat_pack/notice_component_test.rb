# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Notice
    class ComponentTest < ViewComponent::TestCase
      def test_renders_status_role
        render_inline(Component.new(title: "Saved"))

        assert_selector "div[role='status']"
        refute_selector "[role='alert']"
        assert_selector "h3", text: "Saved"
      end

      def test_renders_title_and_description
        render_inline(Component.new(title: "Saved", description: "The take is in the library."))

        assert_selector "div[role='status']"
        assert_selector "h3", text: "Saved"
        assert_selector "p", text: "The take is in the library."
      end

      def test_default_style_is_info
        render_inline(Component.new(title: "Heads up"))

        assert_includes page.native.to_html, "bg-[var(--alert-info-background-color)]"
        assert_includes page.native.to_html, "border-[var(--alert-info-border-color)]"
        assert_includes page.native.to_html, "text-[var(--alert-info-text-color)]"
      end

      def test_renders_success_style
        render_inline(Component.new(title: "Saved", style: :success))

        assert_selector "div[role='status']"
        assert_includes page.native.to_html, "bg-[var(--alert-success-background-color)]"
        assert_includes page.native.to_html, "text-[var(--alert-success-text-color)]"
      end

      def test_raises_for_warning_danger_and_unknown_styles
        %i[warning danger invalid].each do |style|
          assert_raises(ArgumentError) do
            Component.new(title: "Nope", style: style)
          end
        end
      end

      def test_renders_with_icon_by_default
        render_inline(Component.new(title: "Saved", style: :success))

        assert_selector "svg"
      end

      def test_renders_without_icon_when_disabled
        render_inline(Component.new(title: "Saved", icon: false))

        refute_selector "svg"
      end

      def test_renders_dismissible_notice
        render_inline(Component.new(title: "Dismissible", dismissible: true))

        assert_selector "div[role='status'][data-controller='flat-pack--alert']"
        assert_selector "div[data-flat-pack--alert-target='alert']"
        assert_selector "button.fp-button[data-fp-style='ghost'][aria-label='Dismiss'][data-action='flat-pack--alert#dismiss']"
        assert_selector ".fp-alert__dismiss"
      end

      def test_non_dismissible_notice_has_no_controller
        render_inline(Component.new(title: "Stay"))

        refute_selector "[data-controller='flat-pack--alert']"
        refute_selector "button[aria-label='Dismiss']"
      end

      def test_renders_with_slot_content
        render_inline(Component.new(style: :success)) do
          "<strong>Saved.</strong> The take is in the library.".html_safe
        end

        assert_selector "div[role='status']"
        assert_selector "strong", text: "Saved."
        assert_text "The take is in the library."
      end

      def test_slot_content_takes_precedence_over_title_and_description
        render_inline(Component.new(title: "Title", description: "Description")) do
          "Custom content"
        end

        assert_text "Custom content"
        refute_selector "h3", text: "Title"
        refute_selector "p", text: "Description"
      end

      def test_default_size_is_medium
        render_inline(Component.new(title: "Heads up"))

        html = page.native.to_html
        assert_includes html, "p-[var(--alert-padding-md)]"
        assert_includes html, "gap-3"
      end

      def test_renders_small_and_large_sizes
        render_inline(Component.new(title: "Heads up", size: :sm))
        assert_includes page.native.to_html, "p-[var(--alert-padding-sm)]"
        assert_includes page.native.to_html, "text-sm"

        render_inline(Component.new(title: "Heads up", description: "More detail", size: :lg))
        html = page.native.to_html
        assert_includes html, "p-[var(--alert-padding-lg)]"
        assert_includes html, "text-lg"
        assert_includes html, "text-base"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Heads up", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_info_box_matches_alert
        render_inline(Component.new(title: "Heads up", description: "Still local.", style: :info, size: :md))
        notice_class = page.find("[role='status']")[:class]

        render_inline(FlatPack::Alert::Component.new(title: "Heads up", description: "Still local.", style: :info, size: :md))
        alert_class = page.find("[role='alert']")[:class]

        assert_equal alert_class, notice_class
      end

      def test_success_box_matches_alert
        render_inline(Component.new(title: "Saved", style: :success, dismissible: true, size: :lg))
        notice_class = page.find("[role='status']")[:class]

        render_inline(FlatPack::Alert::Component.new(title: "Saved", style: :success, dismissible: true, size: :lg))
        alert_class = page.find("[role='alert']")[:class]

        assert_equal alert_class, notice_class
        assert_selector "[role='alert']"
      end
    end
  end
end
