# frozen_string_literal: true

require "test_helper"

class FontSwatchResetDemoTest < ActionDispatch::IntegrationTest
  test "font swatches demo wires public reset without host internals" do
    get "/demo/font_swatches"

    assert_response :success
    assert_includes response.body, "Reset the face"
    assert_includes response.body, "font-swatch:reset"
    assert_select "[data-controller='font-swatch-reset-demo']"
    assert_select "[data-action*='click->font-swatch-reset-demo#reset']"
    assert_select "[data-controller='flat-pack--font-swatch'][data-action*='font-swatch:reset->flat-pack--font-swatch#reset']"
    assert_select "[data-flat-pack--font-swatch-font-value='ui-sans-serif']"
  end
end
