# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SegmentedButtons
    class ComponentTest < ViewComponent::TestCase
      def test_renders_segmented_buttons
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
          group.button(text: "Month")
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 3
      end

      def test_selected_button_uses_primary_scheme
        render_inline(Component.new) do |group|
          group.button(text: "Selected", selected: true)
          group.button(text: "Not Selected")
        end

        # The selected button should have primary styling
        assert_selector "button", count: 2
      end

      def test_does_not_expose_with_button_helper
        component = Component.new

        refute component.respond_to?(:with_button, true)
      end

      def test_group_size_forwards_to_buttons
        render_inline(Component.new(size: :sm)) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:sm)
      end

      def test_default_group_size_is_medium
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
        end

        assert_includes page.native.to_html, FlatPack::Button::Component::SIZES.fetch(:md)
      end

      def test_button_size_overrides_group_size
        render_inline(Component.new(size: :sm)) do |group|
          group.button(text: "Day", selected: true, size: :lg)
          group.button(text: "Week")
        end

        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:lg)
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:sm)
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end
    end
  end
end
