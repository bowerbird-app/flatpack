# frozen_string_literal: true

require "test_helper"

module FlatPack
  class CardStyleTokensTest < ActiveSupport::TestCase
    STYLES = %w[default shaded brand brand-subtle gradient].freeze
    PARTS = %w[background text-color muted-text-color border-color].freeze

    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "each style publishes background, text, muted text, and border" do
      theme_block = @css[/@theme inline \{.*?^\}/m]
      root_block = @css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      STYLES.product(PARTS).each do |style, part|
        token = "--card-style-#{style}-#{part}"
        assert_includes theme_block, "#{token}: var(#{token});", token
        assert_includes root_block, "#{token}:", token
      end
    end

    test "style fills follow theme tokens and gradient uses background" do
      root_block = @css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      assert_match(/--card-style-default-background:\s*var\(--card-background-color\)/, root_block)
      assert_match(/--card-style-shaded-background:\s*var\(--card-background-muted-color\)/, root_block)
      assert_match(/--card-style-brand-background:\s*var\(--color-primary\)/, root_block)
      assert_match(/--card-style-brand-text-color:\s*var\(--color-primary-text\)/, root_block)
      assert_match(/--card-style-brand-subtle-text-color:\s*var\(--surface-content-color\)/, root_block)
      assert_match(/--card-style-gradient-background:\s*linear-gradient\(/, root_block)
      refute_match(/--card-style-brand-background:\s*#/, root_block)
      refute_includes root_block, "--card-tone-"
    end

    test "dark mode keeps gradient text on the light side of the brand colour" do
      dark_block = @css[/\[data-theme~="dark"\]\s*\{(.*?)\}/m, 1]

      assert_match(/--card-style-gradient-background:\s*linear-gradient\(/, dark_block)
      refute_includes dark_block, "--card-style-brand-background:"
      refute_includes dark_block, "--card-style-default-background:"
      refute_includes dark_block, "--button-primary-background-color"
    end

    test "card hover paints outside the component layer" do
      layered, unlayered = @application.split("/* Unlayered so a style fill", 2)

      refute_includes layered, ".fp-card-hover-subtle:hover"
      refute_includes layered, ".fp-card-hover-strong:hover"
      assert_includes unlayered, ".fp-card-hover-subtle:hover"
      assert_includes unlayered, "box-shadow: var(--card-hover-strong-shadow);"
      assert_includes unlayered, "--card-hover-strong-shadow-dark"
    end

    test "cards do not rebind button or badge colours" do
      refute_includes @application, ".fp-card[data-tone="
      refute_includes @application, "--button-primary-text-color: var(--color-primary);"
      refute_match(/\.fp-card\[data-style="brand"\][^{]*\{[^}]*--(?:button|badge)-/, @application)
      assert_includes @application, '.fp-card[data-style="brand"] { --flat-pack-surface-fill: var(--card-style-brand-background); }'
    end
  end
end
