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

      def test_does_not_render_icon_by_default
        render_inline(Component.new(title: "Empty"))

        assert_no_selector "svg"
      end

      def test_renders_explicit_inbox_icon
        render_inline(Component.new(title: "Empty", icon: :inbox))

        assert_selector "svg"
      end

      def test_does_not_render_icon_when_icon_is_nil
        render_inline(Component.new(title: "Empty", icon: nil))

        assert_no_selector "svg"
      end

      def test_renders_search_icon
        render_inline(Component.new(title: "No results", icon: :search))

        assert_selector "svg"
      end

      def test_renders_custom_icon_name
        render_inline(Component.new(title: "No uploads", icon: :upload))

        assert_includes page.native.to_html, "#icon-upload"
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

      def test_raises_error_for_non_symbol_or_string_icon
        assert_raises(ArgumentError) do
          Component.new(title: "Empty", icon: 123)
        end
      end

      def test_accepts_false_icon_value
        render_inline(Component.new(title: "Empty", icon: false))

        assert_no_selector "svg"
      end

      def test_accepts_custom_classes
        render_inline(Component.new(title: "Empty", class: "custom-class"))

        assert_selector "div.custom-class"
      end
    end
  end
end
