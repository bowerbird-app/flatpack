# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Tooltip
    class ComponentTest < ViewComponent::TestCase
      def test_renders_tooltip_with_text
        render_inline(Component.new(text: "Helpful tip")) do
          "Hover me"
        end

        assert_text "Hover me"
        assert_text "Helpful tip"
      end

      def test_renders_tooltip_with_content_slot
        render_inline(Component.new) do |component|
          component.with_tooltip_content { "Custom tooltip content" }
          "Trigger element"
        end

        assert_text "Trigger element"
        assert_text "Custom tooltip content"
      end

      def test_tooltip_has_role
        render_inline(Component.new(text: "Tip")) do
          "Trigger"
        end

        assert_selector "div[role='tooltip']"
      end

      def test_tooltip_has_stimulus_controller
        render_inline(Component.new(text: "Tip")) do
          "Trigger"
        end

        assert_selector "div[data-controller='flat-pack--tooltip']"
      end

      def test_tooltip_placement_top
        render_inline(Component.new(text: "Tip", placement: :top)) do
          "Trigger"
        end

        assert_selector "div[data-flat-pack--tooltip-placement-value='top']"
      end

      def test_tooltip_placement_bottom
        render_inline(Component.new(text: "Tip", placement: :bottom)) do
          "Trigger"
        end

        assert_selector "div[data-flat-pack--tooltip-placement-value='bottom']"
      end

      def test_tooltip_placement_left
        render_inline(Component.new(text: "Tip", placement: :left)) do
          "Trigger"
        end

        assert_selector "div[data-flat-pack--tooltip-placement-value='left']"
      end

      def test_tooltip_placement_right
        render_inline(Component.new(text: "Tip", placement: :right)) do
          "Trigger"
        end

        assert_selector "div[data-flat-pack--tooltip-placement-value='right']"
      end

      def test_tooltip_hidden_by_default
        render_inline(Component.new(text: "Tip")) do
          "Trigger"
        end

        assert_selector "div.hidden"
      end

      def test_raises_error_for_invalid_placement
        assert_raises(ArgumentError) do
          Component.new(text: "Tip", placement: :invalid)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(text: "Tip", class: "custom-class")) do
          "Trigger"
        end

        assert_selector "div.custom-class"
      end
    end
  end
end
