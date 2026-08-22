# frozen_string_literal: true

require "test_helper"

module FlatPack
  class NamedThemePrimaryTokenRebindTest < ActiveSupport::TestCase
    PRIMARY_BUTTON_TOKENS = {
      "--button-primary-background-color" => "var(--color-primary)",
      "--button-primary-hover-background-color" => "var(--color-primary-hover)",
      "--button-primary-text-color" => "var(--color-primary-text)",
      "--button-primary-border-color" => "var(--color-primary)"
    }.freeze

    test "rounded theme primary is charcoal and button aliases rebind to it" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      rounded_block = css[%r{\[data-theme="rounded"\]\s*\{(.*?)\}}m, 1]
      rebind_block = css[%r{\[data-theme="dark"\],\s*\[data-theme="ocean"\],\s*\[data-theme="rounded"\]\s*\{(.*?)\}}m, 1]

      refute_nil rounded_block
      refute_nil rebind_block
      assert_includes rounded_block, "--color-primary: oklch(0.3211 0 0)"

      PRIMARY_BUTTON_TOKENS.each do |token, value|
        assert_includes rebind_block, "#{token}: #{value}"
      end

      %w[
        --tabs-pill-active-background-color
        --sidebar-item-active-background-color
        --switch-track-checked-background-color
      ].each do |token|
        assert_includes rebind_block, "#{token}: var(--color-primary)"
      end
    end

    test "rounded theme rebinds radius-md component aliases" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      rounded_blocks = css.scan(%r{\[data-theme="rounded"\]\s*\{(.*?)\}}m).flatten
      radius_rebind = rounded_blocks.find { |block| block.include?("--button-border-radius: var(--radius-md)") }

      refute_nil radius_rebind, "expected [data-theme=rounded] to rebind --button-border-radius"
      assert_includes css, "--radius-md: 1rem"

      %w[
        --button-border-radius
        --alert-border-radius
        --toast-border-radius
        --accordion-border-radius
        --popover-radius
        --collapse-border-radius
        --chat-composer-radius
        --avatar-radius-square
      ].each do |token|
        assert_includes radius_rebind, "#{token}: var(--radius-md)"
      end

      dark_ocean_radius = css[%r{\[data-theme="dark"\]\s*\{(.*?)\}}m, 1].to_s + css[%r{\[data-theme="ocean"\]\s*\{(.*?)\}}m, 1].to_s
      refute_includes dark_ocean_radius, "--radius-md:"
    end
  end
end
