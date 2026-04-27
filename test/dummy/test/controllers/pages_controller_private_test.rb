# frozen_string_literal: true

require "test_helper"

class PagesControllerPrivateTest < ActiveSupport::TestCase
  test "page_cache_key changes when layout stylesheet digests change" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/forms/text_input")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:current_importmap_digest) { "importmap-stable" }

    first_helpers = Object.new
    second_helpers = Object.new

    define_asset_path_helper(first_helpers, {
      "application.css" => "/assets/application-old.css",
      "flat_pack/variables.css" => "/assets/flat_pack/variables-old.css",
      "flat_pack/rich_text.css" => "/assets/flat_pack/rich_text-old.css",
      "flat_pack/content_editor.css" => "/assets/flat_pack/content_editor-old.css"
    })

    define_asset_path_helper(second_helpers, {
      "application.css" => "/assets/application-new.css",
      "flat_pack/variables.css" => "/assets/flat_pack/variables-new.css",
      "flat_pack/rich_text.css" => "/assets/flat_pack/rich_text-new.css",
      "flat_pack/content_editor.css" => "/assets/flat_pack/content_editor-new.css"
    })

    controller.define_singleton_method(:helpers) { first_helpers }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:helpers) { second_helpers }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  test "page_cache_key changes when importmap digest changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/forms/text_input")
    controller.define_singleton_method(:request) { request }

    helpers = Object.new
    define_asset_path_helper(helpers, {
      "application.css" => "/assets/application-stable.css",
      "flat_pack/variables.css" => "/assets/flat_pack/variables-stable.css",
      "flat_pack/rich_text.css" => "/assets/flat_pack/rich_text-stable.css",
      "flat_pack/content_editor.css" => "/assets/flat_pack/content_editor-stable.css"
    })

    controller.define_singleton_method(:helpers) { helpers }
    controller.define_singleton_method(:current_importmap_digest) { "importmap-old" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:current_importmap_digest) { "importmap-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  test "page_cache_key changes when page template version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic")
    controller.define_singleton_method(:request) { request }

    helpers = Object.new
    define_asset_path_helper(helpers, {
      "application.css" => "/assets/application-stable.css",
      "flat_pack/variables.css" => "/assets/flat_pack/variables-stable.css",
      "flat_pack/rich_text.css" => "/assets/flat_pack/rich_text-stable.css",
      "flat_pack/content_editor.css" => "/assets/flat_pack/content_editor-stable.css"
    })

    controller.define_singleton_method(:helpers) { helpers }
    controller.define_singleton_method(:current_importmap_digest) { "importmap-stable" }
    controller.define_singleton_method(:page_template_cache_version) { "templates-old" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:page_template_cache_version) { "templates-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  private

  def define_asset_path_helper(helper, asset_paths)
    helper.define_singleton_method(:asset_path) do |logical_path|
      asset_paths.fetch(logical_path)
    end
  end
end
