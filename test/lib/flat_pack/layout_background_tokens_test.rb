# frozen_string_literal: true

require "test_helper"

module FlatPack
  class LayoutBackgroundTokensTest < ActiveSupport::TestCase
    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "edge fill and extra filter are theme tokens with identity defaults" do
      theme_block = @css[/@theme inline \{.*?^\}/m]
      root_block = @css[/^:root,\s*\[data-theme\]\s*\{.*?^\}/m]

      assert_includes theme_block, "--layout-background-color: var(--layout-background-color);"
      assert_includes theme_block, "--layout-background-filter: var(--layout-background-filter);"
      assert_match(/--layout-background-color:\s*transparent;/, root_block)
      assert_match(/--layout-background-filter:\s*saturate\(1\);/, root_block)
      assert_match(/--layout-background-blur:\s*40px;/, root_block)
      assert_match(/--layout-background-tint-color:\s*var\(--surface-page-background-color\);/, root_block)
      assert_match(/--layout-background-tint-opacity:\s*0\.55;/, root_block)

      layer = @application[/\.fp-layout-background \{.*?\n\}/m]
      media = @application[/\.fp-layout-background-media \{.*?\n\}/m]

      assert_includes layer, "background-color: var(--layout-background-color);"
      assert_includes media, "inset: -12%;"
      assert_includes media, "filter: blur(var(--layout-background-blur)) var(--layout-background-filter);"
      assert_includes media, "-webkit-filter: blur(var(--layout-background-blur)) var(--layout-background-filter);"
      refute_includes @css, "--layout-background-overhang"
      refute_includes @application, "--layout-background-overhang"
    end

    test "reduced transparency and missing blur still hide the photo" do
      transparency = <<~CSS
        @media (prefers-reduced-transparency: reduce) {
          .fp-layout-background-media {
            visibility: hidden;
          }

          .fp-layout-background-tint {
            opacity: 1;
          }
        }
      CSS
      unsupported = <<~CSS
        @supports not ((filter: blur(1px)) or (-webkit-filter: blur(1px))) {
          .fp-layout-background-media {
            visibility: hidden;
          }

          .fp-layout-background-tint {
            opacity: 1;
          }
        }
      CSS

      assert_includes @application, transparency.strip
      assert_includes @application, unsupported.strip
      refute_match(/prefers-reduced-motion:[^\n]*\n(?:.*\n){0,8}.*layout-background-filter/, @application)
      refute_match(/forced-colors:[^\n]*\n(?:.*\n){0,8}.*layout-background/, @application)
    end
  end
end
