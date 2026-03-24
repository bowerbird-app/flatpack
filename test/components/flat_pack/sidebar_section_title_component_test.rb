# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module SectionTitle
      class ComponentTest < ViewComponent::TestCase
        def test_renders_label_text
          render_inline(Component.new(label: "Getting Started"))

          assert_selector "p", text: "Getting Started"
        end

        def test_renders_with_expanded_padding_by_default
          render_inline(Component.new(label: "Getting Started"))

          assert_selector "div.px-4"
          assert_selector "div.pt-2"
          assert_selector "div.pb-1"
          assert_selector "div.mx-2"
        end

        def test_renders_with_compact_padding_when_collapsed
          render_inline(Component.new(label: "Getting Started", collapsed: true))

          assert_selector "div.px-1"
          refute_selector "div.px-4"
        end

        def test_label_has_truncate_class
          render_inline(Component.new(label: "Getting Started"))

          assert_includes page.native.to_html, "truncate"
        end

        def test_label_centered_when_collapsed
          render_inline(Component.new(label: "Getting Started", collapsed: true))

          assert_includes page.native.to_html, "text-center"
        end

        def test_label_not_centered_when_expanded
          render_inline(Component.new(label: "Getting Started"))

          refute_includes page.native.to_html, "text-center"
        end

        def test_applies_sidebar_text_color_class
          render_inline(Component.new(label: "Getting Started"))

          assert_includes page.native.to_html, "text-[var(--sidebar-item-text-color)]"
        end

        def test_applies_uppercase_typography_classes
          render_inline(Component.new(label: "Getting Started"))

          assert_includes page.native.to_html, "uppercase"
          assert_includes page.native.to_html, "tracking-wider"
          assert_includes page.native.to_html, "font-semibold"
          assert_includes page.native.to_html, "text-xs"
        end

        def test_includes_tooltip_controller_data_attributes
          render_inline(Component.new(label: "Getting Started"))

          assert_selector "div[data-controller='flat-pack--tooltip']"
          assert_selector "div[data-flat-pack--tooltip-placement-value='right']"
          assert_selector "div[data-flat-pack--tooltip-collapsed-only-value='true']"
          assert_selector "div[data-flat-pack-sidebar-section-title='true']"
          assert_selector "[data-flat-pack--tooltip-target='tooltip']", text: "Getting Started"
        end

        def test_tooltip_contains_same_text_as_label
          render_inline(Component.new(label: "Navigation"))

          assert_selector "p", text: "Navigation"
          assert_selector "[data-flat-pack--tooltip-target='tooltip']", text: "Navigation"
        end

        def test_merges_custom_class
          render_inline(Component.new(label: "Getting Started", class: "my-custom"))

          assert_selector "div.my-custom"
        end

        def test_renders_overflow_hidden_for_truncation
          render_inline(Component.new(label: "Getting Started"))

          assert_includes page.native.to_html, "overflow-hidden"
        end
      end
    end
  end
end
