# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Skeleton
    class ComponentTest < ViewComponent::TestCase
      def test_renders_skeleton
        render_inline(Component.new)

        assert_selector "[role='status']"
        assert_selector "[aria-busy='true']"
      end

      def test_renders_text_variant
        render_inline(Component.new(variant: :text))

        assert_includes page.native.to_html, "h-4"
        assert_includes page.native.to_html, "w-full"
      end

      def test_renders_title_variant
        render_inline(Component.new(variant: :title))

        assert_includes page.native.to_html, "h-8"
        assert_includes page.native.to_html, "w-3/4"
      end

      def test_renders_avatar_variant
        render_inline(Component.new(variant: :avatar))

        assert_includes page.native.to_html, "h-12"
        assert_includes page.native.to_html, "w-12"
        assert_includes page.native.to_html, "rounded-full"
      end

      def test_renders_button_variant
        render_inline(Component.new(variant: :button))

        assert_includes page.native.to_html, "h-10"
        assert_includes page.native.to_html, "w-24"
      end

      def test_renders_rectangle_variant
        render_inline(Component.new(variant: :rectangle))

        assert_includes page.native.to_html, "h-32"
        assert_includes page.native.to_html, "w-full"
      end

      def test_renders_with_custom_width
        render_inline(Component.new(width: "200px"))

        assert_includes page.native.to_html, "w-[200px]"
      end

      def test_renders_with_custom_height
        render_inline(Component.new(height: "50px"))

        assert_includes page.native.to_html, "h-[50px]"
      end

      def test_includes_animate_pulse
        render_inline(Component.new)

        assert_includes page.native.to_html, "animate-pulse"
      end

      def test_includes_background_color
        render_inline(Component.new)

        assert_includes page.native.to_html, "bg-[var(--surface-muted-bg-color)]"
      end

      def test_raises_error_for_invalid_variant
        assert_raises(ArgumentError) do
          Component.new(variant: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))

        assert_selector ".custom-class"
      end

      def test_includes_aria_label
        render_inline(Component.new)

        assert_selector "[aria-label='Loading...']"
      end
    end
  end
end
