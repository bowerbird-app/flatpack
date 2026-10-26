# frozen_string_literal: true

require "test_helper"
require "fileutils"

class PagesControllerPrivateTest < ActiveSupport::TestCase
  test "flash demo is uncached" do
    assert_includes PagesController::UNCACHED_ACTIONS, :flash_demo
  end

  test "query-driven tables demos are uncached" do
    assert_includes PagesController::UNCACHED_ACTIONS, :tables_basic
    assert_includes PagesController::UNCACHED_ACTIONS, :tables_sortable
  end

  test "page_cache_key includes the query string" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/collage", fullpath: "/demo/collage?clip=rise")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }

    rise_key = controller.send(:page_cache_key)
    request.fullpath = "/demo/collage?clip=deal"
    deal_key = controller.send(:page_cache_key)

    refute_equal rise_key, deal_key
    assert_includes rise_key, "clip=rise"
    assert_includes deal_key, "clip=deal"
  end

  test "page_cache_key changes when page template version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic", fullpath: "/demo/tables/basic")
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
    request = OpenStruct.new(path: "/demo/tables/basic", fullpath: "/demo/tables/basic")
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
    request = OpenStruct.new(path: "/demo/tables/basic", fullpath: "/demo/tables/basic")
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

  test "page_cache_key changes when locale changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/", fullpath: "/")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }

    en_key = I18n.with_locale(:en) { controller.send(:page_cache_key) }
    fr_key = I18n.with_locale(:fr) { controller.send(:page_cache_key) }

    refute_equal en_key, fr_key
    assert_includes en_key, "/:en:"
    assert_includes fr_key, "/:fr:"
  end

  test "page_cache_key changes when component version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tree", fullpath: "/demo/tree")
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
    request = OpenStruct.new(path: "/demo/sidebar/collapsible", fullpath: "/demo/sidebar/collapsible")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates" }
    controller.define_singleton_method(:component_cache_version) { "components" }
    controller.define_singleton_method(:layout_stylesheet_cache_version) { "styles" }
    controller.define_singleton_method(:importmap_cache_version) { "importmap" }

    flush_key = controller.send(:page_cache_key)

    request.fullpath = "/demo/sidebar/collapsible?floating=1"
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
