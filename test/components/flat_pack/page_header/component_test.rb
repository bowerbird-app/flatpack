# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageHeader
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_header_with_title
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "h1", text: "Dashboard"
      end

      def test_renders_page_header_with_subtitle
        render_inline(Component.new(
          title: "Dashboard",
          subtitle: "Welcome back"
        ))

        assert_selector "h1", text: "Dashboard"
        assert_selector "p", text: "Welcome back"
      end

      def test_renders_breadcrumb_slot
        render_inline(Component.new(title: "Dashboard")) do |component|
          component.with_breadcrumb do
            "Home > Dashboard"
          end
        end

        assert_text "Home > Dashboard"
      end

      def test_renders_actions_slot
        render_inline(Component.new(title: "Dashboard")) do |component|
          component.with_actions do
            "Action buttons"
          end
        end

        assert_text "Action buttons"
      end

      def test_renders_meta_slot
        render_inline(Component.new(title: "Dashboard")) do |component|
          component.with_meta do
            "Meta information"
          end
        end

        assert_text "Meta information"
      end

      def test_renders_all_slots_together
        render_inline(Component.new(
          title: "Dashboard",
          subtitle: "Overview"
        )) do |component|
          component.with_breadcrumb { "Breadcrumb" }
          component.with_actions { "Actions" }
          component.with_meta { "Meta" }
        end

        assert_selector "h1", text: "Dashboard"
        assert_selector "p", text: "Overview"
        assert_text "Breadcrumb"
        assert_text "Actions"
        assert_text "Meta"
      end

      def test_has_border_bottom
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "div.border-b"
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(title: "Dashboard", class: "custom-class"))

        assert_selector "div.custom-class"
      end
    end
  end
end
