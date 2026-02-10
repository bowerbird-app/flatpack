# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class NavItemComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_link_when_href_provided
        render_inline(NavItemComponent.new(text: "Home", href: "/home"))
        assert_selector "a[href='/home']", text: "Home"
      end

      def test_renders_button_when_no_href
        render_inline(NavItemComponent.new(text: "Action"))
        assert_selector "button", text: "Action"
        refute_selector "a"
      end

      # Text tests
      def test_renders_text_with_truncate
        render_inline(NavItemComponent.new(text: "Long item name"))
        assert_selector "span.truncate", text: "Long item name"
      end

      def test_text_has_navbar_target
        render_inline(NavItemComponent.new(text: "Item"))
        assert_selector "span[data-navbar-target='collapseText']"
      end

      # Icon tests
      def test_renders_with_icon
        render_inline(NavItemComponent.new(text: "Home", icon: "home"))
        assert_selector "svg"
      end

      def test_renders_without_icon
        render_inline(NavItemComponent.new(text: "Home"))
        assert_selector "a", text: "Home"
      end

      # Active state tests
      def test_renders_active_state
        render_inline(NavItemComponent.new(text: "Active", active: true))
        assert_selector ".bg-\\[var\\(--color-primary\\)\\]"
        assert_selector ".text-\\[var\\(--color-primary-text\\)\\]"
      end

      def test_renders_inactive_state
        render_inline(NavItemComponent.new(text: "Inactive", active: false))
        assert_selector ".text-\\[var\\(--color-foreground\\)\\]"
        assert_selector ".hover\\:bg-\\[var\\(--color-muted\\)\\]"
      end

      def test_active_has_aria_current
        render_inline(NavItemComponent.new(text: "Active", active: true, href: "/"))
        assert_selector "a[aria-current='page']"
      end

      def test_inactive_no_aria_current
        render_inline(NavItemComponent.new(text: "Inactive", active: false, href: "/"))
        refute_selector "a[aria-current='page']"
      end

      # Badge tests
      def test_renders_with_badge
        render_inline(NavItemComponent.new(text: "Messages", badge: "5"))
        assert_text "5"
      end

      def test_renders_without_badge
        render_inline(NavItemComponent.new(text: "Home"))
        refute_selector ".rounded-full"
      end

      def test_badge_has_navbar_target
        render_inline(NavItemComponent.new(text: "Item", badge: "3"))
        assert_selector "span[data-navbar-target='collapseText']", text: "3"
      end

      def test_badge_primary_style
        render_inline(NavItemComponent.new(text: "Item", badge: "1", badge_style: :primary))
        assert_selector ".bg-\\[var\\(--color-primary\\)\\]"
      end

      def test_badge_success_style
        render_inline(NavItemComponent.new(text: "Item", badge: "1", badge_style: :success))
        assert_selector ".bg-\\[var\\(--color-success\\)\\]"
      end

      def test_badge_warning_style
        render_inline(NavItemComponent.new(text: "Item", badge: "1", badge_style: :warning))
        assert_selector ".bg-\\[var\\(--color-warning\\)\\]"
      end

      def test_badge_danger_style
        render_inline(NavItemComponent.new(text: "Item", badge: "1", badge_style: :danger))
        assert_selector ".bg-\\[var\\(--color-danger\\)\\]"
      end

      def test_validates_badge_style
        error = assert_raises(ArgumentError) do
          render_inline(NavItemComponent.new(text: "Item", badge: "1", badge_style: :invalid))
        end
        assert_includes error.message, "Invalid badge_style"
      end

      # URL sanitization tests
      def test_sanitizes_href
        render_inline(NavItemComponent.new(text: "Link", href: "https://example.com"))
        assert_selector "a[href='https://example.com']"
      end

      def test_validates_unsafe_href
        error = assert_raises(ArgumentError) do
          render_inline(NavItemComponent.new(text: "Link", href: "javascript:alert('xss')"))
        end
        assert_includes error.message, "Unsafe URL detected"
      end

      # Styling tests
      def test_includes_base_classes
        render_inline(NavItemComponent.new(text: "Item"))
        assert_selector ".flex.items-center.gap-3"
        assert_selector ".px-3.py-2.rounded-lg"
        assert_selector ".text-sm.font-medium"
        assert_selector ".transition-colors.duration-200"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(NavItemComponent.new(text: "Item", class: "custom-item"))
        assert_selector ".custom-item"
      end

      def test_merges_custom_data_attributes
        render_inline(NavItemComponent.new(text: "Item", data: { test: "value" }))
        assert_selector "[data-test='value']"
      end
    end
  end
end
