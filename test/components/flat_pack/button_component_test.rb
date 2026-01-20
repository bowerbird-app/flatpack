# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_with_primary_scheme
        render_inline(Component.new(label: "Click me", scheme: :primary))
        
        assert_selector "button", text: "Click me"
        assert_selector "button[type='button']"
      end

      def test_renders_button_with_secondary_scheme
        render_inline(Component.new(label: "Secondary", scheme: :secondary))
        
        assert_selector "button", text: "Secondary"
      end

      def test_renders_button_with_ghost_scheme
        render_inline(Component.new(label: "Ghost", scheme: :ghost))
        
        assert_selector "button", text: "Ghost"
      end

      def test_renders_link_when_url_provided
        render_inline(Component.new(label: "Link", url: "/path"))
        
        assert_selector "a[href='/path']", text: "Link"
      end

      def test_renders_link_with_method
        render_inline(Component.new(label: "Delete", url: "/path", method: :delete))
        
        assert_selector "a[href='/path']", text: "Delete"
      end

      def test_raises_error_for_invalid_scheme
        assert_raises(ArgumentError) do
          Component.new(label: "Invalid", scheme: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(label: "Custom", class: "custom-class"))
        
        assert_selector "button.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(label: "Data", data: {action: "click"}))
        
        assert_selector "button[data-action='click']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(label: "Aria", aria: {label: "Custom label"}))
        
        assert_selector "button[aria-label='Custom label']"
      end

      def test_default_scheme_is_primary
        component = Component.new(label: "Default")
        render_inline(component)
        
        assert_selector "button", text: "Default"
      end
    end
  end
end
