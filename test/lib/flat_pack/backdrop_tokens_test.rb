# frozen_string_literal: true

require "test_helper"

module FlatPack
  class BackdropTokensTest < ActiveSupport::TestCase
    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "edge fill and extra filter are theme tokens with identity defaults" do
      theme_block = @css[/@theme inline \{.*?^\}/m]
      root_block = @css[/^:root,\s*\[data-theme\]\s*\{.*?^\}/m]

      assert_includes theme_block, "--backdrop-color: var(--backdrop-color);"
      assert_includes theme_block, "--backdrop-filter: var(--backdrop-filter);"
      assert_match(/--backdrop-color:\s*transparent;/, root_block)
      assert_match(/--backdrop-filter:\s*saturate\(1\);/, root_block)
      assert_match(/--backdrop-blur:\s*40px;/, root_block)
      assert_match(/--backdrop-tint-color:\s*var\(--surface-page-background-color\);/, root_block)
      assert_match(/--backdrop-tint-opacity:\s*0\.55;/, root_block)
      refute_includes @css, "--layout-background-"

      layer = @application[/\.fp-backdrop-layers \{.*?\n\}/m]
      media = @application[/\.fp-backdrop-media \{.*?\n\}/m]

      assert_includes layer, "background-color: var(--backdrop-color);"
      assert_includes media, "inset: -12%;"
      assert_includes media, "filter: blur(var(--backdrop-blur)) var(--backdrop-filter);"
      assert_includes media, "-webkit-filter: blur(var(--backdrop-blur)) var(--backdrop-filter);"
      assert_includes @application, "border-radius: inherit;"
      assert_includes @application, "overflow: hidden;"
      refute_includes @application, ".fp-layout-background"
      refute_includes @application, "--layout-background-"
    end

    test "rounded wash is a neutral edge and beats the dark tint when themes combine" do
      rounded = @css[/\[data-theme~="rounded"\]\s*\{(.*?)\}/m, 1]
      dark = @css[/\[data-theme~="dark"\]\s*\{(.*?)\}/m, 1]

      assert_match(/--backdrop-color:\s*#2f2f2f;/, rounded)
      assert_match(/--backdrop-tint-color:\s*#000;/, rounded)
      assert_match(/--backdrop-tint-opacity:\s*0\.18;/, rounded)
      refute_match(/--backdrop-blur\s*:/, rounded)
      refute_match(/--backdrop-filter\s*:/, rounded)
      refute_includes rounded[/--backdrop-color:[^;]+/], "oklch("
      assert_match(/--backdrop-tint-opacity:\s*0\.78;/, dark)
      refute_match(/--backdrop-tint-color\s*:/, dark)

      dark_rule = @css.index("[data-theme~=\"dark\"] {")
      rounded_rule = @css.index("[data-theme~=\"rounded\"] {")
      dark_opacity = @css.index("--backdrop-tint-opacity: 0.78")
      rounded_opacity = @css.index("--backdrop-tint-opacity: 0.18")

      assert_operator dark_rule, :<, rounded_rule
      assert_operator dark_opacity, :<, rounded_opacity
    end

    test "reduced transparency and missing blur still hide the photo" do
      transparency = <<~CSS
        @media (prefers-reduced-transparency: reduce) {
          .fp-backdrop-media {
            visibility: hidden;
          }

          .fp-backdrop-tint {
            opacity: 1;
          }
        }
      CSS
      unsupported = <<~CSS
        @supports not ((filter: blur(1px)) or (-webkit-filter: blur(1px))) {
          .fp-backdrop-media {
            visibility: hidden;
          }

          .fp-backdrop-tint {
            opacity: 1;
          }
        }
      CSS

      assert_includes @application, transparency.strip
      assert_includes @application, unsupported.strip
      refute_match(/prefers-reduced-motion:[^\n]*\n(?:.*\n){0,8}.*backdrop-filter/, @application)
      refute_match(/forced-colors:[^\n]*\n(?:.*\n){0,8}.*backdrop-/, @application)
    end
  end
end
