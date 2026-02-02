# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ButtonGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_group
        render_inline(Component.new) do |group|
          group.with_button(FlatPack::Button::Component.new(text: "Left", style: :secondary))
          group.with_button(FlatPack::Button::Component.new(text: "Right", style: :secondary))
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 2
      end

      def test_applies_group_classes
        render_inline(Component.new) do |group|
          group.with_button(FlatPack::Button::Component.new(text: "Button", style: :secondary))
        end

        assert_selector "div.inline-flex"
      end
    end
  end
end
