# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Popover
    class ComponentTest < ViewComponent::TestCase
      def test_sets_popover_content_with_short_builder
        render_inline(Component.new(trigger_id: "account-trigger")) do |popover|
          popover.popover_content { "Popover body" }
        end

        assert_selector "[aria-hidden='true']", text: "Popover body"
      end

      def test_does_not_expose_with_popover_content_helper
        component = Component.new(trigger_id: "account-trigger")

        refute component.respond_to?(:with_popover_content, true)
      end
    end
  end
end
