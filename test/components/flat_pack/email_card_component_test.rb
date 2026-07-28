# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmailCard
    class ComponentTest < ViewComponent::TestCase
      def test_renders_email_safe_table_structure
        render_inline(Component.new) { "Card body" }

        assert_selector "table[role='presentation'][width='100%']"
        assert_selector "table tr td", text: "Card body"
      end

      def test_uses_default_max_width
        render_inline(Component.new) { "Content" }

        html = page.native.to_html
        assert_includes html, "max-width:600px"
        assert_includes html, "border-collapse:separate"
        assert_includes html, "border-spacing:0"
        assert_includes html, "background-color:var(--card-background-color, var(--surface-background-color, #ffffff))"
        assert_includes html, "border:1px solid var(--card-border-color, var(--surface-border-color, #e5e7eb))"
        assert_includes html, "border-radius:var(--radius-lg, 8px)"
        assert_includes html, "color:var(--surface-content-color, #111827)"
      end

      def test_applies_custom_max_width_and_alignment
        render_inline(Component.new(max_width: 420, align: :right)) { "Content" }

        html = page.native.to_html
        assert_includes html, "max-width:420px"
        assert_selector "td[align='right']"
      end

      def test_custom_colors_do_not_add_theme_background_or_border_overrides
        render_inline(Component.new(bg_color: "#f8fafc", border_color: "#cbd5e1")) { "Content" }

        html = page.native.to_html
        assert_includes html, "background-color:#f8fafc"
        assert_includes html, "border:1px solid #cbd5e1"
        refute_includes html, "background-color:var(--card-background-color"
        refute_includes html, "border:1px solid var(--card-border-color"
      end
    end
  end
end
