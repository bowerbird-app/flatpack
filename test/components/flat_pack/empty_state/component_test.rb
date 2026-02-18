# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmptyState
    class ComponentTest < ViewComponent::TestCase
      def test_renders_empty_state_with_title
        render_inline(Component.new(title: "No results found"))

        assert_selector "h3", text: "No results found"
      end

      def test_renders_empty_state_with_description
        render_inline(Component.new(
          title: "No results",
          description: "Try adjusting your search"
        ))

        assert_selector "h3", text: "No results"
        assert_selector "p", text: "Try adjusting your search"
      end

      def test_renders_default_inbox_icon
        render_inline(Component.new(title: "Empty"))

        assert_selector "svg"
      end

      def test_renders_search_icon
        render_inline(Component.new(title: "No results", icon: :search))

        assert_selector "svg"
      end

      def test_renders_actions_slot
        render_inline(Component.new(title: "Empty")) do |component|
          component.with_actions do
            "Action buttons"
          end
        end

        assert_text "Action buttons"
      end

      def test_renders_custom_graphic_slot
        render_inline(Component.new(title: "Empty")) do |component|
          component.with_graphic do
            "Custom graphic"
          end
        end

        assert_text "Custom graphic"
        # Should not render default icon when custom graphic provided
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_icon
        assert_raises(ArgumentError) do
          Component.new(title: "Empty", icon: :invalid)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(title: "Empty", class: "custom-class"))

        assert_selector "div.custom-class"
      end
    end
  end
end
