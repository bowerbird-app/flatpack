# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Navbar
    class NavSectionComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_section_container
        render_inline(NavSectionComponent.new)
        assert_selector "div.space-y-1"
      end

      # Title tests
      def test_renders_with_title
        render_inline(NavSectionComponent.new(title: "Settings"))
        assert_text "Settings"
      end

      def test_renders_without_title
        render_inline(NavSectionComponent.new)
        refute_selector ".text-xs.font-semibold"
      end

      def test_title_has_navbar_target
        render_inline(NavSectionComponent.new(title: "Section"))
        assert_selector "span[data-navbar-target='collapseText']", text: "Section"
      end

      # Collapsible tests
      def test_renders_static_header_when_not_collapsible
        render_inline(NavSectionComponent.new(title: "Section", collapsible: false))
        assert_selector "div", text: "Section"
        refute_selector "button"
      end

      def test_renders_button_when_collapsible
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true))
        assert_selector "button[data-action='click->left-nav#toggleSection']"
      end

      def test_includes_chevron_when_collapsible
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true))
        assert_selector "svg"
      end

      # Collapsed state tests
      def test_items_hidden_when_collapsed
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true, collapsed: true)) do |section|
          section.item(text: "Item 1", href: "/path1")
        end
        assert_selector "div.hidden"
      end

      def test_items_visible_when_not_collapsed
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true, collapsed: false)) do |section|
          section.item(text: "Item 1", href: "/path1")
        end
        refute_selector "div.space-y-1.hidden"
        assert_selector "a[href='/path1']"
      end

      def test_chevron_rotated_when_not_collapsed
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true, collapsed: false))
        assert_selector "svg.rotate-180"
      end

      def test_chevron_not_rotated_when_collapsed
        render_inline(NavSectionComponent.new(title: "Section", collapsible: true, collapsed: true))
        refute_selector "svg.rotate-180"
      end

      # Items tests
      def test_renders_with_items
        render_inline(NavSectionComponent.new(title: "Section")) do |section|
          section.item(text: "Item 1", href: "/path1")
          section.item(text: "Item 2", href: "/path2")
        end
        assert_selector "a[href='/path1']", text: "Item 1"
        assert_selector "a[href='/path2']", text: "Item 2"
      end

      def test_renders_with_content
        render_inline(NavSectionComponent.new) do
          "Custom content"
        end
        assert_text "Custom content"
      end

      # Styling tests
      def test_title_styling
        render_inline(NavSectionComponent.new(title: "Section"))
        assert_selector ".text-xs.font-semibold.uppercase.tracking-wider"
        assert_selector ".text-\\[var\\(--color-muted-foreground\\)\\]"
      end

      def test_items_container_spacing
        render_inline(NavSectionComponent.new) do |section|
          section.item(text: "Item", href: "/")
        end
        assert_selector "div.space-y-1"
      end

      # Custom attributes tests
      def test_merges_custom_classes
        render_inline(NavSectionComponent.new(class: "custom-section"))
        assert_selector "div.custom-section"
      end

      def test_merges_custom_data_attributes
        render_inline(NavSectionComponent.new(data: { test: "value" }))
        assert_selector "div[data-test='value']"
      end
    end
  end
end
