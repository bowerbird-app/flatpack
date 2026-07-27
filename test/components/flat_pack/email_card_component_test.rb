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

        assert_includes page.native.to_html, "max-width:600px"
      end

      def test_applies_custom_max_width_and_alignment
        render_inline(Component.new(max_width: 420, align: :right)) { "Content" }

        html = page.native.to_html
        assert_includes html, "max-width:420px"
        assert_selector "td[align='right']"
      end
    end
  end
end
