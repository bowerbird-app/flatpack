# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Heading
    class ComponentTest < ViewComponent::TestCase
      def test_renders_h2_at_two_xl_by_default
        render_inline(Component.new(text: "Verify your email"))

        assert_selector "h2.fp-heading", text: "Verify your email"
        html = page.native.to_html
        assert_includes html, "text-[length:var(--text-2xl)]"
        assert_includes html, "font-semibold"
        assert_includes html, "text-[var(--surface-content-color)]"
        assert_includes html, "fp-text-balance"
        assert_includes html, "leading-tight"
        refute_selector "div.fp-section-title"
        refute_selector "h1"
      end

      def test_level_and_size_are_independent
        render_inline(Component.new(text: "Clip stats", level: :h1, size: :lg))

        assert_selector "h1", text: "Clip stats"
        html = page.native.to_html
        assert_includes html, "text-[length:var(--text-lg)]"
        refute_includes html, "text-[length:var(--text-2xl)]"
        refute_selector "h2"
      end

      def test_renders_each_heading_level
        Component::LEVELS.each do |level|
          render_inline(Component.new(text: "Clip stats", level: level))

          assert_selector level.to_s, text: "Clip stats"
        end
      end

      def test_accepts_integer_and_numeric_string_levels
        render_inline(Component.new(text: "Clip stats", level: 3))
        assert_selector "h3", text: "Clip stats"

        render_inline(Component.new(text: "Clip stats", level: "4"))
        assert_selector "h4", text: "Clip stats"
      end

      def test_renders_each_size
        Component::SIZES.each_key do |size|
          render_inline(Component.new(text: "Clip stats", size: size))

          token = (size == :base) ? "base" : size.to_s
          assert_includes page.native.to_html, "text-[length:var(--text-#{token})]"
        end
      end

      def test_style_and_weight
        render_inline(Component.new(text: "Clip stats", style: :muted, weight: :bold))

        html = page.native.to_html
        assert_includes html, "text-[var(--surface-muted-content-color)]"
        assert_includes html, "font-bold"
        refute_includes html, "font-semibold"
      end

      def test_primary_style
        render_inline(Component.new(text: "Clip stats", style: :primary))

        assert_includes page.native.to_html, "text-[var(--color-primary)]"
      end

      def test_renders_block_content_when_text_omitted
        render_inline(Component.new) { "Verify your email" }

        assert_selector "h2", text: "Verify your email"
      end

      def test_prefers_text_over_block_content
        render_inline(Component.new(text: "Verify your email")) { "Ignored" }

        assert_selector "h2", text: "Verify your email"
        refute_text "Ignored"
      end

      def test_requires_text_or_content
        error = assert_raises(ArgumentError) { render_inline(Component.new) }

        assert_includes error.message, "text is required"
      end

      def test_html_safe_text_raises
        error = assert_raises(ArgumentError) do
          Component.new(text: "<em>Hi</em>".html_safe)
        end

        assert_equal "text must be a String", error.message
      end

      def test_forwards_system_arguments
        render_inline(Component.new(text: "Clip stats", id: "stats", class: "mt-2"))

        assert_selector "h2#stats"
        assert_includes page.native.to_html, "mt-2"
      end

      def test_raises_for_invalid_level_size_style_and_weight
        error = assert_raises(ArgumentError) { Component.new(text: "Clip stats", level: :div) }
        assert_includes error.message, "Invalid level"

        error = assert_raises(ArgumentError) { Component.new(text: "Clip stats", size: :display) }
        assert_includes error.message, "Invalid size"

        error = assert_raises(ArgumentError) { Component.new(text: "Clip stats", style: :danger) }
        assert_includes error.message, "Invalid style"

        error = assert_raises(ArgumentError) { Component.new(text: "Clip stats", weight: :black) }
        assert_includes error.message, "Invalid weight"
      end

      def test_explicit_defaults_match_omitted
        omitted = render_inline(Component.new(text: "Clip stats")).to_html
        explicit = render_inline(Component.new(
          text: "Clip stats",
          level: :h2,
          size: :"2xl",
          style: :default,
          weight: :semibold
        )).to_html

        assert_equal omitted, explicit
      end
    end
  end
end
