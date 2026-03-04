# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageTitle
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_title_with_title
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "h1", text: "Dashboard"
      end

      def test_renders_supported_heading_variants
        %i[h1 h2 h3 h4 h5 h6].each do |variant|
          render_inline(Component.new(title: "Dashboard", variant: variant))

          assert_selector variant.to_s, text: "Dashboard"
        end
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

      def test_raises_error_for_invalid_variant
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(title: "Dashboard", variant: :heading))
        end

        assert_includes error.message, "Invalid variant"
      end
    end
  end
end
