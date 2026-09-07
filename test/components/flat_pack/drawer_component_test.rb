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
        assert_includes html, "fp-overlay-pad"
        assert_includes html, "fp-drawer-body"
        assert_selector "[role='dialog'][aria-modal='true']"
        assert_selector "h2", text: "Filters"
        assert_text "Narrow the list."
      end

      def test_invalid_side_raises
        error = assert_raises(ArgumentError) { Component.new(id: "x", side: :top) }

        assert_match(/Invalid side/, error.message)
      end

      def test_blank_id_raises
        error = assert_raises(ArgumentError) { Component.new(id: "") }

        assert_equal "id is required", error.message
      end
    end
  end
end
