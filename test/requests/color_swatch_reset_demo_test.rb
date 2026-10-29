# frozen_string_literal: true

require "test_helper"

class ColorSwatchResetDemoTest < ActionDispatch::IntegrationTest
  test "color swatches demo wires public reset without host internals" do
    get "/demo/color_swatches"

    assert_response :success
    assert_includes response.body, "Reset the picker"
    assert_includes response.body, "color-swatch:reset"
    assert_select "[data-controller='color-swatch-reset-demo']"
    assert_select "[data-action*='click->color-swatch-reset-demo#reset']"
    assert_select "[data-controller='flat-pack--color-swatch'][data-action*='color-swatch:reset->flat-pack--color-swatch#reset']"
    assert_select "[data-controller='flat-pack--color-swatch'][data-action*='color-swatch:clear->flat-pack--color-swatch#clear']"
  end
end
