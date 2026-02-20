# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageTitle
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_title_with_title
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "h1", text: "Dashboard"
      end

      def test_renders_page_title_without_border_divider
        render_inline(Component.new(title: "Dashboard"))

        refute_selector "div.border-b"
      end

      def test_renders_page_title_with_bottom_padding
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "div.pb-8"
      end

      def test_renders_page_title_with_subtitle
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back"))

        assert_selector "p", text: "Welcome back"
      end
    end
  end
end
