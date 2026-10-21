# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TokenAuditorTest < ActiveSupport::TestCase
    test "every referenced token is defined in variables.css" do
      result = FlatPack::TokenAuditor.new.call

      assert_predicate result, :success?, -> { "Missing tokens: #{result.missing.join(", ")}" }
    end

    test "primary shade fills are runtime tokens, not theme tokens" do
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-primary-hover-fill"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-primary-pressed-fill"

      variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes variables, "--fp-primary-hover-fill:"
      refute_includes variables, "--fp-primary-pressed-fill:"
      assert_includes application, "--fp-primary-hover-fill:"
      assert_includes application, "--fp-primary-pressed-fill:"
    end

    test "runtime fill percent is not a theme token" do
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--range-progress"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--collection-editor-columns"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-masonry-gap"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-masonry-row"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-collage-tilt"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-collage-angle"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--reveal-index"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--reveal-delay"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--reveal-duration"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-number-duration"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-collage-place-x"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-collage-from-x"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-trash-button-size"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-fab-offset"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-fab-nav-offset"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-primary-hover-fill"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-primary-pressed-fill"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-collection-min-item-width"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-list-key-width"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-range-value"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-range-scale"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-range-max"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--carousel-bleed"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--card-inset"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--card-inner-radius"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--sidebar-measured-width"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--sidebar-collapsed-frame"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--fp-panel-width"
      assert_includes TokenAuditor::RUNTIME_TOKENS, "--page-layout-width"
    end

    test "brand primitives and transition aliases are defined" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

      %w[--brand-hue --brand-chroma --brand-lightness --surface-subtle-background-color --transition-fast --transition-base --transition-slow].each do |token|
        assert_includes css, "#{token}:", "expected #{token} in variables.css"
      end
    end

    test "named themes only override tokens (do not redeclare full button alias sets)" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      dark_block = css[/\[data-theme~="dark"\]\s*\{(.*?)\}/m, 1]

      refute_nil dark_block
      refute_includes dark_block, "--button-primary-background-color"
      assert_includes css, "overrides only"
    end

    test "rounded theme block shifts spacing and does not copy the palette" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      rounded_block = css[/\[data-theme~="rounded"\]\s*\{(.*?)\}/m, 1]

      refute_nil rounded_block
      refute_includes rounded_block, "--color-primary"
      assert_includes rounded_block, "--space-2: 0.75rem"
      assert_includes rounded_block, "--density: 1"
      refute_empty rounded_block.scan(/^\s*--[a-z0-9-]+\s*:/)
    end
  end
end
