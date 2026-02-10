# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class TopNavComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_nav_element
        render_inline(TopNavComponent.new)
        assert_selector "nav.fixed.top-0.left-0.right-0.z-50"
      end

      # Transparency and blur tests
      def test_renders_transparent_background
        render_inline(TopNavComponent.new(transparent: true))
        assert_selector "nav.bg-\\[var\\(--color-background\\)\\]\\/80"
      end

      def test_renders_solid_background
        render_inline(TopNavComponent.new(transparent: false))
        assert_selector "nav.bg-\\[var\\(--color-background\\)\\]"
        refute_selector "nav.backdrop-blur-md"
      end

      def test_renders_with_blur
        render_inline(TopNavComponent.new(transparent: true, blur: true))
        assert_selector "nav.backdrop-blur-md"
      end

      def test_renders_without_blur
        render_inline(TopNavComponent.new(transparent: true, blur: false))
        refute_selector "nav.backdrop-blur-md"
      end

      # Border tests
      def test_renders_with_border_bottom
        render_inline(TopNavComponent.new(border_bottom: true))
        assert_selector "nav.border-b.border-\\[var\\(--color-border\\)\\]"
      end

      def test_renders_without_border_bottom
        render_inline(TopNavComponent.new(border_bottom: false))
        refute_selector "nav.border-b"
      end

      # Logo tests
      def test_renders_logo_text
        render_inline(TopNavComponent.new(logo_text: "My App"))
        assert_text "My App"
      end

      def test_renders_logo_url_as_link
        render_inline(TopNavComponent.new(logo_text: "App", logo_url: "/home"))
        assert_selector "a[href='/home']", text: "App"
      end

      def test_renders_logo_without_url
        render_inline(TopNavComponent.new(logo_text: "App"))
        assert_selector "div", text: "App"
        refute_selector "a", text: "App"
      end

      def test_sanitizes_logo_url
        render_inline(TopNavComponent.new(logo_text: "App", logo_url: "https://example.com"))
        assert_selector "a[href='https://example.com']"
      end

      def test_validates_unsafe_logo_url
        error = assert_raises(ArgumentError) do
          render_inline(TopNavComponent.new(logo_url: "javascript:alert('xss')"))
        end
        assert_includes error.message, "Unsafe URL detected"
      end

      # Menu toggle tests
      def test_renders_menu_toggle_button
        render_inline(TopNavComponent.new(show_menu_toggle: true))
        assert_selector "button[data-action='click->navbar#toggleMobile']"
        assert_selector "button.md\\:hidden"
      end

      def test_hides_menu_toggle_button
        render_inline(TopNavComponent.new(show_menu_toggle: false))
        refute_selector "button[data-action='click->navbar#toggleMobile']"
      end

      # Theme toggle tests
      def test_shows_theme_toggle
        render_inline(TopNavComponent.new(show_theme_toggle: true)) do |top|
          top.with_theme_toggle
        end
        assert_selector "button[data-action='click->theme#toggle']"
      end

      # Actions tests
      def test_renders_actions
        render_inline(TopNavComponent.new) do |top|
          top.with_action { "Action 1" }
          top.with_action { "Action 2" }
        end
        assert_text "Action 1"
        assert_text "Action 2"
      end

      # Center content tests
      def test_renders_center_content
        render_inline(TopNavComponent.new) do |top|
          top.with_center_content { "Center" }
        end
        assert_text "Center"
      end

      # Height tests
      def test_renders_with_custom_height
        render_inline(TopNavComponent.new(height: "80px"))
        assert_selector "nav[style*='height: 80px']"
      end

      # Accessibility tests
      def test_menu_toggle_has_aria_label
        render_inline(TopNavComponent.new(show_menu_toggle: true))
        assert_selector "button[aria-label='Toggle menu']"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(TopNavComponent.new(class: "custom-nav"))
        assert_selector "nav.custom-nav"
      end

      def test_merges_custom_data_attributes
        render_inline(TopNavComponent.new(data: { test: "value" }))
        assert_selector "nav[data-test='value']"
      end
    end
  end
end
