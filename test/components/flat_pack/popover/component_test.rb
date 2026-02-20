# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Popover
    class ComponentTest < ViewComponent::TestCase
      def test_renders_popover_content
        render_inline(Component.new(trigger_id: "test-trigger")) do |component|
          component.with_popover_content { "Popover content" }
        end

        assert_text "Popover content"
      end

      def test_has_stimulus_controller
        render_inline(Component.new(trigger_id: "test-trigger")) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-controller='flat-pack--popover']"
      end

      def test_has_trigger_id_value
        render_inline(Component.new(trigger_id: "my-trigger")) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-flat-pack--popover-trigger-id-value='my-trigger']"
      end

      def test_placement_top
        render_inline(Component.new(trigger_id: "trigger", placement: :top)) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-flat-pack--popover-placement-value='top']"
      end

      def test_placement_bottom
        render_inline(Component.new(trigger_id: "trigger", placement: :bottom)) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-flat-pack--popover-placement-value='bottom']"
      end

      def test_placement_left
        render_inline(Component.new(trigger_id: "trigger", placement: :left)) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-flat-pack--popover-placement-value='left']"
      end

      def test_placement_right
        render_inline(Component.new(trigger_id: "trigger", placement: :right)) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div[data-flat-pack--popover-placement-value='right']"
      end

      def test_hidden_by_default
        render_inline(Component.new(trigger_id: "trigger")) do |component|
          component.with_popover_content { "Content" }
        end

        assert_selector "div.hidden"
        assert_selector "div[aria-hidden='true']"
      end

      def test_raises_error_when_trigger_id_missing
        assert_raises(ArgumentError) do
          Component.new(trigger_id: nil)
        end
      end

      def test_raises_error_for_invalid_placement
        assert_raises(ArgumentError) do
          Component.new(trigger_id: "trigger", placement: :invalid)
        end
      end
    end
  end
end