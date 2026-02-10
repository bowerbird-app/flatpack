# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class LeftNavComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_aside_element
        render_inline(LeftNavComponent.new)
        assert_selector "aside"
      end

      def test_renders_with_navbar_target
        render_inline(LeftNavComponent.new)
        assert_selector "aside[data-navbar-target='leftNav']"
      end

      # Mobile/desktop classes tests
      def test_includes_mobile_hidden_class
        render_inline(LeftNavComponent.new)
        assert_selector "aside.hidden.md\\:flex"
      end

      def test_includes_fixed_positioning_mobile
        render_inline(LeftNavComponent.new)
        assert_selector "aside.fixed.md\\:relative"
      end

      def test_includes_right_positioning_mobile
        render_inline(LeftNavComponent.new)
        assert_selector "aside.right-0.md\\:left-0"
      end

      def test_includes_translate_classes
        render_inline(LeftNavComponent.new)
        assert_selector "aside.translate-x-full.md\\:translate-x-0"
      end

      def test_includes_transition_classes
        render_inline(LeftNavComponent.new)
        assert_selector "aside.transition-transform.duration-300"
      end

      def test_includes_shadow_for_mobile
        render_inline(LeftNavComponent.new)
        assert_selector "aside.shadow-xl.md\\:shadow-none"
      end

      # Collapsible toggle tests
      def test_renders_toggle_button_when_collapsible
        render_inline(LeftNavComponent.new(collapsible: true, show_toggle: true))
        assert_selector "button[data-action='click->navbar#toggleDesktop']"
        assert_text "Menu"
      end

      def test_hides_toggle_button_when_not_collapsible
        render_inline(LeftNavComponent.new(collapsible: false))
        refute_selector "button[data-action='click->navbar#toggleDesktop']"
      end

      def test_hides_toggle_button_when_show_toggle_false
        render_inline(LeftNavComponent.new(collapsible: true, show_toggle: false))
        refute_selector "button[data-action='click->navbar#toggleDesktop']"
      end

      # Navigation content tests
      def test_renders_nav_element
        render_inline(LeftNavComponent.new)
        assert_selector "nav[data-controller='left-nav']"
      end

      def test_renders_with_items
        render_inline(LeftNavComponent.new) do |left|
          left.with_item(text: "Item 1", href: "/path1")
          left.with_item(text: "Item 2", href: "/path2")
        end
        assert_selector "a[href='/path1']", text: "Item 1"
        assert_selector "a[href='/path2']", text: "Item 2"
      end

      def test_renders_with_sections
        render_inline(LeftNavComponent.new) do |left|
          left.with_section(title: "Section 1")
        end
        assert_text "Section 1"
      end

      def test_renders_with_content
        render_inline(LeftNavComponent.new) do
          "Custom content"
        end
        assert_text "Custom content"
      end

      # Footer tests
      def test_renders_footer
        render_inline(LeftNavComponent.new) do |left|
          left.with_footer { "Footer content" }
        end
        assert_text "Footer content"
      end

      # Layout tests
      def test_includes_flex_column_layout
        render_inline(LeftNavComponent.new)
        assert_selector "aside.flex-col"
      end

      def test_includes_background_color
        render_inline(LeftNavComponent.new)
        assert_selector "aside.bg-\\[var\\(--color-background\\)\\]"
      end

      def test_includes_border
        render_inline(LeftNavComponent.new)
        assert_selector "aside.border-r.border-\\[var\\(--color-border\\)\\]"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(LeftNavComponent.new(class: "custom-nav"))
        assert_selector "aside.custom-nav"
      end

      def test_merges_custom_data_attributes
        render_inline(LeftNavComponent.new(data: { test: "value" }))
        assert_selector "aside[data-test='value']"
      end
    end
  end
end
