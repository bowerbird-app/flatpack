# frozen_string_literal: true

require "test_helper"

class PagesButtonsDemoTest < ActionDispatch::IntegrationTest
  test "buttons demo shows disabled button and link states" do
    get "/demo/buttons"

    assert_response :success
    assert_includes response.body, "Disabled Buttons"
    assert_select "button[disabled]", text: "Disabled Primary"
    assert_select "a[href]", text: "Disabled Link"
    assert_select "#button-link-and-form a.fp-button", text: "Open takes"
    assert_select "#button-link-and-form form.contents[action='#{demo_buttons_archive_path}'][method='post']" do
      assert_select "input[name='_method'][value='patch']", count: 1
      assert_select "input[name='take'][value='harbour']", count: 1
      assert_select "button[type='submit']", text: "Archive take"
    end
  end

  test "archive form returns to the buttons demo" do
    post demo_buttons_archive_path, params: {take: "harbour", _method: "patch"}

    assert_redirected_to "#{demo_buttons_path}#form-submit"
  end
end
