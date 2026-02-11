# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class ComponentTest < ViewComponent::TestCase
      # Basic Navbar Tests
      def test_renders_basic_navbar
        render_inline(Component.new)
        assert_selector "div.flatpack-navbar"
      end

      def test_renders_with_default_dark_mode
        render_inline(Component.new(dark_mode: :auto))
        assert_selector "div.flatpack-navbar"
      end

      def test_validates_dark_mode
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(dark_mode: :invalid))
        end
        assert_includes error.message, "Invalid dark_mode"
      end

      # Top Nav Tests
      def test_renders_with_top_nav
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "Test App")
        end
        assert_selector "nav.flatpack-navbar-top"
        assert_text "Test App"
      end

      def test_top_nav_with_logo_url
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_url: "/logo.png", logo_text: "App")
        end
        assert_selector "img[src='/logo.png'][alt='Logo']"
      end

      def test_top_nav_with_custom_logo_href
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_href: "/custom", logo_text: "App")
        end
        assert_selector "a[href='/custom']"
      end

      def test_top_nav_with_actions
        render_inline(Component.new) do |navbar|
          navbar.top_nav do |top|
            top.action { "<button>Action 1</button>".html_safe }
            top.action { "<button>Action 2</button>".html_safe }
          end
        end
        assert_selector "button", text: "Action 1"
        assert_selector "button", text: "Action 2"
      end

      def test_top_nav_transparent_adds_transparency_class
        render_inline(Component.new) do |navbar|
          navbar.top_nav(transparent: true)
        end
        assert_includes page.native.to_html, "bg-[var(--color-background)]/80"
      end

      def test_top_nav_not_transparent_has_solid_background
        render_inline(Component.new) do |navbar|
          navbar.top_nav(transparent: false)
        end
        refute_includes page.native.to_html, "/80"
      end

      def test_top_nav_with_blur
        render_inline(Component.new) do |navbar|
          navbar.top_nav(blur: true)
        end
        assert_includes page.native.to_html, "backdrop-blur"
      end

      def test_top_nav_with_border_bottom
        render_inline(Component.new) do |navbar|
          navbar.top_nav(border_bottom: true)
        end
        assert_includes page.native.to_html, "border-b"
      end

      def test_top_nav_validates_unsafe_logo_href
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |navbar|
            navbar.top_nav(logo_href: "javascript:alert('xss')")
          end
        end
        assert_includes error.message, "Unsafe URL"
      end

      # Left Nav Tests
      def test_renders_with_left_nav
        render_inline(Component.new) do |navbar|
          navbar.left_nav
        end
        assert_selector "aside.flatpack-navbar-left"
      end

      def test_left_nav_with_items
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
            left.item(text: "About", href: "/about")
          end
        end
        assert_selector ".flatpack-navbar-item", count: 2
        assert_text "Home"
        assert_text "About"
      end

      def test_left_nav_with_sections
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.section(title: "Main") do |section|
              section.item(text: "Dashboard", href: "/dashboard")
            end
          end
        end
        assert_selector ".flatpack-navbar-section"
        assert_text "Main"
        assert_text "Dashboard"
      end

      def test_left_nav_item_with_icon
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Home", icon: "home", href: "/")
          end
        end
        assert_text "Home"
        # Icon should be rendered (actual icon rendering tested in icon component tests)
      end

      def test_left_nav_item_active_state
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/", active: true)
          end
        end
        assert_includes page.native.to_html, "bg-[var(--color-primary)]"
      end

      def test_left_nav_item_with_badge
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Messages", href: "/messages", badge: "3")
          end
        end
        assert_text "Messages"
        assert_text "3"
      end

      def test_left_nav_section_collapsible
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.section(title: "Projects", collapsible: true) do |section|
              section.item(text: "Project 1", href: "/projects/1")
            end
          end
        end
        assert_selector "button", text: "Projects"
      end

      def test_left_nav_section_not_collapsible
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.section(title: "Settings", collapsible: false) do |section|
              section.item(text: "Profile", href: "/profile")
            end
          end
        end
        assert_selector "div", text: "Settings"
        refute_selector "button", text: "Settings"
      end

      # Integration Tests
      def test_full_navbar_with_top_and_left_nav
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "App") do |top|
            top.action { "<button>Action</button>".html_safe }
          end

          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
            left.section(title: "Main") do |section|
              section.item(text: "Dashboard", href: "/dashboard")
            end
          end
        end

        assert_selector "nav.flatpack-navbar-top"
        assert_selector "aside.flatpack-navbar-left"
        assert_text "App"
        assert_text "Home"
        assert_text "Main"
        assert_text "Dashboard"
      end

      def test_navbar_with_custom_dimensions
        render_inline(Component.new(
          left_nav_width: "280px",
          left_nav_collapsed_width: "80px",
          top_nav_height: "72px"
        )) do |navbar|
          navbar.top_nav(logo_text: "App")
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        assert_selector "div.flatpack-navbar"
      end

      def test_navbar_collapsed_state
        render_inline(Component.new(left_nav_collapsed: true)) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        assert_selector "aside.flatpack-navbar-left"
      end

      def test_navbar_contained_mode_uses_absolute_positioning
        render_inline(Component.new(contained: true)) do |navbar|
          navbar.top_nav(logo_text: "App")
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        # Check that container doesn't have min-h-screen in contained mode
        assert_selector "div.flatpack-navbar"
        # Check that top nav uses absolute positioning
        html = page.native.to_html
        assert_includes html, "absolute"
        refute_includes html, "min-h-screen"
      end

      def test_navbar_default_mode_uses_fixed_positioning
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "App")
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        # Check that it uses fixed positioning by default
        html = page.native.to_html
        assert_includes html, "fixed"
        assert_includes html, "min-h-screen"
      end

      def test_main_content_renders
        render_inline(Component.new) do |navbar|
          navbar.top_nav(logo_text: "App")
          "<div>Main content</div>".html_safe
        end

        assert_selector "main.flatpack-navbar-main"
        assert_text "Main content"
      end

      # System Arguments Tests
      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-navbar"))
        assert_includes page.native.to_html, "custom-navbar"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "main-navbar"}))
        assert_selector "div[data-testid='main-navbar']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(aria: {label: "Main navigation"}))
        assert_selector "div[aria-label='Main navigation']"
      end

      # Nav Item Component Tests
      def test_nav_item_renders_as_link
        render_inline(NavItemComponent.new(text: "Home", href: "/"))
        assert_selector "a[href='/']", text: "Home"
      end

      def test_nav_item_renders_as_div_without_href
        render_inline(NavItemComponent.new(text: "Label"))
        assert_selector "div", text: "Label"
        refute_selector "a"
      end

      def test_nav_item_validates_unsafe_href
        error = assert_raises(ArgumentError) do
          render_inline(NavItemComponent.new(text: "Link", href: "javascript:alert('xss')"))
        end
        assert_includes error.message, "Unsafe URL"
      end

      def test_nav_item_allows_relative_urls
        render_inline(NavItemComponent.new(text: "Home", href: "/home"))
        assert_selector "a[href='/home']"
      end

      def test_nav_item_allows_http_urls
        render_inline(NavItemComponent.new(text: "External", href: "http://example.com"))
        assert_selector "a[href='http://example.com']"
      end

      def test_nav_item_allows_https_urls
        render_inline(NavItemComponent.new(text: "External", href: "https://example.com"))
        assert_selector "a[href='https://example.com']"
      end

      # Left Nav Positioning Tests
      def test_left_nav_positions_below_top_nav
        render_inline(Component.new(top_nav_height: "72px")) do |navbar|
          navbar.top_nav(logo_text: "App")
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        html = page.native.to_html
        assert_includes html, "aside"
        # Check that the left nav has the top position style applied
        assert_includes html, "top: 72px"
      end

      def test_left_nav_without_top_nav_starts_at_top
        render_inline(Component.new) do |navbar|
          navbar.left_nav do |left|
            left.item(text: "Home", href: "/")
          end
        end

        html = page.native.to_html
        # Without top nav, should have top-0 class
        assert_includes html, "top-0"
        # Should not have inline style with top position
        refute_includes html, "style=\"top:"
      end

      # Nav Section Component Tests
      def test_nav_section_renders_with_title
        render_inline(NavSectionComponent.new(title: "Section Title")) do |section|
          section.item(text: "Item", href: "/")
        end
        assert_text "Section Title"
      end

      def test_nav_section_renders_without_title
        render_inline(NavSectionComponent.new) do |section|
          section.item(text: "Item", href: "/")
        end
        assert_text "Item"
      end

      # Theme Toggle Component Tests
      def test_theme_toggle_renders
        render_inline(ThemeToggleComponent.new)
        assert_selector "button.flatpack-theme-toggle"
      end

      def test_theme_toggle_has_aria_label
        render_inline(ThemeToggleComponent.new)
        assert_selector "button[aria-label='Toggle theme']"
      end

      def test_theme_toggle_validates_size
        error = assert_raises(ArgumentError) do
          render_inline(ThemeToggleComponent.new(size: :invalid))
        end
        assert_includes error.message, "Invalid size"
      end

      def test_theme_toggle_with_small_size
        render_inline(ThemeToggleComponent.new(size: :sm))
        assert_includes page.native.to_html, "w-8 h-8"
      end

      def test_theme_toggle_with_medium_size
        render_inline(ThemeToggleComponent.new(size: :md))
        assert_includes page.native.to_html, "w-10 h-10"
      end

      def test_theme_toggle_with_large_size
        render_inline(ThemeToggleComponent.new(size: :lg))
        assert_includes page.native.to_html, "w-12 h-12"
      end
    end
  end
end
