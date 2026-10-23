# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageLayoutTokensTest < ActiveSupport::TestCase
    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      @root = @css[/^:root,\s*\[data-theme\]\s*\{.*?^\}/m]
      @theme = @css[/@theme inline \{.*?^\}/m]
      @rounded = @css[/\[data-theme~="rounded"\]\s*\{(.*?)\}/m, 1]
    end

    test "widths and spacing come from tokens" do
      assert_match(/--page-layout-width-narrow:\s*40rem;/, @root)
      assert_match(/--page-layout-width-default:\s*56rem;/, @root)
      assert_match(/--page-layout-width-wide:\s*72rem;/, @root)
      assert_match(/--page-layout-width-full:\s*100%;/, @root)
      assert_match(/--page-layout-padding-inline:\s*var\(--space-4\);/, @root)
      assert_match(/--page-layout-padding-block:\s*var\(--space-6\);/, @root)
      assert_match(/--page-layout-gap:\s*var\(--space-6\);/, @root)
      assert_match(
        /@media \(min-width: 640px\) \{\s*:root,\s*\[data-theme\] \{\s*--layout-content-inset:\s*2rem;\s*--page-layout-padding-inline:\s*var\(--space-6\);/,
        @css
      )

      assert_includes @theme, "--page-layout-width-narrow: var(--page-layout-width-narrow);"
      assert_includes @theme, "--page-layout-padding-inline: var(--page-layout-padding-inline);"
      assert_includes @application, "--layout-content-max-width: var(--page-layout-width);"
      assert_includes @application, "--layout-content-inset: var(--page-layout-padding-inline);"
      assert_includes @application, '.fp-page-layout[data-fp-page-layout-width="narrow"]'
      assert_includes @application, '.fp-page-layout[data-fp-page-layout-align="center"]'

      center = @application[/\.fp-page-layout\[data-fp-page-layout-align="center"\] \.fp-page-layout-main \{.*?\}/m]
      assert_includes center, "display: grid;"
      assert_includes center, "align-content: center;"
      refute_includes @application, "justify-content: center"

      column = @application[/\.fp-page-layout-top-nav-column \{.*?\}/m]
      refute_nil column
      assert_includes column, "box-sizing: border-box;"
      assert_includes column, "width: 100%;"
      assert_includes column, "min-width: 0;"
      assert_includes column, "max-width: calc(var(--layout-content-max-width) + (2 * var(--layout-content-inset)));"
      assert_includes column, "margin-inline: auto;"
      assert_includes column, "padding-left: max(var(--layout-content-inset), env(safe-area-inset-left, 0px));"
      assert_includes column, "padding-right: max(var(--layout-content-inset), env(safe-area-inset-right, 0px));"
      refute_includes column, "fp-top-nav"
      refute_includes column, "--top-nav-"
      assert_operator @application.index(".fp-page-layout-top-nav-column {"), :>, @application.index(".fp-top-nav {")
    end

    test "rounded padding follows the spacing scale and sets no photo colour" do
      refute_match(/--page-layout-/, @rounded)
      refute_match(/--page-layout-[^;]*(?:#|oklch|rgb)/, @root)
      refute_includes @root, "--page-layout-width:"
    end
  end
end
