# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SegmentedButtons
    class ComponentTest < ViewComponent::TestCase
      def test_renders_segmented_buttons
        render_inline(Component.new) do |group|
          group.with_button(text: "Day", selected: true)
          group.with_button(text: "Week")
          group.with_button(text: "Month")
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 3
      end

      def test_selected_button_uses_primary_scheme
        render_inline(Component.new) do |group|
          group.with_button(text: "Selected", selected: true)
          group.with_button(text: "Not Selected")
        end

        # The selected button should have primary styling
        assert_selector "button", count: 2
      end
    end
  end
end
