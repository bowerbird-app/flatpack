# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TopNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_basic_top_nav
        render_inline(Component.new)
        assert_selector "header"
      end

      def test_renders_left_slot
        render_inline(Component.new) do |nav|
          nav.left do
            "Left content"
          end
        end
        assert_text "Left content"
      end

      def test_renders_center_slot
        render_inline(Component.new) do |nav|
          nav.center do
            "Center content"
          end
        end
        assert_text "Center content"
      end

      def test_renders_right_slot
        render_inline(Component.new) do |nav|
          nav.right do
            "Right content"
          end
        end
        assert_text "Right content"
      end

      def test_renders_all_slots
        render_inline(Component.new) do |nav|
          nav.left { "Left" }
          nav.center { "Center" }
          nav.right { "Right" }
        end
        assert_text "Left"
        assert_text "Center"
        assert_text "Right"
      end

      def test_has_sticky_positioning
        render_inline(Component.new)
        assert_includes page.native.to_html, "sticky"
        assert_includes page.native.to_html, "top-0"
      end

      def test_has_backdrop_blur
        render_inline(Component.new)
        assert_includes page.native.to_html, "backdrop-blur"
      end

      def test_has_border_bottom
        render_inline(Component.new)
        assert_includes page.native.to_html, "border-b"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-nav"))
        assert_includes page.native.to_html, "custom-nav"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "top-nav"}))
        assert_selector "header[data-testid='top-nav']"
      end
    end
  end
end
