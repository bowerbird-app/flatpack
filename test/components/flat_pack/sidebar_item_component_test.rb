# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Item
      class ComponentTest < ViewComponent::TestCase
        def test_renders_label_and_href
          render_inline(Component.new(label: "Dashboard", href: "/demo"))

          assert_selector "a[href='/demo']", text: "Dashboard"
        end

        def test_renders_active_state_with_aria_current
          render_inline(Component.new(label: "Dashboard", href: "#", active: true))

          assert_selector "a[aria-current='page']"
          assert_includes page.native.to_html, "sidebar-item-active-background-color"
        end

        def test_renders_collapsed_mode_accessibility
          render_inline(Component.new(label: "Settings", href: "#", collapsed: true))

          assert_selector "a[aria-label='Settings']"
          assert_selector "span.sr-only", text: "Settings"
        end

        def test_renders_badge_when_provided
          render_inline(Component.new(label: "Inbox", href: "#", badge: "8"))

          assert_text "8"
        end

        def test_includes_tooltip_controller_data_attributes
          render_inline(Component.new(label: "Reports", href: "#"))

          assert_selector "a[data-controller='flat-pack--tooltip']"
          assert_selector "a[data-flat-pack--tooltip-placement-value='right']"
          assert_selector "a[data-flat-pack--tooltip-collapsed-only-value='true']"
          assert_selector "a[data-flat-pack-sidebar-item='true']"
          assert_selector "[data-flat-pack--tooltip-target='tooltip']"
        end

        def test_raises_for_unsafe_href
          assert_raises(ArgumentError) do
            Component.new(label: "Bad", href: "javascript:alert(1)")
          end
        end
      end
    end
  end
end
