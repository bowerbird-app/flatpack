# frozen_string_literal: true

require "test_helper"

module FlatPack
  module HeroTitle
    class ComponentTest < ViewComponent::TestCase
      def test_renders_text_as_h1_by_default
        render_inline(Component.new(text: "Northlight"))

        assert_selector "h1", text: "Northlight"
        html = page.native.to_html
        assert_includes html, "fp-hero-title"
        assert_includes html, "fp-hero-title--xl"
        assert_includes html, "fp-display"
        assert_includes html, "fp-text-balance"
        assert_includes html, "font-size: var(--display-size)"
        assert_includes html, "font-weight: var(--display-weight)"
        assert_includes html, "letter-spacing: var(--display-tracking)"
        assert_includes html, "line-height: var(--display-leading)"
        assert_includes html, "text-[var(--surface-content-color)]"
      end

      def test_caller_text_color_wins_over_surface_ink
        render_inline(Component.new(
          text: "Northlight",
          class: "text-[var(--hero-overlay-text-color)]"
        ))

        html = page.native.to_html
        assert_includes html, "text-[var(--hero-overlay-text-color)]"
        refute_includes html, "text-[var(--surface-content-color)]"
      end

      def test_renders_block_content_when_text_omitted
        render_inline(Component.new) { "Northlight collection" }

        assert_selector "h1", text: "Northlight collection"
      end

      def test_prefers_text_over_block_content
        render_inline(Component.new(text: "Northlight")) { "Ignored" }

        assert_selector "h1", text: "Northlight"
        refute_text "Ignored"
      end

      def test_requires_text_or_content
        error = assert_raises(ArgumentError) do
          render_inline(Component.new)
        end

        assert_includes error.message, "text is required"
      end

      def test_md_lg_xxl_use_hero_title_size_tokens
        {
          md: "--hero-title-md-size",
          lg: "--hero-title-lg-size",
          xxl: "--hero-title-xxl-size"
        }.each do |size, token|
          render_inline(Component.new(text: "Northlight", size: size))

          html = page.native.to_html
          assert_includes html, "fp-hero-title--#{size}"
          assert_includes html, "font-size: var(#{token})"
          refute_includes html, "fp-display"
          refute_includes html, "font-size: var(--display-size)"
        end
      end

      def test_xl_is_the_default_and_matches_display_size
        omitted = render_inline(Component.new(text: "Northlight")).to_html
        explicit = render_inline(Component.new(text: "Northlight", size: :xl)).to_html

        assert_equal omitted, explicit
        assert_includes explicit, "fp-display"
        assert_includes explicit, "font-size: var(--display-size)"
      end

      def test_renders_heading_levels
        %i[h1 h2 h3 h4 h5 h6].each do |level|
          render_inline(Component.new(text: "Northlight", level: level))

          assert_selector level.to_s, text: "Northlight"
        end
      end

      def test_align_left_and_center
        render_inline(Component.new(text: "Northlight", align: :left))
        assert_includes page.native.to_html, "text-left"

        render_inline(Component.new(text: "Northlight", align: :center))
        assert_includes page.native.to_html, "text-center"
      end

      def test_omitted_align_does_not_force_text_alignment
        render_inline(Component.new(text: "Northlight"))

        html = page.native.to_html
        refute_includes html, "text-left"
        refute_includes html, "text-center"
      end

      def test_forwards_system_arguments
        render_inline(Component.new(text: "Northlight", id: "cover", class: "mt-2"))

        assert_selector "h1#cover"
        assert_includes page.native.to_html, "mt-2"
      end

      def test_raises_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(text: "Northlight", size: :huge)
        end

        assert_includes error.message, "Invalid size"
        assert_includes error.message, "md"
        assert_includes error.message, "xl"
      end

      def test_raises_for_invalid_level
        error = assert_raises(ArgumentError) do
          Component.new(text: "Northlight", level: :div)
        end

        assert_includes error.message, "Invalid level"
      end

      def test_raises_for_invalid_align
        error = assert_raises(ArgumentError) do
          Component.new(text: "Northlight", align: :right)
        end

        assert_includes error.message, "Invalid align"
        assert_includes error.message, "left"
        assert_includes error.message, "center"
      end
    end
  end
end
