# frozen_string_literal: true

require "test_helper"

module FlatPack
  module OverflowRow
    class ComponentTest < ViewComponent::TestCase
      def test_renders_overflow_row_with_controller
        render_inline(Component.new) { "Item" }

        assert_selector "[data-controller='flat-pack--overflow-row']"
        assert_selector "[data-flat-pack--overflow-row-target='scroller']"
        assert_selector "[data-flat-pack--overflow-row-target='track']", text: "Item"
        assert_selector "[data-can-scroll-end='false']"
      end

      def test_applies_nowrap_and_overflow_classes
        render_inline(Component.new) { "Item" }

        html = page.native.to_html
        assert_includes html, "flex-nowrap"
        assert_includes html, "overflow-x-auto"
        assert_includes html, "overflow-y-hidden"
        assert_includes html, "fp-scrollbar-hidden"
        assert_includes html, "fp-overflow-row-scroller"
        refute_includes html, "flex-wrap"
      end

      def test_defaults_gap_to_md_stack_token
        render_inline(Component.new) { "Item" }

        assert_includes page.native.to_html, "--overflow-row-gap: var(--stack-gap-md)"
        assert_includes page.native.to_html, "gap-[var(--overflow-row-gap)]"
      end

      def test_accepts_gap_presets
        render_inline(Component.new(gap: :sm)) { "Item" }

        assert_includes page.native.to_html, "--overflow-row-gap: var(--stack-gap-sm)"
      end

      def test_rejects_invalid_gap
        assert_raises(ArgumentError) do
          Component.new(gap: :xl)
        end
      end

      def test_yields_children
        render_inline(Component.new) do
          "<span class=\"child-a\">A</span><span class=\"child-b\">B</span>".html_safe
        end

        assert_selector ".child-a", text: "A"
        assert_selector ".child-b", text: "B"
      end

      def test_merges_custom_classes_on_root
        render_inline(Component.new(class: "custom-row")) { "Item" }

        assert_selector "[data-controller='flat-pack--overflow-row'].custom-row"
      end

      def test_accepts_data_and_aria_attributes
        render_inline(Component.new(data: {testid: "overflow-row"}, aria: {label: "Swatches"})) { "Item" }

        assert_selector "[data-testid='overflow-row'][aria-label='Swatches']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(id: "theme-swatches")) { "Item" }

        assert_selector "#theme-swatches[data-controller='flat-pack--overflow-row']"
      end
    end
  end
end
