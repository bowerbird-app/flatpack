# frozen_string_literal: true

require "test_helper"

class EngineLoadTest < ActiveSupport::TestCase
  test "FlatPack engine is loaded" do
    assert defined?(FlatPack::Engine), "FlatPack::Engine should be defined"
  end

  test "FlatPack engine is mounted" do
    routes = Rails.application.routes.routes.map(&:path).map(&:spec).map(&:to_s)
    assert routes.any? { |r| r.include?("flat_pack") },
      "FlatPack engine should be mounted in routes"
  end

  test "FlatPack module is accessible" do
    assert defined?(FlatPack), "FlatPack module should be defined"
  end
end
