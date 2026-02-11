# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class ComponentTest < ViewComponent::TestCase
      # Navbar Component Tests
      def test_renders_wrapper_with_controller
        render_inline(Component.new) do |navbar|
          "Content"
        end

        assert_selector "div[data-controller='flat-pack--navbar']"
      end

      def test_applies_correct_data_attributes
        render_inline(Component.new)

        assert_selector "div[data-flat-pack--navbar-expanded-width-value='256px']"
        assert_selector "div[data-flat-pack--navbar-collapsed-width-value='64px']"
        assert_selector "div[data-flat-pack--navbar-collapsed-value='false']"
      end

      def test_renders_with_flex_layout
        render_inline(Component.new)

        assert_selector "div.flex.h-full"
      end

      def test_renders_main_content_area
        render_inline(Component.new) do |navbar|
          "Main content"
        end

        assert_selector "main.flex-1.overflow-auto", text: "Main content"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))

        assert_selector "div.custom-class"
      end

      # Sidebar Tests
      def test_sidebar_hidden_on_mobile_by_default
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.hidden.md\\:flex"
      end

      def test_sidebar_visible_on_desktop
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.md\\:relative"
      end

      def test_sidebar_full_height_positioning
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.inset-y-0.left-0"
      end

      def test_sidebar_contains_navigation_element
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside nav"
      end

      def test_sidebar_has_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside[data-flat-pack--navbar-target='sidebar']"
      end

      def test_sidebar_has_border_and_background
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.border-r.bg-\\[var\\(--color-background\\)\\]"
      end

      def test_sidebar_has_transition
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.transition-transform.duration-300"
      end

      def test_sidebar_slides_from_left
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "aside.-translate-x-full.md\\:translate-x-0"
      end

      # Bottom Toggle Button Tests
      def test_toggle_button_renders_with_correct_targets
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "button[data-flat-pack--navbar-target='toggleButton']"
      end

      def test_toggle_button_has_chevron_icon_with_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "svg[data-flat-pack--navbar-target='toggleIcon']"
      end

      def test_toggle_button_has_minimize_text_with_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "span[data-flat-pack--navbar-target='toggleText']", text: "Minimize"
      end

      def test_toggle_button_in_border_container_with_mt_auto
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "div.border-t.mt-auto button"
      end

      def test_toggle_button_has_unified_click_action
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "button[data-action='click->flat-pack--navbar#toggle']"
      end

      def test_toggle_button_has_gap_classes
        render_inline(Component.new) do |navbar|
          navbar.sidebar do
            "Sidebar content"
          end
        end

        assert_selector "button.flex.items-center.gap-2"
      end

      # Sidebar Item Tests
      def test_sidebar_item_renders_with_text
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard")
          end
        end

        assert_selector "span", text: "Dashboard"
      end

      def test_sidebar_item_with_icon_and_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard", icon: "home")
          end
        end

        assert_selector "span[data-flat-pack--navbar-target='itemIcon']"
      end

      def test_sidebar_item_text_has_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard")
          end
        end

        assert_selector "span[data-flat-pack--navbar-target='itemText']", text: "Dashboard"
      end

      def test_sidebar_item_with_badge_and_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Messages", badge: "5")
          end
        end

        assert_selector "span[data-flat-pack--navbar-target='itemBadge']", text: "5"
      end

      def test_sidebar_item_active_state_styling
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard", active: true)
          end
        end

        html = page.native.to_html
        assert_includes html, "bg-[var(--color-primary)]"
        assert_includes html, "text-[var(--color-primary-text)]"
      end

      def test_sidebar_item_hover_state_styling
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard")
          end
        end

        html = page.native.to_html
        assert_includes html, "hover:bg-[var(--color-muted)]"
      end

      def test_sidebar_item_renders_as_link_with_href
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard", href: "/dashboard")
          end
        end

        assert_selector "a[href='/dashboard']", text: "Dashboard"
      end

      def test_sidebar_item_renders_as_button_without_href
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard")
          end
        end

        assert_selector "button[type='button']", text: "Dashboard"
      end

      def test_sidebar_item_validates_required_text
        assert_raises(ArgumentError) do
          SidebarItemComponent.new(text: nil)
        end
      end

      def test_sidebar_item_badge_styles
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Notifications", badge: "3", badge_style: :danger)
          end
        end

        html = page.native.to_html
        assert_includes html, "bg-[var(--color-danger)]"
      end

      # Sidebar Section Tests
      def test_sidebar_section_renders_with_title
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Main Navigation")
          end
        end

        assert_selector "h3", text: "Main Navigation"
      end

      def test_sidebar_section_title_has_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Main")
          end
        end

        assert_selector "[data-flat-pack--navbar-target='sectionTitle']"
      end

      def test_sidebar_section_collapsible_behavior
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Projects", collapsible: true) do |section|
              section.item(text: "Project 1")
            end
          end
        end

        assert_selector "button[data-action='click->flat-pack--sidebar#toggleSection']"
      end

      def test_sidebar_section_chevron_rotation
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Projects", collapsible: true, collapsed: true)
          end
        end

        html = page.native.to_html
        refute_includes html, "rotate-180"
      end

      def test_sidebar_section_items_hidden_when_collapsed
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Projects", collapsible: true, collapsed: true) do |section|
              section.item(text: "Project 1")
            end
          end
        end

        assert_selector "ul.hidden"
      end

      def test_sidebar_section_contains_items
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.section(title: "Main") do |section|
              section.item(text: "Dashboard")
              section.item(text: "Projects")
            end
          end
        end

        assert_selector "ul li", count: 2
      end

      # Top Nav Tests
      def test_top_nav_renders_nav_element
        render_inline(Component.new) do |navbar|
          navbar.top_nav do
            "Nav content"
          end
        end

        assert_selector "nav"
      end

      def test_top_nav_hamburger_on_mobile_only
        render_inline(Component.new) do |navbar|
          navbar.top_nav do
            "Nav content"
          end
        end

        assert_selector "button.md\\:hidden[aria-label='Toggle navigation']"
      end

      def test_top_nav_hamburger_has_toggle_action
        render_inline(Component.new) do |navbar|
          navbar.top_nav do
            "Nav content"
          end
        end

        assert_selector "button[data-action='click->flat-pack--navbar#toggle']"
      end

      def test_top_nav_left_section_content
        render_inline(Component.new) do |navbar|
          navbar.top_nav do |nav|
            nav.left_section do
              "Logo"
            end
          end
        end

        assert_text "Logo"
      end

      def test_top_nav_center_section_content
        render_inline(Component.new) do |navbar|
          navbar.top_nav do |nav|
            nav.center_section do
              "Search"
            end
          end
        end

        assert_text "Search"
      end

      def test_top_nav_right_section_content
        render_inline(Component.new) do |navbar|
          navbar.top_nav do |nav|
            nav.right_section do
              "Profile"
            end
          end
        end

        assert_text "Profile"
      end

      def test_top_nav_all_three_sections_together
        render_inline(Component.new) do |navbar|
          navbar.top_nav do |nav|
            nav.left_section { "Logo" }
            nav.center_section { "Search" }
            nav.right_section { "Profile" }
          end
        end

        assert_text "Logo"
        assert_text "Search"
        assert_text "Profile"
      end

      def test_top_nav_flex_layout
        render_inline(Component.new) do |navbar|
          navbar.top_nav
        end

        assert_selector "nav.flex.items-center"
      end

      # Stimulus Integration Tests
      def test_has_layout_controller
        render_inline(Component.new)

        assert_selector "[data-controller='flat-pack--navbar']"
      end

      def test_has_sidebar_target
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "[data-flat-pack--navbar-target='sidebar']"
      end

      def test_has_all_toggle_targets
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "[data-flat-pack--navbar-target='toggleButton']"
        assert_selector "[data-flat-pack--navbar-target='toggleIcon']"
        assert_selector "[data-flat-pack--navbar-target='toggleText']"
      end

      def test_has_item_targets
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard", icon: "home", badge: "5")
          end
        end

        assert_selector "[data-flat-pack--navbar-target='itemText']"
        assert_selector "[data-flat-pack--navbar-target='itemIcon']"
        assert_selector "[data-flat-pack--navbar-target='itemBadge']"
      end

      def test_sidebar_has_sidebar_controller
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "aside[data-controller='flat-pack--sidebar']"
      end

      # Accessibility Tests
      def test_semantic_aside_element
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "aside"
      end

      def test_semantic_nav_element_in_sidebar
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "aside nav"
      end

      def test_semantic_nav_element_in_top_nav
        render_inline(Component.new) do |navbar|
          navbar.top_nav
        end

        assert_selector "nav"
      end

      def test_button_type_attributes
        render_inline(Component.new) do |navbar|
          navbar.sidebar
        end

        assert_selector "button[type='button']"
      end

      def test_hamburger_aria_label
        render_inline(Component.new) do |navbar|
          navbar.top_nav
        end

        assert_selector "button[aria-label='Toggle navigation']"
      end

      # Complete Integration Test
      def test_complete_layout_with_all_components
        render_inline(Component.new) do |navbar|
          navbar.sidebar do |sidebar|
            sidebar.item(text: "Dashboard", icon: "home", href: "/", active: true)
            sidebar.item(text: "Messages", icon: "mail", href: "/messages", badge: "5")
            sidebar.section(title: "Projects", collapsible: true) do |section|
              section.item(text: "Project 1", icon: "folder", href: "/projects/1")
            end
          end

          navbar.top_nav do |nav|
            nav.left_section { "Logo" }
            nav.center_section { "Search" }
            nav.right_section { "Profile" }
          end

          "Main content area"
        end

        # Verify all parts are present
        assert_selector "[data-controller='flat-pack--navbar']"
        assert_selector "aside[data-flat-pack--navbar-target='sidebar']"
        assert_selector "nav"
        assert_selector "main", text: "Main content area"
        assert_text "Dashboard"
        assert_text "Messages"
        assert_text "Projects"
        assert_text "Logo"
        assert_text "Profile"
      end
    end
  end
end
