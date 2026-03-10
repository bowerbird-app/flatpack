# frozen_string_literal: true

require "test_helper"
require "ostruct"

module FlatPack
  class EngineTest < ActiveSupport::TestCase
    test "engine isolates namespace" do
      assert_equal "flat_pack", FlatPack::Engine.engine_name
    end

    test "assets initializer appends stylesheet and javascript paths" do
      app = OpenStruct.new(config: OpenStruct.new(assets: OpenStruct.new(paths: [])))

      find_initializer("flat_pack.assets").block.call(app)

      assert_includes app.config.assets.paths, FlatPack::Engine.root.join("app/assets/stylesheets")
      assert_includes app.config.assets.paths, FlatPack::Engine.root.join("app/assets/javascripts")
      assert_includes app.config.assets.paths, FlatPack::Engine.root.join("app/javascript")
    end

    test "importmap initializer appends engine importmap path" do
      app = OpenStruct.new(config: OpenStruct.new(importmap: OpenStruct.new(paths: [])))

      find_initializer("flat_pack.importmap").block.call(app)

      assert_includes app.config.importmap.paths, FlatPack::Engine.root.join("config/importmap.rb")
    end

    test "view component initializer appends preview path in test env" do
      app = OpenStruct.new(config: OpenStruct.new(view_component: OpenStruct.new(preview_paths: [])))

      find_initializer("flat_pack.view_component").block.call(app)

      assert_includes app.config.view_component.preview_paths, FlatPack::Engine.root.join("test/components/previews").to_s
    end

    test "view component initializer is a no-op when config has no view_component" do
      app = OpenStruct.new(config: OpenStruct.new)

      find_initializer("flat_pack.view_component").block.call(app)

      refute app.config.respond_to?(:view_component)
    end

    private

    def find_initializer(name)
      FlatPack::Engine.initializers.find { |initializer| initializer.name == name }
    end
  end
end
