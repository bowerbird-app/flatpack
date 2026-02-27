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
    end

    test "configure allows overriding defaults" do
      FlatPack.configure do |config|
        config.default_theme = :dark
      end

      assert_equal :dark, FlatPack.configuration.default_theme
    end

    test "configure reuses existing configuration object" do
      FlatPack.configure { |config| config.default_theme = :dark }
      first_object_id = FlatPack.configuration.object_id

      FlatPack.configure { |config| config.default_theme = :light }

      assert_equal first_object_id, FlatPack.configuration.object_id
      assert_equal :light, FlatPack.configuration.default_theme
    end
  end
end
