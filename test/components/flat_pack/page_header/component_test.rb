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
        assert_no_selector "p[style*='font-size: var(--page-title-h1-size']"
      end

      def test_renders_large_subtitle_styles
        render_inline(Component.new(
          title: "Dashboard",
          subtitle: "Welcome back",
          large_subtitle: true
        ))

        assert_selector "p[style*='font-size: var(--page-title-h1-size, 2.25rem)']", text: "Welcome back"
        assert_selector "p[style*='font-weight: bold']", text: "Welcome back"
        assert_selector "p[style*='margin-top: 0']", text: "Welcome back"
        assert_no_selector "p.text-lg"
      end

      def test_renders_title_color_override
        render_inline(Component.new(title: "Dashboard", title_color: "#334455"))

        assert_selector "h1[style*='color: #334455']", text: "Dashboard"
      end

      def test_renders_subtitle_color_override
        render_inline(Component.new(
          title: "Dashboard",
          subtitle: "Welcome back",
          subtitle_color: "var(--color-primary)"
        ))

        assert_selector "p[style*='color: var(--color-primary)']", text: "Welcome back"
      end

      def test_does_not_have_border_bottom
        render_inline(Component.new(title: "Dashboard"))

        assert_no_selector "div.border-b"
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
