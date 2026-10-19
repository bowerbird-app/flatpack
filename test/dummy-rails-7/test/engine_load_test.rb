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

  test "application.css imports compile to digested sibling urls" do
    assembly = Rails.application.assets
    compiled = assembly.load_path.find("flat_pack/application.css").compiled_content

    refute_match(%r{flat_pack/flat_pack/}, compiled)
    refute_match(/@import\s+["']/, compiled)

    %w[variables rich_text content_editor inline_edit].each do |name|
      sibling = assembly.load_path.find("flat_pack/#{name}.css")
      assert_includes compiled, %(url("#{assembly.prefix}#{sibling.digested_path}"))
    end
  end
end
