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
      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"
      assert_match(/--color-primary:\s*oklch\(/, root_block)
      assert_match(/--font-sans:\s*system-ui/, root_block)
      assert_match(/--duration-fast:\s*150ms/, root_block)
      assert_match(/--easing-standard:\s*cubic-bezier/, root_block)
      assert_match(/--button-padding-x-xs:\s*0\.5rem/, root_block)
      assert_match(/--carousel-caption-below-text-color:\s*var\(--surface-muted-content-color\)/, root_block)
      assert_match(/--hero-overlay-background-color:\s*rgb\(0 0 0 \/ 0\.6\)/, root_block)
      assert_match(/--hero-overlay-left-background:\s*linear-gradient/, root_block)
      assert_match(/--hero-overlay-button-primary-background-color:\s*oklch\(1 0 0\)/, root_block)
      assert_match(/--hero-overlay-on-light-background-color:\s*rgb\(255 255 255 \/ 0\.62\)/, root_block)
      assert_match(/--hero-overlay-on-light-text-color:\s*oklch\(0\.22 0 0\)/, root_block)
      assert_match(/--hero-overlay-min-height:\s*560px/, root_block)
      assert_match(/--hero-overlay-copy-padding-top:\s*calc\(var\(--top-nav-height\)/, root_block)
      assert_match(/--top-nav-height:\s*72px/, root_block)
      assert_match(/--top-nav-backdrop-blur:\s*16px/, root_block)
      assert_match(/--carousel-media-background-color:\s*oklch\(0 0 0\)/, root_block)
      assert_match(/--carousel-lightbox-image-background-color:\s*rgb\(0 0 0 \/ 0\.2\)/, root_block)
      assert_match(/--badge-remove-hover-background-color:\s*var\(--chip-remove-hover-background-color\)/, root_block)
      assert_match(/--picker-badge-background-color:\s*rgb\(0 0 0 \/ 0\.55\)/, root_block)
      assert_match(/--icon-stroke-width:\s*1\.5/, root_block)
      assert_match(/--surface-border-color:\s*#d1d5db/, root_block)
      assert_match(/--sidebar-border-color:\s*var\(--surface-border-color\)/, root_block)
      assert_match(/--sidebar-background-color:\s*var\(--surface-page-background-color\)/, root_block)
      refute_match(/--sidebar-background-color:\s*oklch\(1\.0 0 0\)/, root_block)
      assert_match(/--fp-button-background:\s*var\(--button-default-background-color\)/, root_block)

      root_block.scan(/^\s*(--[a-z0-9-]+)\s*:\s*(.+);$/).each do |name, value|
        refute_equal "var(#{name})", value, "#{name} on :root must not be a circular self-reference"
      end
    end

    test ":root --color-primary follows brand primitives" do
      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"
      assert_match(
        /--color-primary:\s*oklch\(var\(--brand-lightness\)\s+var\(--brand-chroma\)\s+var\(--brand-hue\)\);/,
        root_block
      )
      assert_match(
        /--color-primary-hover:\s*oklch\(calc\(var\(--brand-lightness\) - 0\.10\)\s+var\(--brand-chroma\)\s+var\(--brand-hue\)\);/,
        root_block
      )
      refute_match(/--color-primary:\s*oklch\(0\.3211 0 0\);/, root_block)
      refute_includes root_block, "calc(var(--brand-chroma) - 0.02)"
    end

    test "primary hover derives from --color-primary with a brand-knob fallback" do
      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"
      assert_match(
        /--color-primary-hover:\s*oklch\(calc\(var\(--brand-lightness\) - 0\.10\)\s+var\(--brand-chroma\)\s+var\(--brand-hue\)\);/,
        root_block
      )
      refute_match(
        /--color-primary-hover:\s*oklch\(from var\(--color-primary\)/,
        root_block
      )

      supports_block = @css[/@supports \(color: oklch\(from red calc\(l - 0\.1\) c h\)\)\s*\{.*?^\}/m]
      refute_nil supports_block, "expected an @supports relative-color block for --color-primary-hover"
      assert_match(
        /--color-primary-hover:\s*oklch\(from var\(--color-primary\) calc\(l - 0\.1\) c h\);/,
        supports_block
      )
      refute_includes supports_block, "color-mix("
    end

    test "dummy sunrise theme sets brand lightness so primary recolors" do
      css = Rails.root.join("app/assets/stylesheets/application.tailwind.css").read
      sunrise = css[/\[data-theme="sunrise"\]\s*\{[^}]*--brand-hue:[^}]*\}/m]

      refute_nil sunrise, "expected a [data-theme=\"sunrise\"] block"
      assert_includes sunrise, "--brand-hue: 35"
      assert_includes sunrise, "--brand-chroma: 0.19"
      assert_includes sunrise, "--brand-lightness: 0.52"
    end

    test "dummy featured-in themes set only semantic tokens" do
      css = Rails.root.join("app/assets/stylesheets/application.tailwind.css").read
      light = css[/\[data-theme="featured-in"\]\s*\{([^}]*--color-primary:[^}]*)\}/m, 1]
      dark = css[/\[data-theme="featured-in-dark"\]\s*\{([^}]*--color-primary:[^}]*)\}/m, 1]

      refute_nil light, "expected a [data-theme=\"featured-in\"] block with --color-primary"
      refute_nil dark, "expected a [data-theme=\"featured-in-dark\"] block with --color-primary"
      assert_includes light, "--color-primary:"
      refute_includes light, "--color-primary-hover"
      refute_includes light, "--color-ghost-text"
      refute_includes light, "--button-"
      assert_includes dark, "--surface-content-color"
      refute_includes dark, "--color-primary-hover"
      refute_includes dark, "--color-ghost-text"
      refute_includes dark, "--button-"
      refute_includes dark, "--list-item-hover-background-color"
    end

    test "@theme inline names match :root custom properties" do
      theme_names = token_names(@css[/@theme inline \{.*?^\}/m])
      root_names = token_names(root_block)

      assert_equal root_names, theme_names
    end

    test "rounded is a no-op alias and does not restate the default palette" do
      rounded_block = @css[/\[data-theme="rounded"\]\s*\{(.*?)\}/m, 1]

      refute_nil rounded_block
      refute_includes rounded_block, "--color-primary"
      refute_includes rounded_block, "--radius-md"
      refute_includes rounded_block, "--shadow-sm"
      custom_properties = rounded_block.scan(/^\s*--[a-z0-9-]+\s*:/)
      assert_empty custom_properties, "[data-theme=rounded] must not assign custom properties; :root already holds the palette"
    end

    test "named theme blocks do not circular-map tokens" do
      @css.scan(/\[data-theme="([^"]+)"\]\s*\{(.*?)\}/m).each do |theme, body|
        body.scan(/^\s*(--[a-z0-9-]+)\s*:\s*(.+);$/).each do |name, value|
          refute_equal "var(#{name})", value.strip, "[data-theme=#{theme}] #{name} must not be a circular self-reference"
        end
      end
    end

    test "dark and ocean stay override-only" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      ocean_block = @css[/\[data-theme="ocean"\]\s*\{(.*?)\}/m, 1]

      refute_includes dark_block, "--button-primary-background-color"
      refute_includes ocean_block, "--button-primary-background-color"
      assert_includes dark_block, "--color-primary"
      assert_includes ocean_block, "--color-primary"
      assert_match(/--sidebar-background-color:\s*oklch\(0\.17 0\.01 250\)/, dark_block)
      assert_match(/--sidebar-background-color:\s*oklch\(0\.96 0\.02 220\)/, ocean_block)
    end

    test "secondary ghost chip and overlay paints derive from semantic tokens" do
      {
        "--color-secondary" => "color-mix(in oklab, var(--surface-muted-background-color) 18%, var(--surface-background-color))",
        "--color-secondary-hover" => "color-mix(in oklab, var(--surface-muted-background-color) 70%, var(--surface-background-color))",
        "--color-secondary-text" => "var(--surface-content-color)",
        "--color-ghost-hover" => "color-mix(in oklab, var(--surface-muted-background-color) 35%, var(--surface-background-color))",
        "--color-ghost-text" => "var(--surface-content-color)",
        "--chip-remove-hover-background-color" => "color-mix(in oklab, var(--surface-content-color) 10%, transparent)",
        "--modal-backdrop-color" => "var(--overlay-backdrop-color)",
        "--carousel-chevron-background-color" => "var(--overlay-scrim-color)",
        "--overlay-backdrop-color" => "rgb(0 0 0 / 0.5)",
        "--overlay-scrim-color" => "rgb(31 41 55 / 0.68)"
      }.each do |token, value|
        assert_match(/#{Regexp.escape(token)}:\s*#{Regexp.escape(value)}/, root_block)
      end

      refute_match(/--color-ghost-text:\s*#333/, root_block)
      refute_match(/--color-secondary:\s*#f5f5f5/, root_block)
      refute_match(/--chip-remove-hover-background-color:\s*rgb\(0 0 0 \/ 0\.1\)/, root_block)
    end

    test "dark block no longer restates derived component colours" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]

      %w[
        --color-secondary
        --color-secondary-hover
        --color-secondary-text
        --color-ghost-hover
        --color-ghost-text
        --carousel-chevron-background-color
        --switch-track-background-color
        --comments-inline-input-radius
        --modal-backdrop-color
        --list-item-hover-background-color
        --list-item-active-background-color
        --chip-remove-hover-background-color
      ].each do |token|
        refute_includes dark_block, "#{token}:", "dark should not override #{token}; it should follow :root wiring"
      end

      assert_match(/--modal-backdrop-blur:\s*3px/, dark_block)
      assert_match(/--overlay-backdrop-color:\s*rgb\(0 0 0 \/ 0\.65\)/, dark_block)
      assert_match(/--overlay-scrim-color:\s*rgb\(15 20 36 \/ 0\.72\)/, dark_block)
      assert_includes dark_block, "--color-primary-hover"
      assert_includes dark_block, "--shadow-sm"
      assert_includes dark_block, "--bottom-nav-background-color"
      assert_includes dark_block, "--top-nav-background-color"
      assert_includes dark_block, "--sidebar-background-color"
    end

    test "chrome greys alias surface tokens so named themes inherit" do
      {
        "--tabs-pill-inactive-text-color" => "var(--surface-muted-content-color)",
        "--tabs-pill-inactive-hover-background-color" => "var(--surface-muted-background-color)",
        "--tabs-pill-inactive-hover-text-color" => "var(--surface-content-color)",
        "--sidebar-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--top-nav-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--list-item-hover-background-color" => "var(--surface-muted-background-color)",
        "--list-item-active-background-color" => "var(--surface-muted-background-color)",
        "--list-marker-color" => "var(--surface-muted-content-color)",
        "--chat-message-incoming-background-color" => "var(--surface-muted-background-color)",
        "--chat-message-incoming-text-color" => "var(--surface-content-color)",
        "--chat-message-incoming-meta-color" => "var(--surface-muted-content-color)",
        "--avatar-background-color" => "var(--surface-muted-background-color)",
        "--avatar-text-color" => "var(--surface-content-color)",
        "--search-input-background-color" => "var(--surface-background-color)"
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

    test "alerts and toasts wash status colour instead of filling like buttons" do
      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"

      {
        "--alert-success-background-color" => "color-mix(in oklab, var(--color-success-background-color) 18%, var(--surface-background-color))",
        "--alert-success-border-color" => "color-mix(in oklab, var(--color-success-background-color) 42%, var(--surface-border-color))",
        "--alert-success-text-color" => "var(--surface-content-color)",
        "--alert-success-icon-color" => "color-mix(in oklab, var(--color-success-background-color) 78%, black)",
        "--alert-warning-background-color" => "color-mix(in oklab, var(--color-warning-background-color) 18%, var(--surface-background-color))",
        "--alert-warning-text-color" => "var(--surface-content-color)",
        "--alert-danger-background-color" => "color-mix(in oklab, var(--color-danger-background-color) 18%, var(--surface-background-color))",
        "--alert-danger-text-color" => "var(--surface-content-color)",
        "--toast-info-background-color" => "var(--alert-info-background-color)",
        "--toast-info-border-color" => "var(--alert-info-border-color)",
        "--toast-info-text-color" => "var(--alert-info-text-color)",
        "--toast-info-icon-color" => "var(--alert-info-icon-color)",
        "--toast-success-border-color" => "var(--alert-success-border-color)",
        "--button-success-background-color" => "var(--color-success-background-color)",
        "--badge-success-background-color" => "var(--color-success-background-color)"
      }.each do |token, value|
        assert_match(/#{Regexp.escape(token)}:\s*#{Regexp.escape(value)}/, root_block)
      end

      refute_match(/--alert-success-background-color:\s*var\(--color-success-background-color\)/, root_block)
      refute_match(/--toast-info-background-color:\s*var\(--color-primary\)/, root_block)
      assert_match(
        /--toast-dismiss-text-color:\s*var\(--surface-muted-content-color\)/,
        root_block
      )
      assert_match(
        /--toast-dismiss-hover-background-color:\s*color-mix\(in oklab, currentColor 8%, transparent\)/,
        root_block
      )
      refute_match(
        /--toast-danger-dismiss-background-color:\s*color-mix\(in oklab, var\(--toast-danger-text-color\)/,
        root_block
      )
    end

    test "active pill colours alias the primary button tokens" do
      assert_match(/--tabs-pill-active-background-color:\s*var\(--button-primary-background-color\)/, root_block)
      assert_match(/--tabs-pill-active-border-color:\s*var\(--button-primary-border-color\)/, root_block)
      assert_match(/--tabs-pill-active-text-color:\s*var\(--button-primary-text-color\)/, root_block)

      application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      assert_includes application, ".fp-pill-button-slots {"
      assert_includes application, "--tabs-pill-active-background-color: var(--fp-button-background);"
      refute_includes application, ":not([data-fp-style=\"primary\"])"
      refute_includes application, "--tabs-pill-default-background-color"
    end

    test "range thumb fill follows --color-primary with a surface ring" do
      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"
      assert_match(/--range-fill-color:\s*var\(--color-primary\)/, root_block)
      assert_match(/--range-thumb-color:\s*var\(--color-primary\)/, root_block)
      assert_match(/--range-thumb-border-color:\s*var\(--surface-background-color\)/, root_block)
      refute_match(/--range-thumb-color:\s*var\(--surface-background-color\)/, root_block)

      application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      assert_includes application, "background: var(--range-thumb-color);"
      assert_includes application, "border: 2px solid var(--range-thumb-border-color);"
      assert_includes application, "::-webkit-slider-thumb"
      assert_includes application, "::-moz-range-thumb"
      assert_includes application, ".fp-range-input:disabled"
      assert_includes application, ".fp-range-input:focus-visible"
      assert_includes application, ".fp-range-input-ends"
      assert_includes application, ".fp-range-input-glyph--start"
      assert_includes application, ".fp-range-input-glyph--end"
      assert_includes application, "font-family: var(--font-sans)"

      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      ocean_block = @css[/\[data-theme="ocean"\]\s*\{(.*?)\}/m, 1]
      refute_includes dark_block, "--range-thumb-color"
      refute_includes ocean_block, "--range-thumb-color"
      refute_includes dark_block, "--range-thumb-border-color"
      refute_includes ocean_block, "--range-thumb-border-color"
    end

    test "focus ring and active nav fills follow --color-primary" do
      {
        "--color-ring" => "var(--color-primary)",
        "--sidebar-item-active-background-color" => "var(--color-primary)",
        "--top-nav-item-active-background-color" => "var(--color-primary)",
        "--sidebar-item-active-text-color" => "var(--color-primary-text)",
        "--sidebar-item-active-icon-color" => "var(--color-primary-text)",
        "--top-nav-item-active-text-color" => "var(--color-primary-text)",
        "--top-nav-item-active-icon-color" => "var(--color-primary-text)"
      }.each do |token, value|
        assert_match(/#{Regexp.escape(token)}:\s*#{Regexp.escape(value)}/, root_block)
      end

      refute_match(/--color-ring:\s*#333/, root_block)
      refute_match(/--sidebar-item-active-background-color:\s*#333/, root_block)
      refute_match(/--top-nav-item-active-background-color:\s*#333/, root_block)
    end

    test "default palette re-declares on [data-theme] so descendant themes re-resolve" do
      assert_match(/^:root,\s*\[data-theme\]\s*\{/, @css)
    end

    test "dark and ocean do not freeze --color-ring; they follow --color-primary" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      ocean_block = @css[/\[data-theme="ocean"\]\s*\{(.*?)\}/m, 1]

      refute_includes dark_block, "--color-ring"
      refute_includes ocean_block, "--color-ring"
    end

    test "bottom nav bar stays a surface, not a brand fill" do
      assert_match(/--bottom-nav-background-color:\s*#2f2f2f/, root_block)
      refute_match(/--bottom-nav-background-color:\s*var\(--color-primary\)/, root_block)
    end

    private

    def token_names(block)
      block.to_s.scan(/^\s*(--[a-z0-9-]+)\s*:/).flatten.sort
    end

    def root_block
      @css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]
    end
  end
end
