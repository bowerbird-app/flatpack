# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Tooltip
    class ComponentTest < ViewComponent::TestCase
      def test_sets_tooltip_content_with_short_builder
        render_inline(Component.new) do |tooltip|
          tooltip.tooltip_content { "Tooltip body" }
          "Trigger"
        end

        assert_selector "[role='tooltip']", text: "Tooltip body"
        assert_text "Trigger"
      end

      def test_does_not_expose_with_tooltip_content_helper
        component = Component.new

        refute component.respond_to?(:with_tooltip_content, true)
      end
    end
  end
end
