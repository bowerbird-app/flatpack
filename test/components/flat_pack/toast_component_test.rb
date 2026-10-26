# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toast
    class ComponentTest < ViewComponent::TestCase
      def test_dismiss_button_is_a_centered_ghost_control
        render_inline(Component.new(text: "Saved", style: :success))

        button = page.find("button[aria-label='Dismiss']")
        assert_equal "button", button["type"]
        assert_equal "ghost", button["data-fp-style"]
        assert_equal "flat-pack--toast#dismiss", button["data-action"]
        assert_includes button["class"], "fp-button"
        assert_includes button["class"], "fp-hit-slop"
        refute_includes button["class"], "fp-hit-target"
        assert_selector ".fp-toast__dismiss"
        refute_includes page.native.to_html, "bg-[var(--toast-danger-dismiss-background-color)]"
        assert_includes css_host("fp-toast__dismiss"), "--button-ghost-text-color: var(--toast-dismiss-text-color)"
        assert_includes css_host("fp-toast__dismiss"), "--button-ghost-hover-background-color: var(--toast-dismiss-hover-background-color)"
      end

      def test_danger_dismiss_matches_other_styles
        render_inline(Component.new(text: "Failed", style: :danger))

        button = page.find("button[aria-label='Dismiss']")
        assert_equal "ghost", button["data-fp-style"]
        refute_includes page.native.to_html, "bg-[var(--toast-danger-dismiss-background-color)]"
        refute_includes page.native.to_html, "text-[var(--toast-danger-dismiss-text-color)]"
      end

      def test_default_size_is_medium
        render_inline(Component.new(text: "Saved"))

        html = page.native.to_html
        assert_includes html, "p-[var(--toast-padding-md)]"
        refute_includes html, "--toast-padding:"
        assert_includes html, "text-sm"
        assert_includes html, "gap-3"
      end

      def test_renders_small_size
        render_inline(Component.new(text: "Saved", size: :sm))

        html = page.native.to_html
        assert_includes html, "p-[var(--toast-padding-sm)]"
        assert_includes html, "text-xs"
      end

      def test_renders_large_size
        render_inline(Component.new(text: "Saved", size: :lg))

        html = page.native.to_html
        assert_includes html, "p-[var(--toast-padding-lg)]"
        assert_includes html, "text-base"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(text: "Saved", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      private

      def css_host(name)
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        css[/#{Regexp.escape(".#{name}")} \{.*?\}/m].to_s
      end
    end
  end
end
