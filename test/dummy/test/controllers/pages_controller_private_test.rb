# frozen_string_literal: true

require "test_helper"

class PagesControllerPrivateTest < ActiveSupport::TestCase
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

  private
end
