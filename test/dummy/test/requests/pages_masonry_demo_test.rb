# frozen_string_literal: true

require "test_helper"

class PagesMasonryDemoTest < ActionDispatch::IntegrationTest
  test "masonry demo renders a gallery of linked media tiles" do
    get "/demo/masonry"

    assert_response :success
    assert_includes response.body, "Masonry"
    assert_includes response.body, "fp-masonry--columns"
    assert_includes response.body, "fp-masonry--rows"
    assert_includes response.body, 'data-controller="flat-pack--masonry"'
    assert_includes response.body, 'loading="lazy"'
    assert_includes response.body, 'decoding="async"'
    assert_includes response.body, "aspect-ratio: 1120 / 1400"
    assert_includes response.body, "Harbour at dusk"
    assert_includes response.body, "JPG · 1120×1400 · 4:5"
    assert_includes response.body, "harbour.jpg"
    assert_includes response.body, "fp-overlay"
    assert_includes response.body, 'data-fp-placement="bottom_left"'
    assert_includes response.body, 'href="/masonry/harbour.svg"'
    assert_includes response.body, "Jetty notes"
    assert_includes response.body, ">Save<"
    assert_includes response.body, "group/media"
    refute_includes response.body, "fp-masonry__image"
    refute_includes response.body, "with_image"
    assert_includes response.body, demo_grid_path
    assert_includes response.body, demo_overlay_path
  end

  test "sidebar includes masonry" do
    get "/demo/masonry"

    assert_response :success
    assert_includes response.body, 'href="/demo/masonry"'
    assert_includes response.body, "Masonry"
  end
end
