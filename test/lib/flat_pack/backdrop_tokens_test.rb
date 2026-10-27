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

    test "content tokens alias surface text and rounded uses the hero overlay text" do
      theme_block = @css[/@theme inline \{.*?^\}/m]
      root_block = @css[/^:root,\s*\[data-theme\]\s*\{.*?^\}/m]
      rounded = @css[/\[data-theme~="rounded"\]\s*\{(.*?)\}/m, 1]
      dark = @css[/\[data-theme~="dark"\]\s*\{(.*?)\}/m, 1]

      assert_includes theme_block, "--backdrop-content-color: var(--backdrop-content-color);"
      assert_includes theme_block, "--backdrop-muted-content-color: var(--backdrop-muted-content-color);"
      assert_match(/--backdrop-content-color:\s*var\(--surface-content-color\);/, root_block)
      assert_match(/--backdrop-muted-content-color:\s*var\(--surface-muted-content-color\);/, root_block)
      assert_match(/--backdrop-content-color:\s*var\(--hero-overlay-text-color\);/, rounded)
      assert_match(/--backdrop-muted-content-color:\s*var\(--hero-overlay-muted-text-color\);/, rounded)
      refute_match(/--backdrop-content-color:\s*var\(--backdrop-content-color\)/, rounded)
      refute_match(/--backdrop-muted-content-color:\s*var\(--backdrop-muted-content-color\)/, rounded)
      refute_match(/--backdrop-content-color\s*:/, dark)
      refute_match(/--backdrop-muted-content-color\s*:/, dark)
    end

    test "on-backdrop text is gated on a layout photo and leaves the card surface alone" do
      main = @application[/\[data-flat-pack-layout-background\] \.fp-layout-main \{.*?\n\}/m]
      on_backdrop = @application[/\[data-flat-pack-layout-background\] \.fp-on-backdrop \{.*?\n\}/m]
      muted = @application[/\[data-flat-pack-layout-background\] \.fp-on-backdrop-muted \{.*?\n\}/m]
      card = @application[/\[data-flat-pack-layout-background\] \.fp-on-backdrop \.fp-card \{.*?\n\}/m]

      assert_match(/\A\[data-flat-pack-layout-background\]/, main)
      assert_match(/\A\[data-flat-pack-layout-background\]/, on_backdrop)
      assert_match(/\A\[data-flat-pack-layout-background\]/, muted)
      assert_match(/\A\[data-flat-pack-layout-background\]/, card)
      refute_includes main, "--surface-content-color"
      refute_match(/--surface-content-color\s*:/, card)

      assert_includes on_backdrop, "color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--surface-content-color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--surface-muted-content-color: var(--backdrop-muted-content-color);"
      assert_includes on_backdrop, "--breadcrumb-current-color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--breadcrumb-link-color: var(--backdrop-muted-content-color);"
      assert_includes on_backdrop, "--breadcrumb-link-hover-color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--breadcrumb-separator-color: var(--backdrop-muted-content-color);"
      assert_includes on_backdrop, "--top-nav-item-text-color: var(--backdrop-muted-content-color);"
      assert_includes on_backdrop, "--top-nav-item-icon-color: var(--backdrop-muted-content-color);"
      assert_includes on_backdrop, "--top-nav-item-hover-text-color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--color-ghost-text: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--button-ghost-text-color: var(--backdrop-content-color);"
      assert_includes on_backdrop, "--button-ghost-hover-background-color: color-mix(in oklab, var(--backdrop-content-color) 16%, transparent);"
      refute_match(/--color-ghost-hover\s*:/, on_backdrop)

      assert_includes muted, "color: var(--backdrop-muted-content-color);"
    end
  end
end
