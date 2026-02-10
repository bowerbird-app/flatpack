# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class ComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_navbar_wrapper
        render_inline(Component.new)
        assert_selector "div[data-controller='navbar theme']"
      end

      def test_renders_with_content
        render_inline(Component.new) do
          "Main content"
        end
        assert_selector "main"
        assert_text "Main content"
      end

      # Dark mode tests
      def test_renders_with_dark_mode_auto
        render_inline(Component.new(dark_mode: :auto))
        html = page.native.to_html
        refute_includes html, 'class="light"'
        refute_includes html, 'class="dark"'
      end

      def test_renders_with_dark_mode_light
        render_inline(Component.new(dark_mode: :light))
        assert_selector "div.light"
      end

      def test_renders_with_dark_mode_dark
        render_inline(Component.new(dark_mode: :dark))
        assert_selector "div.dark"
      end

      def test_validates_dark_mode
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(dark_mode: :invalid))
        end
        assert_includes error.message, "Invalid dark_mode"
      end

      # Data attributes tests
      def test_includes_navbar_controller_data
        render_inline(Component.new(left_nav_collapsed: true))
        assert_selector "div[data-navbar-collapsed-value='true']"
      end

      def test_includes_width_data_values
        render_inline(Component.new(
          left_nav_width: "300px",
          left_nav_collapsed_width: "80px"
        ))
        assert_selector "div[data-navbar-width-value='300px']"
        assert_selector "div[data-navbar-collapsed-width-value='80px']"
      end

      def test_includes_theme_mode_data
        render_inline(Component.new(dark_mode: :light))
        assert_selector "div[data-theme-mode-value='light']"
      end

      # Layout tests
      def test_renders_main_content_area
        render_inline(Component.new) do
          "Content"
        end
        assert_selector "main.flex-1.overflow-auto"
        assert_selector "main.bg-\\[var\\(--color-background\\)\\]"
      end

      # Slot tests
      def test_renders_with_top_nav
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "Test App")
        end
        assert_selector "nav"
        assert_text "Test App"
      end

      def test_renders_with_left_nav
        render_inline(Component.new) do |navbar|
          navbar.left_nav
        end
        assert_selector "aside"
      end

      def test_renders_with_both_navs
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "App")
          navbar.left_nav
        end
        assert_selector "nav"
        assert_selector "aside"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-wrapper"))
        assert_selector "div.custom-wrapper"
      end

      def test_merges_custom_data_attributes
        render_inline(Component.new(data: { test: "value" }))
        assert_selector "div[data-test='value']"
      end
    end
  end
end
