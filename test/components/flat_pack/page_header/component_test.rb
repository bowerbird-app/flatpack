# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageHeader
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_header_with_title
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "h1", text: "Dashboard"
        assert_selector "h1.text-4xl", text: "Dashboard"
      end

      def test_renders_page_header_with_subtitle
        render_inline(Component.new(
          title: "Dashboard",
          subtitle: "Welcome back"
        ))

        assert_selector "h1", text: "Dashboard"
        assert_selector "p", text: "Welcome back"
        assert_selector "p.text-lg", text: "Welcome back"
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
