# frozen_string_literal: true

require "test_helper"

class PagesCollageDemoTest < ActionDispatch::IntegrationTest
  test "collage demo renders a photo wall, the scatters, and an empty state" do
    get "/demo/collage"

    assert_response :success
    assert_includes response.body, "Collage"
    assert_includes response.body, "fp-collage--subtle"
    assert_includes response.body, "fp-collage--none"
    assert_includes response.body, "fp-collage--loose"
    assert_includes response.body, "fp-collage--motion"
    assert_includes response.body, "fp-collage--stack-md"
    assert_includes response.body, "fp-content-enter"
    assert_includes response.body, "--fp-collage-columns: 3"
    assert_includes response.body, "--fp-collage-columns: 4"
    assert_includes response.body, "--fp-collage-angle: -6deg"
    assert_includes response.body, "Harbour at dusk"
    assert_includes response.body, "Blue hour"
    assert_includes response.body, "No stories yet"
    assert_includes response.body, "Add a photo"
    assert_includes response.body, "fp-empty-state"
    assert_operator response.body.scan('src="/masonry/harbour.svg"').size, :>=, 1
    refute_includes response.body, "position: absolute"
    refute_includes response.body, "position:absolute"
  end

  test "sidebar includes collage" do
    get "/demo/collage"

    assert_response :success
    assert_includes response.body, 'href="/demo/collage"'
    assert_includes response.body, "Collage"
  end
end
