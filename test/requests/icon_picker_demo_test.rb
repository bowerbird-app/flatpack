# frozen_string_literal: true

require "test_helper"

class IconPickerDemoTest < ActionDispatch::IntegrationTest
  test "the demo renders twenty pickers from one shared catalog" do
    get "/demo/forms/icon_picker"

    assert_response :success
    assert_includes response.body, "Icon picker"
    assert_includes response.body, "icon-picker-rows"
    assert_includes response.body, "id=\"icon-field\""
    assert_includes response.body, "id=\"icon-cell-inbox\""
    assert_includes response.body, "id=\"icon-restricted\""
    assert_equal 20, response.body.scan(/id="weight-icon-\d+"/).size

    template_ids = response.body.scan(/id="(flat-pack-icon-catalog-outline-[a-f0-9]+)"/).flatten.uniq
    assert_equal 2, template_ids.size
    assert_equal 1, response.body.scan('data-icon-name="arrow-right"').size

    template_svgs = response.body.scan(/<template\b.*?<\/template>/m).sum { |chunk| chunk.scan("<svg").size }
    assert_operator template_svgs, :>, 300
    assert_operator template_svgs, :<, 400
  end
end
