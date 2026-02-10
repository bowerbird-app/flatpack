# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class ThemeToggleComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_button
        render_inline(ThemeToggleComponent.new)
        assert_selector "button[data-action='click->theme#toggle']"
      end

      def test_has_aria_label
        render_inline(ThemeToggleComponent.new)
        assert_selector "button[aria-label='Toggle theme']"
      end

      # Icon tests
      def test_renders_sun_icon
        render_inline(ThemeToggleComponent.new)
        # Sun icon should be hidden by default, visible in dark mode
        assert_selector "svg.hidden.dark\\:block"
      end

      def test_renders_moon_icon
        render_inline(ThemeToggleComponent.new)
        # Moon icon should be visible by default, hidden in dark mode
        assert_selector "svg.block.dark\\:hidden"
      end

      # Size tests
      def test_renders_with_size_sm
        render_inline(ThemeToggleComponent.new(size: :sm))
        assert_selector "button.p-1\\.5"
      end

      def test_renders_with_size_md
        render_inline(ThemeToggleComponent.new(size: :md))
        assert_selector "button.p-2"
      end

      def test_renders_with_size_lg
        render_inline(ThemeToggleComponent.new(size: :lg))
        assert_selector "button.p-3"
      end

      def test_validates_size
        error = assert_raises(ArgumentError) do
          render_inline(ThemeToggleComponent.new(size: :invalid))
        end
        assert_includes error.message, "Invalid size"
      end

      # Label tests
      def test_renders_without_label_by_default
        render_inline(ThemeToggleComponent.new)
        refute_text "Theme"
      end

      def test_renders_with_label
        render_inline(ThemeToggleComponent.new(show_label: true))
        assert_text "Theme"
      end

      def test_label_size_sm
        render_inline(ThemeToggleComponent.new(size: :sm, show_label: true))
        assert_selector "span.text-xs"
      end

      def test_label_size_md
        render_inline(ThemeToggleComponent.new(size: :md, show_label: true))
        assert_selector "span.text-sm"
      end

      def test_label_size_lg
        render_inline(ThemeToggleComponent.new(size: :lg, show_label: true))
        assert_selector "span.text-base"
      end

      # Styling tests
      def test_includes_base_classes
        render_inline(ThemeToggleComponent.new)
        assert_selector "button.flex.items-center.justify-center"
        assert_selector "button.rounded-lg"
        assert_selector "button.hover\\:bg-\\[var\\(--color-muted\\)\\]"
        assert_selector "button.transition-colors.duration-200"
      end

      # Hover animation tests
      def test_sun_icon_has_rotate_animation
        render_inline(ThemeToggleComponent.new)
        assert_selector "svg.hover\\:rotate-180.duration-500"
      end

      def test_moon_icon_has_rotate_animation
        render_inline(ThemeToggleComponent.new)
        assert_selector "svg.hover\\:rotate-12.duration-300"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(ThemeToggleComponent.new(class: "custom-toggle"))
        assert_selector "button.custom-toggle"
      end

      def test_merges_custom_data_attributes
        render_inline(ThemeToggleComponent.new(data: { test: "value" }))
        assert_selector "button[data-test='value']"
      end
    end
  end
end
