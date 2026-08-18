# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TokenAuditorTest < ActiveSupport::TestCase
    test "every referenced token is defined in variables.css" do
      result = FlatPack::TokenAuditor.new.call

      assert_predicate result, :success?, -> { "Missing tokens: #{result.missing.join(", ")}" }
    end

    test "brand primitives and transition aliases are defined" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

      %w[--brand-hue --brand-chroma --brand-lightness --surface-subtle-background-color --transition-fast --transition-base --transition-slow].each do |token|
        assert_includes css, "#{token}:", "expected #{token} in variables.css"
      end
    end

    test "named themes only override tokens (do not redeclare full button alias sets)" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      dark_block = css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]

      refute_nil dark_block
      refute_includes dark_block, "--button-primary-background-color"
      assert_includes css, "overrides only"
    end
  end
end
