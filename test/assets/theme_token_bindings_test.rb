# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ThemeTokenBindingsTest < ActiveSupport::TestCase
    def rich_text_css
      FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/rich_text.css").read
    end

    def application_css
      FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    test "rich text focus and selection chrome use ring/primary tokens without blue oklch fallbacks" do
      css = rich_text_css

      assert_includes css, "box-shadow: 0 0 0 2px inset var(--color-ring);"
      assert_includes css, "background: color-mix(in oklab, var(--color-primary) 15%, transparent);"
      assert_includes css, "outline: 2px solid color-mix(in oklab, var(--color-ring) 40%, transparent);"
      assert_includes css, "box-shadow: 0 0 0 2px color-mix(in oklab, var(--color-primary) 15%, transparent);"
      refute_includes css, "oklch(0.52 0.26 250"
      refute_includes css, "#2563eb"
    end

    test "donut chart tooltips bind to tooltip/surface tokens instead of frozen white" do
      css = application_css

      assert_includes css, 'background: var(--tooltip-background-color, var(--surface-background-color)) !important;'
      assert_includes css, 'color: var(--tooltip-text-color, var(--surface-content-color)) !important;'
      refute_match(/\[data-flat-pack--chart-type-value="donut"\][^{]*\{[^}]*background:\s*#fff/m, css)
      refute_includes css, "background: #fff !important;"
    end
  end
end
