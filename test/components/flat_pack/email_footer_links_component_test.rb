# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmailFooterLinks
    class ComponentTest < ViewComponent::TestCase
      def test_renders_table_structure_with_links
        render_inline(Component.new(links: links))

        assert_selector "table[role='presentation'][width='100%'] tr td"
        assert_selector "a[href='https://example.com/privacy']", text: "Privacy"
        assert_selector "a[href='https://example.com/terms']", text: "Terms"
      end

      def test_renders_explicit_link_separator_text
        render_inline(Component.new(links: links))

        assert_includes page.native.to_html, " | "
      end

      def test_applies_muted_typography_styles
        render_inline(Component.new(links: links, color: "#9ca3af", font_size: "11px"))

        html = page.native.to_html
        assert_includes html, "color:#9ca3af"
        assert_includes html, "font-size:11px"
      end

      private

      def links
        [
          {label: "Privacy", href: "https://example.com/privacy"},
          {label: "Terms", href: "https://example.com/terms"}
        ]
      end
    end
  end
end
