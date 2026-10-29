# frozen_string_literal: true

require "test_helper"

class PagesButtonsDemoTest < ActionDispatch::IntegrationTest
  test "buttons demo shows disabled button and link states" do
    get "/demo/buttons"

    assert_response :success
    assert_includes response.body, "Disabled Buttons"
    assert_select "button[disabled]", text: "Disabled Primary"
    assert_select "a[href]", text: "Disabled Link"
  end
end
