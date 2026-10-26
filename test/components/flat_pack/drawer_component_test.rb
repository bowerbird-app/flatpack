# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Drawer
    class ComponentTest < ViewComponent::TestCase
      def test_renders_dialog_on_an_edge
        render_inline(Component.new(id: "filters-drawer", title: "Filters", side: :right)) do |drawer|
          drawer.body { "Narrow the list." }
        end

        html = page.native.to_html

        assert_includes html, "data-controller=\"flat-pack--drawer\""
        refute_includes html, "flat-pack--modal-origin-value"
        refute_includes html, "trigger_origin"
        assert_includes html, "z-[70]"
        refute_includes html, "fixed inset-0 z-50 hidden"
        assert_includes html, "fp-drawer-body"
        assert_selector "[role='dialog'][aria-modal='true']"
        assert_selector "h2", text: "Filters"
        assert_selector ".fp-drawer__close button.fp-button[data-fp-style='ghost'][aria-label='Close'][data-action='flat-pack--drawer#close']"
        assert_text "Narrow the list."
      end

      def test_invalid_side_raises
        error = assert_raises(ArgumentError) { Component.new(id: "x", side: :top) }

        assert_match(/Invalid side/, error.message)
      end

      def test_panel_transitions_translate
        render_inline(Component.new(id: "filters-drawer", title: "Filters", side: :left)) do |drawer|
          drawer.body { "Narrow the list." }
        end

        html = page.native.to_html

        assert_includes html, "transition-[opacity,translate]"
        assert_includes html, "-translate-x-full"
      end

      def test_blank_id_raises
        error = assert_raises(ArgumentError) { Component.new(id: "") }

        assert_equal "id is required", error.message
      end

      def test_body_hides_the_bar_and_is_a_named_region
        render_inline(Component.new(id: "filters-drawer", title: "Filters")) do |drawer|
          drawer.body { "Narrow the list." }
        end

        body = page.find(".fp-drawer-body")
        assert_includes body[:class], "fp-pane-scroll"
        assert_equal "region", body["role"]
        assert_equal "0", body["tabindex"]
        assert_equal "Drawer", body["aria-label"]
        assert_nil body["data-pane-scrollbar"]
        assert_selector "[role='dialog']"
      end

      def test_visible_scrollbar_uses_the_browser_bar
        render_inline(Component.new(id: "filters-drawer", scrollbar: :visible)) do |drawer|
          drawer.body { "Narrow the list." }
        end

        body = page.find(".fp-drawer-body")
        assert_equal "visible", body["data-pane-scrollbar"]
        assert_nil body["tabindex"]
        assert_nil body["role"]
      end

      def test_scrollbar_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(id: "filters-drawer", scrollbar: :thin) }

        assert_equal "scrollbar must be :hidden or :visible", error.message
      end
    end
  end
end
