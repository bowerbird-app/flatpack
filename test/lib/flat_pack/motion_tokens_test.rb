# frozen_string_literal: true

require "test_helper"

module FlatPack
  class MotionTokensTest < ActiveSupport::TestCase
    test "motion tokens are registered for Tailwind and set on :root" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      theme = css[/@theme inline \{.*?^\}/m]
      root = css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      names = %w[
        --motion-duration-fast --motion-duration-base --motion-duration-slow
        --motion-ease-out --motion-ease-in-out --motion-ease-spring
        --motion-distance-sm --motion-distance-md --motion-distance-lg
        --reveal-stagger
      ]

      names.each do |name|
        assert_includes theme, "#{name}: var(#{name});", "#{name} missing from @theme inline"
        assert_includes root, "#{name}:", "#{name} missing from :root"
      end

      assert_match(/--motion-duration-fast:\s*var\(--duration-fast\)/, root)
      assert_match(/--motion-duration-base:\s*var\(--duration-base\)/, root)
      assert_match(/--motion-duration-slow:\s*var\(--duration-slow\)/, root)
      assert_match(/--motion-ease-out:\s*var\(--easing-enter\)/, root)
      assert_match(/--motion-ease-in-out:\s*cubic-bezier\(0\.4, 0, 0\.2, 1\)/, root)
      assert_match(/--motion-ease-spring:\s*var\(--easing-spring\)/, root)
      assert_match(/--motion-distance-sm:\s*4px/, root)
      assert_match(/--motion-distance-md:\s*1rem/, root)
      assert_match(/--motion-distance-lg:\s*2rem/, root)
      assert_match(/--reveal-stagger:\s*40ms/, root)
    end

    test "content enter and collage motion inherit the shared tokens" do
      variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root = variables[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      assert_match(/--collage-duration:\s*var\(--motion-duration-slow\)/, root)
      assert_match(/--collage-easing:\s*var\(--motion-ease-out\)/, root)
      assert_match(/--collage-rise:\s*var\(--motion-distance-sm\)/, root)
      assert_match(/--collage-stagger:\s*var\(--reveal-stagger\)/, root)

      enter = css[/\.fp-content-enter \{.*?\n  \}/m]
      assert_includes enter, "var(--motion-duration-slow)"
      assert_includes enter, "var(--motion-ease-out)"
      assert_includes enter, "var(--motion-distance-sm)"
    end

    test "reveal css rests on the final state and only hides with is-pending" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_match(/\.fp-reveal--fade\s*\{[^}]*opacity:\s*0/, css)
      assert_includes css, "transform: scale(1.05);"
      assert_includes css, "transform: scale(0.96);"
      assert_includes css, "animation-timeline: view();"
      assert_includes css, "@supports (animation-timeline: view())"
      assert_includes css, "prefers-reduced-motion: no-preference"
      assert_includes css, ".fp-reveal--wipe.is-pending"
      assert_includes css, ".fp-text-stream__source"
      assert_match(/prefers-reduced-motion: reduce.*?\.fp-reveal--parallax/m, css)
    end
  end
end
