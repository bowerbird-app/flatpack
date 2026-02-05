# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Badge
    class ComponentTest < ViewComponent::TestCase
      def test_renders_badge_with_text
        render_inline(Component.new(text: "New"))

        assert_selector "span", text: "New"
      end

      def test_renders_default_style
        render_inline(Component.new(text: "Default"))

        assert_selector "span", text: "Default"
        assert_includes page.native.to_html, "bg-[var(--color-muted)]"
      end

      def test_renders_primary_style
        render_inline(Component.new(text: "Primary", style: :primary))

        assert_selector "span", text: "Primary"
        assert_includes page.native.to_html, "bg-[var(--color-primary)]"
      end

      def test_renders_success_style
        render_inline(Component.new(text: "Success", style: :success))

        assert_selector "span", text: "Success"
        assert_includes page.native.to_html, "bg-[var(--color-success)]"
      end

      def test_renders_warning_style
        render_inline(Component.new(text: "Warning", style: :warning))

        assert_selector "span", text: "Warning"
        assert_includes page.native.to_html, "bg-[var(--color-warning)]"
      end

      def test_renders_info_style
        render_inline(Component.new(text: "Info", style: :info))

        assert_selector "span", text: "Info"
        assert_includes page.native.to_html, "bg-blue-500"
      end

      def test_renders_small_size
        render_inline(Component.new(text: "Small", size: :sm))

        assert_selector "span", text: "Small"
        assert_includes page.native.to_html, "text-xs"
        assert_includes page.native.to_html, "px-2"
      end

      def test_renders_medium_size
        render_inline(Component.new(text: "Medium", size: :md))

        assert_selector "span", text: "Medium"
        assert_includes page.native.to_html, "text-sm"
        assert_includes page.native.to_html, "px-2.5"
      end

      def test_renders_large_size
        render_inline(Component.new(text: "Large", size: :lg))

        assert_selector "span", text: "Large"
        assert_includes page.native.to_html, "text-base"
        assert_includes page.native.to_html, "px-3"
      end

      def test_default_size_is_medium
        render_inline(Component.new(text: "Default"))

        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_with_dot_indicator
        render_inline(Component.new(text: "Online", dot: true))

        assert_selector "span", text: "Online"
        assert_selector "span span[aria-hidden='true']"
      end

      def test_renders_without_dot_by_default
        render_inline(Component.new(text: "Offline"))

        refute_selector "span span[aria-hidden='true']"
      end

      def test_renders_removable_badge
        render_inline(Component.new(text: "Tag", removable: true))

        assert_selector "span", text: "Tag"
        assert_selector "button[type='button'][aria-label='Remove']"
        assert_selector "button svg"
      end

      def test_renders_non_removable_badge_by_default
        render_inline(Component.new(text: "Tag"))

        refute_selector "button[aria-label='Remove']"
      end

      def test_raises_error_for_invalid_style
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", style: :invalid)
        end
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", size: :xl)
        end
      end

      def test_raises_error_without_text
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(text: "Custom", class: "custom-class"))

        assert_selector "span.custom-class", text: "Custom"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(text: "Data", data: {testid: "badge"}))

        assert_selector "span[data-testid='badge']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(text: "Aria", aria: {label: "Status badge"}))

        assert_selector "span[aria-label='Status badge']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(text: "ID", id: "my-badge"))

        assert_selector "span#my-badge"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(text: "Badge", onclick: "alert('xss')"))

        refute_selector "span[onclick]"
      end
    end
  end
end
