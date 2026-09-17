# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class StyleRegistryTest < ActiveSupport::TestCase
      setup do
        @previous = StyleRegistry.extra_styles.dup
        StyleRegistry.reset!
        @previous.each do |name, config|
          StyleRegistry.register(name, press: config.fetch(:press))
        end
        StyleRegistry.unregister(:spec_stripe)
        StyleRegistry.unregister(:spec_quiet)
      end

      teardown do
        StyleRegistry.reset!
        @previous.each do |name, config|
          StyleRegistry.register(name, press: config.fetch(:press))
        end
      end

      test "register_style adds a known style" do
        FlatPack::Button.register_style(:spec_stripe, press: :raised)

        assert_includes FlatPack::Button.styles, :spec_stripe
        assert_equal :raised, StyleRegistry.press_for(:spec_stripe)
        assert_equal "fp-button-raised", StyleRegistry.press_class(:spec_stripe)
      end

      test "register_style accepts flat press" do
        FlatPack::Button.register_style(:spec_quiet, press: :flat)

        assert_equal :flat, StyleRegistry.press_for(:spec_quiet)
        assert_equal "fp-button-flat", StyleRegistry.press_class(:spec_quiet)
      end

      test "cannot replace a built-in style" do
        error = assert_raises(ArgumentError) do
          FlatPack::Button.register_style(:primary, press: :flat)
        end

        assert_match(/built-in/, error.message)
        assert_equal :raised, StyleRegistry.press_for(:primary)
      end

      test "rejects unknown press" do
        error = assert_raises(ArgumentError) do
          FlatPack::Button.register_style(:spec_stripe, press: :bouncy)
        end

        assert_match(/Invalid press/, error.message)
      end

      test "rejects invalid style names" do
        error = assert_raises(ArgumentError) do
          FlatPack::Button.register_style("Stripe-CTA")
        end

        assert_match(/Invalid style name/, error.message)
      end

      test "re-registering a custom style updates press" do
        FlatPack::Button.register_style(:spec_stripe, press: :raised)
        FlatPack::Button.register_style(:spec_stripe, press: :flat)

        assert_equal :flat, StyleRegistry.press_for(:spec_stripe)
      end

      test "built-in names stay the catalog SCHEMES keys" do
        FlatPack::Button.register_style(:spec_stripe)

        assert_equal %i[default primary secondary ghost success warning danger], Component::SCHEMES.keys
        refute_includes Component::SCHEMES.keys, :spec_stripe
      end
    end
  end
end
