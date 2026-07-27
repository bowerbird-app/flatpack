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
      end

      def test_renders_secondary_variant_styles
        render_inline(Component.new(href: "https://example.com", label: "Secondary", variant: :secondary))

        html = page.native.to_html
        assert_includes html, "background-color:#f3f4f6"
        assert_includes html, "border:1px solid #d1d5db"
      end

      def test_renders_full_width_button
        render_inline(Component.new(href: "https://example.com", label: "Full Width", full_width: true))

        assert_selector "table[width='100%']"
        assert_includes page.native.to_html, "display:block"
      end
    end
  end
end
