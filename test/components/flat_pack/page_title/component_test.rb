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

      def test_renders_page_title_without_bottom_padding
        render_inline(Component.new(title: "Dashboard"))

        refute_selector "div.pb-8"
      end

      def test_renders_page_title_with_subtitle
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back"))

        assert_selector "p", text: "Welcome back"
        assert_selector "p.mt-2.text-lg", text: "Welcome back"
        assert_no_selector "p[style*='font-size: var(--page-title-h1-size']"
      end

      def test_renders_large_subtitle_styles
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back", large_subtitle: true))

        assert_selector "p[style*='font-size: var(--page-title-h1-size)']", text: "Welcome back"
        assert_selector "p[style*='font-weight: bold']", text: "Welcome back"
        assert_selector "p[style*='margin-top: 0']", text: "Welcome back"
        assert_no_selector "p.mt-2.text-lg"
      end

      def test_large_subtitle_matches_all_variant_sizes
        %i[h1 h2 h3 h4 h5 h6].each do |variant|
          render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back", variant: variant, large_subtitle: true))

          assert_selector "#{variant}[style*='font-size: var(--page-title-#{variant}-size)']", text: "Dashboard"
          assert_selector "p[style*='font-size: var(--page-title-#{variant}-size)']", text: "Welcome back"
        end
      end

      def test_renders_title_color_override
        render_inline(Component.new(title: "Dashboard", variant: :h3, title_color: "#123456"))

        assert_selector "h3[style*='color: #123456']", text: "Dashboard"
      end

      def test_renders_subtitle_color_override
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back", subtitle_color: "var(--color-primary)"))

        assert_selector "p[style*='color: var(--color-primary)']", text: "Welcome back"
      end

      def test_renders_actions_slot_below_subtitle
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back")) do |component|
          component.actions do
            "Filter"
          end
        end

        assert_selector "p + div.page-title-actions", text: "Filter"
      end

      def test_renders_actions_slot_below_title_when_subtitle_missing
        render_inline(Component.new(title: "Dashboard")) do |component|
          component.actions do
            "Filter"
          end
        end

        assert_selector "h1 + div.page-title-actions", text: "Filter"
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
