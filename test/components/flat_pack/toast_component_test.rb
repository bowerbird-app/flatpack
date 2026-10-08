# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toast
    class ComponentTest < ViewComponent::TestCase
      def test_dismiss_button_is_a_centered_ghost_control
        render_inline(Component.new(text: "Saved", style: :success))

        html = page.native.to_html

        assert_includes html, "inline-flex"
        assert_includes html, "items-center"
        assert_includes html, "justify-center"
        assert_includes html, "fp-hit-slop"
        assert_includes html, "pointer-events-auto"
        refute_includes html, "fp-hit-target"
        assert_includes html, "text-[var(--toast-dismiss-text-color)]"
        assert_includes html, "hover:bg-[var(--toast-dismiss-hover-background-color)]"
        refute_includes html, "bg-[var(--toast-danger-dismiss-background-color)]"
      end

      def test_danger_dismiss_matches_other_styles
        render_inline(Component.new(text: "Failed", style: :danger))

        html = page.native.to_html

        assert_includes html, "text-[var(--toast-dismiss-text-color)]"
        refute_includes html, "bg-[var(--toast-danger-dismiss-background-color)]"
        refute_includes html, "text-[var(--toast-danger-dismiss-text-color)]"
      end

      def test_default_size_is_medium
        render_inline(Component.new(text: "Saved"))

        html = page.native.to_html
        assert_includes html, "--toast-padding: 1rem"
        assert_includes html, "text-sm"
        assert_includes html, "gap-3"
      end

      def test_renders_small_size
        render_inline(Component.new(text: "Saved", size: :sm))

        html = page.native.to_html
        assert_includes html, "--toast-padding: 0.75rem"
        assert_includes html, "text-xs"
      end

      def test_renders_large_size
        render_inline(Component.new(text: "Saved", size: :lg))

        html = page.native.to_html
        assert_includes html, "--toast-padding: 1.25rem"
        assert_includes html, "text-base"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(text: "Saved", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end
    end
  end
end
