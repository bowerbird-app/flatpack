# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ButtonGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_group
        render_inline(Component.new) do |group|
          group.with_button(FlatPack::Button::Component.new(label: "Left", scheme: :secondary))
          group.with_button(FlatPack::Button::Component.new(label: "Right", scheme: :secondary))
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 2
      end

      def test_applies_group_classes
        render_inline(Component.new) do |group|
          group.with_button(FlatPack::Button::Component.new(label: "Button", scheme: :secondary))
        end

        assert_selector "div.inline-flex"
      end
    end
  end
end
