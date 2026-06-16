# frozen_string_literal: true

require "test_helper"

class PagesControllerPrivateTest < ActiveSupport::TestCase
  test "query-driven tables demos are uncached" do
    assert_includes PagesController::UNCACHED_ACTIONS, :tables_basic
    assert_includes PagesController::UNCACHED_ACTIONS, :tables_sortable
  end

  test "page_cache_key changes when page template version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates-old" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:page_template_cache_version) { "templates-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  test "page_cache_key changes when layout stylesheet version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles-old" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
  end

  test "page_cache_key changes when importmap version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap-old" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:importmap_cache_version) { "importmap-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
  end

  test "importmap cache version changes when flatpack controller javascript changes" do
    controller = PagesController.new
    controller_path = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/flatpack_date_picker_controller.js")
    original_atime = File.atime(controller_path)
    original_mtime = File.mtime(controller_path)
    old_version = controller.send(:importmap_cache_version)

    File.utime(original_atime, original_mtime + 5.seconds, controller_path)
    new_version = controller.send(:importmap_cache_version)

    refute_equal old_version, new_version
  ensure
    File.utime(original_atime, original_mtime, controller_path) if original_atime && original_mtime
  end

  test "page_cache_key changes when component version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tree")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components-old" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:component_cache_version) { "components-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  private
end
