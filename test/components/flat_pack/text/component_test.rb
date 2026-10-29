# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Text
    class ComponentTest < ViewComponent::TestCase
      def test_renders_paragraph_at_base_by_default
        render_inline(Component.new(text: "We sent a link to your inbox."))

        assert_selector "p.fp-text", text: "We sent a link to your inbox."
        html = page.native.to_html
        assert_includes html, "text-[length:var(--text-base)]"
        assert_includes html, "font-normal"
        assert_includes html, "text-[var(--surface-content-color)]"
        assert_includes html, "fp-text-pretty"
        refute_selector "h1, h2, h3, h4, h5, h6"
      end

      def test_size_style_and_weight
        render_inline(Component.new(
          text: "We sent a link to your inbox.",
          size: :sm,
          style: :muted,
          weight: :medium
        ))

        html = page.native.to_html
        assert_includes html, "text-[length:var(--text-sm)]"
        assert_includes html, "text-[var(--surface-muted-content-color)]"
        assert_includes html, "font-medium"
      end

      def test_primary_style
        render_inline(Component.new(text: "We sent a link to your inbox.", style: :primary))

        assert_includes page.native.to_html, "text-[var(--color-primary)]"
      end

      def test_as_span_and_div
        render_inline(Component.new(text: "Saved", as: :span))
        assert_selector "span.fp-text", text: "Saved"

        render_inline(Component.new(text: "Saved", as: :div))
        assert_selector "div.fp-text", text: "Saved"
      end

      def test_renders_each_size
        Component::SIZES.each_key do |size|
          render_inline(Component.new(text: "Saved", size: size))

          token = (size == :base) ? "base" : size.to_s
          assert_includes page.native.to_html, "text-[length:var(--text-#{token})]"
        end
      end

      def test_renders_block_content_when_text_omitted
        render_inline(Component.new) { "We sent a link to your inbox." }

        assert_selector "p.fp-text", text: "We sent a link to your inbox."
      end

      def test_prefers_text_over_block_content
        render_inline(Component.new(text: "We sent a link to your inbox.")) { "Ignored" }

        assert_selector "p", text: "We sent a link to your inbox."
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
        render_inline(Component.new(text: "Saved", id: "status", class: "mt-1"))

        assert_selector "p#status"
        assert_includes page.native.to_html, "mt-1"
      end

      def test_raises_for_invalid_size_style_weight_and_as
        error = assert_raises(ArgumentError) { Component.new(text: "Saved", size: :"5xl") }
        assert_includes error.message, "Invalid size"

        error = assert_raises(ArgumentError) { Component.new(text: "Saved", style: :danger) }
        assert_includes error.message, "Invalid style"

        error = assert_raises(ArgumentError) { Component.new(text: "Saved", weight: :black) }
        assert_includes error.message, "Invalid weight"

        error = assert_raises(ArgumentError) { Component.new(text: "Saved", as: :h2) }
        assert_includes error.message, "Invalid as"
      end

      def test_explicit_defaults_match_omitted
        omitted = render_inline(Component.new(text: "Saved")).to_html
        explicit = render_inline(Component.new(
          text: "Saved",
          size: :base,
          style: :default,
          weight: :normal,
          as: :p
        )).to_html

        assert_equal omitted, explicit
      end
    end
  end
end
