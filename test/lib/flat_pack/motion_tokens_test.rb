# frozen_string_literal: true

require "test_helper"

module FlatPack
  class MotionTokensTest < ActiveSupport::TestCase
    test "motion tokens are registered for Tailwind and set on :root" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      theme = css[/@theme inline \{.*?^\}/m]
      root = css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      names = %w[
        --motion-duration-fast --motion-duration-base --motion-duration-slow --motion-duration-slower
        --motion-delay-sm --motion-delay-md --motion-delay-lg
        --motion-stagger-sm --motion-stagger-md --motion-stagger-lg
        --motion-ease-out --motion-ease-in-out --motion-ease-spring
        --motion-distance-sm --motion-distance-md --motion-distance-lg
        --motion-scale --motion-scale-strong --motion-zoom --motion-zoom-strong
        --reveal-stagger
      ]

      names.each do |name|
        assert_includes theme, "#{name}: var(#{name});", "#{name} missing from @theme inline"
        assert_includes root, "#{name}:", "#{name} missing from :root"
      end

      assert_match(/--motion-duration-fast:\s*var\(--duration-fast\)/, root)
      assert_match(/--motion-duration-base:\s*var\(--duration-base\)/, root)
      assert_match(/--motion-duration-slow:\s*var\(--duration-slow\)/, root)
      assert_match(/--motion-duration-slower:\s*600ms/, root)
      assert_match(/--motion-delay-sm:\s*120ms/, root)
      assert_match(/--motion-delay-md:\s*250ms/, root)
      assert_match(/--motion-delay-lg:\s*450ms/, root)
      assert_match(/--motion-stagger-sm:\s*40ms/, root)
      assert_match(/--motion-stagger-md:\s*80ms/, root)
      assert_match(/--motion-stagger-lg:\s*120ms/, root)
      assert_match(/--motion-ease-out:\s*var\(--easing-enter\)/, root)
      assert_match(/--motion-ease-in-out:\s*cubic-bezier\(0\.4, 0, 0\.2, 1\)/, root)
      assert_match(/--motion-ease-spring:\s*var\(--easing-spring\)/, root)
      assert_match(/--motion-distance-sm:\s*4px/, root)
      assert_match(/--motion-distance-md:\s*1rem/, root)
      assert_match(/--motion-distance-lg:\s*3rem/, root)
      assert_match(/--motion-scale:\s*0\.95/, root)
      assert_match(/--motion-scale-strong:\s*0\.85/, root)
      assert_match(/--motion-zoom:\s*1\.05/, root)
      assert_match(/--motion-zoom-strong:\s*1\.2/, root)
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

    test "every reveal is hidden until is-revealed" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_match(/\.fp-reveal--fade\s*\{[^}]*opacity:\s*0/, css)

      {
        ".fp-reveal--fade:not(.is-revealed)" => "opacity: 0",
        ".fp-reveal--rise:not(.is-revealed)" => "opacity: 0",
        ".fp-reveal--blur:not(.is-revealed)" => "opacity: 0",
        ".fp-reveal--scale:not(.is-revealed)" => "opacity: 0",
        ".fp-reveal--zoom:not(.is-revealed)" => "opacity: 0",
        ".fp-reveal--wipe:not(.is-revealed)" => "clip-path: inset(0 100% 0 0)",
        ".fp-reveal--words:not(.is-revealed) .fp-reveal__chunk" => "translateY(100%)",
        ".fp-reveal--lines:not(.is-revealed) .fp-reveal__chunk" => "translateY(100%)"
      }.each do |selector, hidden|
        block = declaration_block(css, selector)
        refute_nil block, "missing hidden rule #{selector}"
        assert_includes block, hidden
      end

      rise = css[/\.fp-reveal--rise:not\(\.is-revealed\)\s*\{([^}]+)\}/, 1]
      assert_includes rise, "var(--motion-distance-md)"
      strong_rise = css[/\.fp-reveal--strong\.fp-reveal--rise:not\(\.is-revealed\)\s*\{([^}]+)\}/, 1]
      assert_includes strong_rise, "var(--motion-distance-lg)"
      assert_includes css, "scale(var(--motion-scale))"
      assert_includes css, "scale(var(--motion-scale-strong))"
      assert_includes css, "scale(var(--motion-zoom))"
      assert_includes css, "scale(var(--motion-zoom-strong))"
      refute_includes css, "scale(0.96)"
      refute_includes css, "scale(1.05)"
      assert_includes css, "@media (scripting: none)"
      assert_includes css, "var(--reveal-duration, var(--motion-duration-slow))"
      assert_includes css, "var(--reveal-delay, 0ms)"
      assert_includes css, "calc(var(--reveal-delay, 0ms) + min(var(--reveal-index, 0), 12) * var(--reveal-stagger))"
      assert_includes css, "animation-timeline: view();"
      assert_match(/prefers-reduced-motion: reduce.*?\.fp-reveal--parallax/m, css)
    end

    private

    def declaration_block(css, selector)
      index = 0
      while (found = css.index(selector, index))
        brace = css.index("{", found)
        return nil unless brace

        between = css[found + selector.length, brace - (found + selector.length)]
        if !between.include?("{") && !between.include?("}")
          close = css.index("}", brace)
          return css[brace + 1, close - brace - 1]
        end

        index = found + selector.length
      end

      nil
    end
  end
end
