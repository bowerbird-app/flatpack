# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmailButton
    class ComponentTest < ViewComponent::TestCase
      def test_renders_table_based_button_markup
        render_inline(Component.new(href: "https://example.com", label: "Confirm"))

        assert_selector "table[role='presentation'] tr td a[href='https://example.com']", text: "Confirm"
      end

      def test_renders_primary_variant_styles
        render_inline(Component.new(href: "https://example.com", label: "Primary", variant: :primary))

        html = page.native.to_html
        assert_includes html, "background-color:#2563eb"
        assert_includes html, "color:#ffffff"
        assert_includes html, "background-color:var(--button-primary-background-color, #2563eb)"
        assert_includes html, "border:1px solid var(--button-primary-border-color, #2563eb)"
        assert_includes html, "color:var(--button-primary-text-color, #ffffff)"
      end

      def test_renders_secondary_variant_styles
        render_inline(Component.new(href: "https://example.com", label: "Secondary", variant: :secondary))

        html = page.native.to_html
        assert_includes html, "background-color:#f3f4f6"
        assert_includes html, "border:1px solid #d1d5db"
        assert_includes html, "background-color:var(--button-secondary-background-color, #f3f4f6)"
        assert_includes html, "border:1px solid var(--button-secondary-border-color, #d1d5db)"
        assert_includes html, "color:var(--button-secondary-text-color, #374151)"
      end

      def test_renders_full_width_button
        render_inline(Component.new(href: "https://example.com", label: "Full Width", full_width: true))

        assert_selector "table[width='100%']"
        assert_includes page.native.to_html, "display:block"
      end

      def test_renders_fit_content_button
        render_inline(Component.new(href: "https://example.com", label: "Fit Content", fit_content: true))

        html = page.native.to_html
        assert_includes html, "width:auto;"
        assert_includes html, "display:inline-table"
      end

      def test_renders_alignment_styles
        render_inline(Component.new(href: "https://example.com", label: "Right aligned", align: :right, full_width: true))

        html = page.native.to_html
        assert_includes html, 'td align="right"'
        assert_includes html, "text-align:right"
      end

      def test_raises_when_full_width_and_fit_content_are_both_enabled
        error = assert_raises(ArgumentError) do
          Component.new(href: "https://example.com", label: "Invalid", full_width: true, fit_content: true)
        end

        assert_equal "full_width and fit_content cannot both be true", error.message
      end
    end
  end
end
