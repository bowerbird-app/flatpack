# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Progress
    class ComponentTest < ViewComponent::TestCase
      def test_renders_progress_bar
        render_inline(Component.new(value: 50))

        assert_selector "[role='progressbar']"
      end

      def test_renders_with_correct_percentage
        render_inline(Component.new(value: 75, max: 100))

        assert_selector "[aria-valuenow='75.0']"
        assert_selector "[aria-valuemax='100.0']"
      end

      def test_renders_default_variant
        render_inline(Component.new(value: 50))

        assert_includes page.native.to_html, "bg-primary"
      end

      def test_renders_success_variant
        render_inline(Component.new(value: 50, variant: :success))

        assert_includes page.native.to_html, "bg-success-bg"
      end

      def test_renders_warning_variant
        render_inline(Component.new(value: 50, variant: :warning))

        assert_includes page.native.to_html, "bg-warning-bg"
      end

      def test_renders_danger_variant
        render_inline(Component.new(value: 50, variant: :danger))

        assert_includes page.native.to_html, "bg-destructive-bg"
      end

      def test_renders_small_size
        render_inline(Component.new(value: 50, size: :sm))

        assert_includes page.native.to_html, "h-1"
      end

      def test_renders_medium_size
        render_inline(Component.new(value: 50, size: :md))

        assert_includes page.native.to_html, "h-2"
      end

      def test_renders_label_when_provided
        render_inline(Component.new(value: 50, label: "Upload Progress"))

        assert_text "Upload Progress"
      end

      def test_renders_percentage_label_when_show_label
        render_inline(Component.new(value: 75, show_label: true))

        assert_text "75%"
      end

      def test_calculates_percentage_correctly
        render_inline(Component.new(value: 25, max: 50))

        assert_selector "[aria-valuenow='25.0']"
        assert_includes page.native.to_html, "width: 50.0%"
      end

      def test_caps_percentage_at_100
        render_inline(Component.new(value: 150, max: 100))

        assert_includes page.native.to_html, "width: 100%"
      end

      def test_raises_error_for_negative_value
        assert_raises(ArgumentError) do
          Component.new(value: -10)
        end
      end

      def test_raises_error_for_zero_max
        assert_raises(ArgumentError) do
          Component.new(value: 50, max: 0)
        end
      end

      def test_raises_error_for_invalid_variant
        assert_raises(ArgumentError) do
          Component.new(value: 50, variant: :invalid)
        end
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(value: 50, size: :xxl)
        end
      end

      def test_includes_sr_only_percentage
        render_inline(Component.new(value: 60))

        assert_selector ".sr-only", text: "60%"
      end

      def test_merges_custom_classes
        render_inline(Component.new(value: 50, class: "custom-class"))

        assert_selector ".custom-class"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(value: 50, aria: {label: "File upload"}))

        assert_selector "[aria-label='File upload']"
      end
    end
  end
end
