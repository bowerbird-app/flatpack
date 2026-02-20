# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Accordion
    class ComponentTest < ViewComponent::TestCase
      def test_renders_accordion_container
        render_inline(Component.new)

        assert_selector "[data-controller='flat-pack--accordion']"
      end

      def test_renders_accordion_items
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "First Item") { "Content 1" }
          accordion.item(id: "item2", title: "Second Item") { "Content 2" }
        end

        assert_selector "button", text: "First Item"
        assert_selector "button", text: "Second Item"
        assert_text "Content 1"
        assert_text "Content 2"
      end

      def test_renders_item_with_open_state
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item", open: true) { "Content" }
        end

        assert_selector "button[aria-expanded='true']"
      end

      def test_renders_item_with_closed_state
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item", open: false) { "Content" }
        end

        assert_selector "button[aria-expanded='false']"
      end

      def test_allow_multiple_false_by_default
        render_inline(Component.new)

        assert_selector "[data-flat-pack--accordion-allow-multiple-value='false']"
      end

      def test_allow_multiple_true
        render_inline(Component.new(allow_multiple: true))

        assert_selector "[data-flat-pack--accordion-allow-multiple-value='true']"
      end

      def test_includes_stimulus_targets
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item") { "Content" }
        end

        assert_selector "[data-flat-pack--accordion-target='trigger']"
        assert_selector "[data-flat-pack--accordion-target='content']"
        assert_selector "[data-flat-pack--accordion-target='icon']"
      end

      def test_includes_toggle_action
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item") { "Content" }
        end

        assert_selector "[data-action='flat-pack--accordion#toggle']"
      end

      def test_renders_chevron_icons
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item 1") { "Content" }
          accordion.item(id: "item2", title: "Item 2") { "Content" }
        end

        assert_selector "svg", count: 2
      end

      def test_item_content_has_correct_id
        render_inline(Component.new) do |accordion|
          accordion.item(id: "my-item", title: "Item") { "Content" }
        end

        assert_selector "#my-item-content"
        assert_selector "[aria-controls='my-item-content']"
      end

      def test_renders_with_border_styling
        render_inline(Component.new) do |accordion|
          accordion.item(id: "item1", title: "Item") { "Content" }
        end

        assert_includes page.native.to_html, "border-b"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class")) do |accordion|
          accordion.item(id: "item1", title: "Item") { "Content" }
        end

        assert_selector ".custom-class"
      end
    end
  end
end
