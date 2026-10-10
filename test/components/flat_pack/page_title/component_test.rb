# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageTitle
    class ComponentTest < ViewComponent::TestCase
      def test_renders_page_title_with_title
        render_inline(Component.new(title: "Dashboard"))

        assert_selector "h1", text: "Dashboard"
        assert_includes page.native.to_html, "fp-text-balance"
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

      def test_renders_slot_below_subtitle
        render_inline(Component.new(title: "Dashboard", subtitle: "Welcome back")) do |component|
          component.slot do
            "Filter"
          end
        end

        assert_selector "p + div.page-title-actions", text: "Filter"
      end

      def test_renders_slot_below_title_when_subtitle_missing
        render_inline(Component.new(title: "Dashboard")) do |component|
          component.slot do
            "Filter"
          end
        end

        assert_selector "h1 + div.page-title-actions", text: "Filter"
      end

      def test_actions_is_deprecated_in_favor_of_slot
        _stdout, stderr = capture_io do
          render_inline(Component.new(title: "Dashboard")) do |component|
            component.actions { "Filter" }
          end
        end

        assert_includes stderr, "FlatPack::PageTitle::Component#actions is deprecated"
        assert_includes stderr, "#slot"
      end

      def test_raises_error_for_invalid_variant
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(title: "Dashboard", variant: :heading))
        end

        assert_includes error.message, "Invalid variant"
      end

      def test_default_size_keeps_page_title_heading_token
        render_inline(Component.new(title: "Dashboard"))

        html = page.native.to_html
        assert_selector "h1[style*='font-size: var(--page-title-h1-size)']", text: "Dashboard"
        assert_includes html, "font-bold"
        assert_includes html, "leading-tight"
        refute_includes html, "fp-display"
        refute_includes html, "--display-size"
        refute_includes html, "--display-weight"
      end

      def test_display_size_uses_display_tokens
        render_inline(Component.new(title: "Northlight", size: :display))

        html = page.native.to_html
        assert_selector "h1.fp-display", text: "Northlight"
        assert_includes html, "font-size: var(--display-size)"
        assert_includes html, "font-weight: var(--display-weight)"
        assert_includes html, "letter-spacing: var(--display-tracking)"
        assert_includes html, "line-height: var(--display-leading)"
        assert_includes html, "fp-text-balance"
        refute_includes html, "font-bold"
        refute_includes html, "leading-tight"
        refute_includes html, "--page-title-h1-size"
      end

      def test_display_subtitle_spacing_scales
        render_inline(Component.new(
          title: "Northlight",
          subtitle: "Stills, credits, and download packs",
          size: :display
        ))

        assert_selector "p.fp-display-subtitle", text: "Stills, credits, and download packs"
        assert_selector "p.text-lg"
        refute_selector "p.mt-2"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(title: "Dashboard", size: :huge))
        end

        assert_includes error.message, "Invalid size"
      end
    end
  end
end
