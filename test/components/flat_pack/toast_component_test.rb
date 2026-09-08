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
        assert_includes html, "fp-hit-target"
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
    end
  end
end
