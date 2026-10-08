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
      assert_includes app.config.assets.paths, FlatPack::Engine.root.join("app/javascript")
    end

    test "importmap initializer appends engine importmap path" do
      app = OpenStruct.new(config: OpenStruct.new(importmap: OpenStruct.new(paths: [])))

      find_initializer("flat_pack.importmap").block.call(app)

      assert_includes app.config.importmap.paths, FlatPack::Engine.root.join("config/importmap.rb")
    end

    test "view component initializer appends preview path in test env" do
      app = OpenStruct.new(config: OpenStruct.new(view_component: OpenStruct.new(previews: OpenStruct.new(paths: []))))

      find_initializer("flat_pack.view_component").block.call(app)

      assert_includes app.config.view_component.previews.paths, FlatPack::Engine.root.join("test/components/previews").to_s
    end

    test "view component initializer initializes nil config and appends preview path in test env" do
      app = OpenStruct.new(config: OpenStruct.new(view_component: nil))

      find_initializer("flat_pack.view_component").block.call(app)

      assert_includes app.config.view_component.previews.paths, FlatPack::Engine.root.join("test/components/previews").to_s
    end

    test "view component initializer is a no-op when config has no view_component" do
      app = OpenStruct.new(config: OpenStruct.new)

      find_initializer("flat_pack.view_component").block.call(app)

      refute app.config.respond_to?(:view_component)
    end

    test "copy helper is mixed into views and skipped on API-like controllers" do
      assert_includes ActionView::Base.included_modules, FlatPack::CopyHelper

      api_like = Class.new
      base_like = Class.new do
        def self.helper(mod)
          (@helpers ||= []) << mod
        end

        def self.helpers
          @helpers || []
        end
      end

      [api_like, base_like].each do |klass|
        klass.class_eval do
          helper FlatPack::CopyHelper if respond_to?(:helper)
        end
      end

      refute_respond_to api_like, :helper
      assert_includes base_like.helpers, FlatPack::CopyHelper
    end

    test "view component slot compatibility helpers are available" do
      component = FlatPack::Comments::Thread::Component.new

      assert component.respond_to?(:set_slot, true)
      assert component.respond_to?(:get_slot, true)
      assert component.respond_to?(:set_polymorphic_slot, true)
    end

    private

    def find_initializer(name)
      FlatPack::Engine.initializers.find { |initializer| initializer.name == name }
    end
  end
end
