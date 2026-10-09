# frozen_string_literal: true

require "test_helper"

class PagesMasonryDemoTest < ActionDispatch::IntegrationTest
  test "masonry demo renders both orders and an image cell" do
    get "/demo/masonry"

    assert_response :success
    assert_includes response.body, "Masonry"
    assert_includes response.body, "fp-masonry--columns"
    assert_includes response.body, "fp-masonry--rows"
    assert_includes response.body, 'data-controller="flat-pack--masonry"'
    assert_includes response.body, 'loading="lazy"'
    assert_includes response.body, 'decoding="async"'
    assert_includes response.body, "aspect-ratio: 400 / 600"
    assert_includes response.body, "Harbour at dusk"
    assert_includes response.body, "Jetty notes"
    assert_includes response.body, demo_grid_path
  end

  test "sidebar includes masonry" do
    get "/demo/masonry"

    assert_response :success
    assert_includes response.body, 'href="/demo/masonry"'
    assert_includes response.body, "Masonry"
  end
end
