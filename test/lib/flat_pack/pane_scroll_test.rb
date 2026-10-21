# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PaneScrollTest < ActiveSupport::TestCase
    setup do
      @variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "pane bar width and fade size are theme tokens" do
      theme = @variables[/@theme inline \{.*?^\}/m]
      root = @variables[/^:root,\s*\[data-theme\]\s*\{.*?^\}/m]

      assert_match(/--pane-scrollbar-width:\s*var\(--pane-scrollbar-width\);/, theme)
      assert_match(/--pane-scroll-fade-size:\s*var\(--pane-scroll-fade-size\);/, theme)
      assert_match(/--pane-scrollbar-width:\s*none;/, root)
      assert_match(/--pane-scroll-fade-size:\s*2\.5rem;/, root)
    end

    test "pane bars use the token, with a webkit fallback and a scroll-driven fade" do
      assert_includes @css, "scrollbar-width: var(--pane-scrollbar-width);"
      assert_includes @css, "scrollbar-width: auto;"
      assert_includes @css, "@supports not (scrollbar-width: none)"
      assert_includes @css, ".fp-pane-scroll:not([data-pane-scrollbar=\"visible\"])::-webkit-scrollbar"
      assert_includes @css, "outline: 2px solid var(--color-ring);"
      assert_match(
        /@supports \(animation-timeline: scroll\(\)\) \{.*?mask-image:.*?animation-timeline: scroll\(self\), scroll\(self\);.*?var\(--pane-scroll-fade-size\).*?@media \(prefers-reduced-motion: reduce\) \{\s*\.fp-pane-scroll \{\s*animation: none;\s*mask-image: none;/m,
        @css
      )
    end

    test "overflow row keeps its own hidden bar" do
      assert_includes @css, ".fp-scrollbar-hidden"
      row = FlatPack::Engine.root.join("app/components/flat_pack/overflow_row/component.rb").read
      assert_includes row, "fp-scrollbar-hidden"
    end
  end
end
