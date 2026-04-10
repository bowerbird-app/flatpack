# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ConfigurationTest < ActiveSupport::TestCase
    setup do
      FlatPack.configuration = nil
    end

    test "configure initializes configuration with default theme" do
      FlatPack.configure { |_config| }

      assert_instance_of FlatPack::Configuration, FlatPack.configuration
      assert_equal :light, FlatPack.configuration.default_theme
      assert_equal :outline, FlatPack.configuration.default_icon_variant
    end

    test "configure allows overriding defaults" do
      FlatPack.configure do |config|
        config.default_theme = :dark
        config.default_icon_variant = :mini
      end

      assert_equal :dark, FlatPack.configuration.default_theme
      assert_equal :mini, FlatPack.configuration.default_icon_variant
    end

    test "configure reuses existing configuration object" do
      FlatPack.configure { |config| config.default_theme = :dark }
      first_object_id = FlatPack.configuration.object_id

      FlatPack.configure { |config| config.default_theme = :light }

      assert_equal first_object_id, FlatPack.configuration.object_id
      assert_equal :light, FlatPack.configuration.default_theme
    end

    test "default_icon_variant rejects unknown values" do
      error = assert_raises(ArgumentError) do
        FlatPack.configure { |config| config.default_icon_variant = :filled }
      end

      assert_includes error.message, "Invalid heroicon variant"
    end
  end
end
