# frozen_string_literal: true

require "test_helper"

class PagesFloatingFrameDemoTest < ActionDispatch::IntegrationTest
  test "floating frame demo pins a launcher and keeps the iframe in a template" do
    get "/demo/floating_frame"

    assert_response :success
    assert_includes response.body, "fp-floating-frame"
    assert_includes response.body, 'aria-label="Open notes"'
    assert_includes response.body, 'aria-expanded="false"'
    assert_includes response.body, 'aria-controls="notes-frame-panel"'
    assert_includes response.body, 'data-fp-position="bottom_left"'
    assert_includes response.body, 'role="dialog"'
    assert_includes response.body, "<template"
    assert_includes response.body, 'src="/demo/floating_frame/page"'
    assert_includes response.body, 'sandbox="allow-scripts allow-same-origin allow-forms allow-popups"'
    refute_includes response.body, "allow-top-navigation"
  end

  test "framed page is a same-origin document" do
    get "/demo/floating_frame/page"

    assert_response :success
    assert_includes response.body, "Notes"
    assert_includes response.body, 'id="scratch"'
  end

  test "sidebar includes floating frame" do
    get "/demo/floating_frame"

    assert_response :success
    assert_includes response.body, 'href="/demo/floating_frame"'
    assert_includes response.body, "Floating frame"
  end
end
