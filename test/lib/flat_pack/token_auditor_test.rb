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

    test "named themes rebind primary-wired component tokens" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      rebind_block = css[%r{\[data-theme="dark"\],\s*\[data-theme="ocean"\],\s*\[data-theme="rounded"\]\s*\{(.*?)\}}m, 1]

      refute_nil rebind_block, "expected a shared named-theme primary-token rebind block"

      {
        "--button-primary-background-color" => "var(--color-primary)",
        "--button-primary-hover-background-color" => "var(--color-primary-hover)",
        "--button-primary-text-color" => "var(--color-primary-text)",
        "--button-primary-border-color" => "var(--color-primary)",
        "--tabs-pill-active-background-color" => "var(--color-primary)",
        "--sidebar-item-active-background-color" => "var(--color-primary)",
        "--switch-track-checked-background-color" => "var(--color-primary)"
      }.each do |token, value|
        assert_includes rebind_block, "#{token}: #{value}", "expected #{token} rebound to #{value}"
      end
    end
  end
end
