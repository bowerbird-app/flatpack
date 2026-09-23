# frozen_string_literal: true

require "test_helper"
require "fileutils"

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

  test "page_cache_key separates the floating shell from the flush rail" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/sidebar/collapsible", query_string: "")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }
    controller.define_singleton_method(:params) { ActionController::Parameters.new({}) }

    flush_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:params) { ActionController::Parameters.new(floating: "1") }
    floating_key = controller.send(:page_cache_key)

    refute_equal flush_key, floating_key
    assert_includes floating_key, "floating"
    assert_includes flush_key, request.path
  end

  test "page_template_cache_version includes shared view partials" do
    controller = PagesController.new
    version = controller.send(:page_template_cache_version)

    refute_nil version
    refute_empty version

    related = Rails.root.join("app/views/shared/_related_demos.html.erb")
    assert File.file?(related)

    stamp = File.mtime(related)
    FileUtils.touch(related, mtime: stamp + 1)
    begin
      refute_equal version, controller.send(:page_template_cache_version)
    ensure
      FileUtils.touch(related, mtime: stamp)
    end
  end

  private
end
