# frozen_string_literal: true

require "test_helper"

class PagesControllerPrivateTest < ActiveSupport::TestCase
  test "page_cache_key changes when page template version changes" do
    controller = PagesController.new
    request = OpenStruct.new(path: "/demo/tables/basic")
    controller.define_singleton_method(:request) { request }
    controller.define_singleton_method(:page_template_cache_version) { "templates-old" }
    old_key = controller.send(:page_cache_key)

    controller.define_singleton_method(:page_template_cache_version) { "templates-new" }
    new_key = controller.send(:page_cache_key)

    refute_equal old_key, new_key
    assert_includes new_key, request.path
  end

  private
end
