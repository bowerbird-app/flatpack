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

      def test_omitted_max_height_leaves_the_shell_uncapped
        render_inline(Component.new(trigger_id: "account-trigger")) do |popover|
          popover.popover_content { "Popover body" }
        end

        root = page.find("[data-controller='flat-pack--popover']", visible: :all)

        refute_includes root[:class].to_s, "overflow-y-auto"
        refute_includes root[:style].to_s, "max-height"
      end

      def test_max_height_caps_the_shell
        render_inline(Component.new(trigger_id: "account-trigger", max_height: " 9rem ")) do |popover|
          popover.popover_content { "Popover body" }
        end

        root = page.find("[data-controller='flat-pack--popover']", visible: :all)

        assert_includes root[:class], "overflow-y-auto"
        assert_equal "max-height: 9rem;", root[:style]
      end

      def test_max_height_rejects_a_class_name
        error = assert_raises(ArgumentError) { Component.new(trigger_id: "account-trigger", max_height: "max-h-96") }

        assert_match(/max_height:/, error.message)
      end

      def test_max_height_rejects_percent
        error = assert_raises(ArgumentError) { Component.new(trigger_id: "account-trigger", max_height: "50%") }

        assert_match(/max_height:/, error.message)
        assert_match(/Percent/, error.message)
      end
    end
  end
end
