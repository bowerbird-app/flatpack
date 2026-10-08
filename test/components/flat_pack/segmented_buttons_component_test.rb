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

      def test_omitted_style_uses_primary_on_the_selected_button
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        assert_selector "button[data-fp-style='primary']", text: "Day"
        assert_selector "button[data-fp-style='secondary']", text: "Week"
      end

      def test_primary_style_uses_primary_on_the_selected_button
        render_inline(Component.new(style: :primary)) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        assert_selector "button[data-fp-style='primary']", text: "Day"
        assert_selector "button[data-fp-style='secondary']", text: "Week"
      end

      def test_default_style_uses_default_on_the_selected_button
        render_inline(Component.new(style: :default)) do |group|
          group.button(text: "List")
          group.button(text: "Grid", selected: true)
        end

        assert_selector "button[data-fp-style='default']", text: "Grid"
        assert_selector "button[data-fp-style='secondary']", text: "List"
      end

      def test_danger_style_uses_danger_on_the_selected_button
        render_inline(Component.new(style: :danger)) do |group|
          group.button(text: "Delete", selected: true)
          group.button(text: "Keep")
        end

        assert_selector "button[data-fp-style='danger']", text: "Delete"
        assert_selector "button[data-fp-style='secondary']", text: "Keep"
      end

      def test_unknown_style_raises_the_button_registry_message
        error = assert_raises(ArgumentError) do
          Component.new(style: :nope)
        end

        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:nope), error.message
      end

      def test_css_string_style_raises_the_button_registry_message
        error = assert_raises(ArgumentError) do
          Component.new(style: "color: red")
        end

        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:"color: red"), error.message
      end

      def test_segment_style_raises
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |group|
            group.button(text: "Day", selected: true, style: :ghost)
          end
        end

        assert_equal "Pass style: to SegmentedButtons, not to a segment.", error.message
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
