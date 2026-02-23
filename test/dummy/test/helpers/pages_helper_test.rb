# frozen_string_literal: true

require "test_helper"

class PagesHelperTest < ActiveSupport::TestCase
  include PagesHelper

  test "demo_button_basic_examples returns expected shape" do
    examples = demo_button_basic_examples

    assert_equal 5, examples.size
    assert_equal "Primary", examples.first[:label]
    assert_equal({text: "Primary", style: :primary}, examples.first[:kwargs])
  end

  test "demo_button_snippets builds erb code for each example" do
    snippets = demo_button_snippets([
      {label: "Primary", kwargs: {text: "Primary", style: :primary, disabled: false}}
    ])

    assert_equal 1, snippets.size
    assert_equal "Primary", snippets.first[:label]
    assert_equal "erb", snippets.first[:language]
    assert_includes snippets.first[:code], "FlatPack::Button::Component"
    assert_includes snippets.first[:code], "style: :primary"
    assert_includes snippets.first[:code], "disabled: false"
  end

  test "demo_component_render_code renders string symbol and numeric kwargs" do
    code = send(
      :demo_component_render_code,
      "FlatPack::Button::Component",
      {text: "Click", style: :ghost, tab_index: 3}
    )

    assert_equal '<%= render FlatPack::Button::Component.new(text: "Click", style: :ghost, tab_index: 3) %>', code
  end

  test "demo_code_value handles symbol string and other objects" do
    assert_equal ":warning", send(:demo_code_value, :warning)
    assert_equal '"hello"', send(:demo_code_value, "hello")
    assert_equal "123", send(:demo_code_value, 123)
  end
end
