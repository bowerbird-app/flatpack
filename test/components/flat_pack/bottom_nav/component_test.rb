# frozen_string_literal: true

require "test_helper"

module FlatPack
  module BottomNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_nav_with_default_aria_label
        render_inline(Component.new) do |nav|
          nav.item(label: "Home", href: "/", icon: :home, active: true)
          nav.item(label: "Search", href: "/search", icon: :search)
        end

        assert_selector "nav[aria-label='Bottom navigation']"
        assert_selector "a", count: 2
      end

      def test_allows_custom_aria_label_via_system_arguments
        render_inline(Component.new(aria: {label: "Primary mobile navigation"})) do |nav|
          nav.item(label: "Home", href: "/")
        end

        assert_selector "nav[aria-label='Primary mobile navigation']"
      end

      def test_item_sets_aria_current_when_active
        render_inline(Component.new) do |nav|
          nav.item(label: "Home", href: "/", active: true)
          nav.item(label: "Profile", href: "/profile")
        end

        assert_selector "a[href='/'][aria-current='page']"
        refute_selector "a[href='/profile'][aria-current='page']"
      end

      def test_item_sanitizes_and_accepts_safe_relative_href
        render_inline(Component.new) do |nav|
          nav.item(label: "Messages", href: "/messages")
        end

        assert_selector "a[href='/messages']", text: "Messages"
      end

      def test_item_rejects_unsafe_href
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |nav|
            nav.item(label: "Bad", href: "javascript:alert('xss')")
          end
        end

        assert_includes error.message, "Unsafe URL detected"
      end

      def test_item_renders_icon_when_provided
        render_inline(Component.new) do |nav|
          nav.item(label: "Home", href: "/", icon: :home)
        end

        assert_selector "svg"
        assert_includes page.native.to_html, "#icon-home"
      end

      def test_merges_component_system_arguments_class_data_and_aria
        render_inline(Component.new(class: "custom-nav", data: {testid: "mobile-nav"}, aria: {label: "App nav"})) do |nav|
          nav.item(label: "Home", href: "/")
        end

        assert_selector "nav.custom-nav[data-testid='mobile-nav'][aria-label='App nav']"
      end

      def test_merges_item_system_arguments_class_data_and_aria
        render_inline(Component.new) do |nav|
          nav.item(label: "Home", href: "/", class: "custom-item", data: {track: "home"}, aria: {label: "Go home"})
        end

        assert_selector "a.custom-item[data-track='home'][aria-label='Go home']"
      end
    end
  end
end
