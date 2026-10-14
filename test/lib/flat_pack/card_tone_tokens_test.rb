# frozen_string_literal: true

require "test_helper"

module FlatPack
  class CardToneTokensTest < ActiveSupport::TestCase
    TONES = %w[default shaded brand brand-subtle gradient].freeze
    PARTS = %w[background text-color muted-text-color border-color].freeze

    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      @application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "each tone publishes background, text, muted text, and border" do
      theme_block = @css[/@theme inline \{.*?^\}/m]
      root_block = @css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      TONES.product(PARTS).each do |tone, part|
        token = "--card-tone-#{tone}-#{part}"
        assert_includes theme_block, "#{token}: var(#{token});", token
        assert_includes root_block, "#{token}:", token
      end
    end

    test "tone fills follow theme tokens and gradient uses background" do
      root_block = @css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      assert_match(/--card-tone-default-background:\s*var\(--card-background-color\)/, root_block)
      assert_match(/--card-tone-shaded-background:\s*var\(--card-background-muted-color\)/, root_block)
      assert_match(/--card-tone-brand-background:\s*var\(--color-primary\)/, root_block)
      assert_match(/--card-tone-brand-text-color:\s*var\(--color-primary-text\)/, root_block)
      assert_match(/--card-tone-brand-subtle-text-color:\s*var\(--surface-content-color\)/, root_block)
      assert_match(/--card-tone-gradient-background:\s*linear-gradient\(/, root_block)
      refute_match(/--card-tone-brand-background:\s*#/, root_block)
    end

    test "dark mode keeps gradient text on the light side of the brand colour" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]

      assert_match(/--card-tone-gradient-background:\s*linear-gradient\(/, dark_block)
      refute_includes dark_block, "--card-tone-brand-background:"
      refute_includes dark_block, "--card-tone-default-background:"
      refute_includes dark_block, "--button-primary-background-color"
    end

    test "brand and gradient cards rebind button and badge colours to the tone text" do
      assert_includes @application, '.fp-card[data-tone="brand"]'
      assert_includes @application, '.fp-card[data-tone="gradient"]'
      assert_includes @application, "--button-primary-background-color: var(--surface-content-color);"
      assert_includes @application, "--button-primary-text-color: var(--color-primary);"
      assert_includes @application, "--button-ghost-text-color: var(--surface-content-color);"
      assert_includes @application, "--badge-primary-background-color: var(--surface-content-color);"
      assert_includes @application, "--badge-default-text-color: var(--surface-content-color);"
    end
  end
end
