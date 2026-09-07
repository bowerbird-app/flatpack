# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TokenSourceTest < ActiveSupport::TestCase
    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
    end

    test "theme inventory is @theme inline pointing at :root names" do
      theme_block = @css[/@theme inline \{.*?^\}/m]

      refute_nil theme_block, "expected an @theme inline block in variables.css"
      refute_match(/^@theme \{/, @css)
      refute_includes theme_block, "oklch("
      refute_includes theme_block, "#fff"
      theme_block.scan(/^\s*(--[a-z0-9-]+)\s*:\s*(.+);$/).each do |name, value|
        assert_equal "var(#{name})", value, "#{name} in @theme inline must point at itself so Tailwind does not emit a second value"
      end
    end

    test ":root holds concrete values and does not circular-map tokens" do
      root_block = @css[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected a :root block in variables.css"
      assert_match(/--color-primary:\s*oklch\(/, root_block)
      assert_match(/--font-sans:\s*system-ui/, root_block)
      assert_match(/--duration-fast:\s*150ms/, root_block)
      assert_match(/--easing-standard:\s*cubic-bezier/, root_block)
      assert_match(/--button-padding-x-xs:\s*0\.5rem/, root_block)
      assert_match(/--carousel-caption-below-text-color:\s*var\(--surface-muted-content-color\)/, root_block)
      assert_match(/--icon-stroke-width:\s*1\.5/, root_block)

      root_block.scan(/^\s*(--[a-z0-9-]+)\s*:\s*(.+);$/).each do |name, value|
        refute_equal "var(#{name})", value, "#{name} on :root must not be a circular self-reference"
      end
    end

    test "@theme inline names match :root custom properties" do
      theme_names = token_names(@css[/@theme inline \{.*?^\}/m])
      root_names = token_names(@css[/^:root \{.*?^\}/m])

      assert_equal root_names, theme_names
    end

    test "rounded is a no-op alias and does not restate the default palette" do
      rounded_block = @css[/\[data-theme="rounded"\]\s*\{(.*?)\}/m, 1]

      refute_nil rounded_block
      refute_includes rounded_block, "--color-primary"
      refute_includes rounded_block, "--radius-md"
      refute_includes rounded_block, "--shadow-sm"
    end

    test "dark and ocean stay override-only" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      ocean_block = @css[/\[data-theme="ocean"\]\s*\{(.*?)\}/m, 1]

      refute_includes dark_block, "--button-primary-background-color"
      refute_includes ocean_block, "--button-primary-background-color"
      assert_includes dark_block, "--color-primary"
      assert_includes ocean_block, "--color-primary"
    end

    test "chrome greys alias surface tokens so named themes inherit" do
      root_block = @css[/^:root \{.*?^\}/m]

      {
        "--tabs-pill-inactive-text-color" => "var(--surface-muted-content-color)",
        "--tabs-pill-inactive-hover-background-color" => "var(--surface-muted-background-color)",
        "--tabs-pill-inactive-hover-text-color" => "var(--surface-content-color)",
        "--sidebar-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--top-nav-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--list-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--list-item-active-background-color" => "var(--surface-muted-background-color)",
        "--chat-message-incoming-background-color" => "var(--surface-muted-background-color)",
        "--chat-message-incoming-text-color" => "var(--surface-content-color)",
        "--chat-message-incoming-meta-color" => "var(--surface-muted-content-color)",
        "--avatar-background-color" => "var(--surface-muted-background-color)",
        "--avatar-text-color" => "var(--surface-content-color)"
      }.each do |token, value|
        assert_match(/#{Regexp.escape(token)}:\s*#{Regexp.escape(value)}/, root_block)
      end

      %w[#4b5563 #dfe5ec #f7f7f7 #e5e7eb #ececec #e6e6e6 #1f2937].each do |hex|
        refute_includes root_block, hex
      end

      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      refute_includes dark_block, "--tabs-pill-inactive-text-color"
      refute_includes dark_block, "--sidebar-item-hover-background-color"
      refute_includes dark_block, "--chat-message-incoming-background-color"
      refute_includes dark_block, "--avatar-background-color"
    end

    private

    def token_names(block)
      block.to_s.scan(/^\s*(--[a-z0-9-]+)\s*:/).flatten.sort
    end
  end
end
