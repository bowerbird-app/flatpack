# frozen_string_literal: true

require "test_helper"

class PagesCollageDemoTest < ActionDispatch::IntegrationTest
  test "collage demo renders a brick of cards, the scatters, and an empty state" do
    get "/demo/collage"

    assert_response :success
    assert_includes response.body, "Collage"
    assert_includes response.body, "fp-collage--brick"
    assert_includes response.body, "fp-collage--subtle"
    assert_includes response.body, "fp-collage--none"
    assert_includes response.body, "fp-collage--loose"
    assert_includes response.body, "fp-collage--motion"
    assert_includes response.body, "fp-collage--stack-md"
    assert_includes response.body, "fp-content-enter"
    assert_includes response.body, "--fp-collage-tracks: 10"
    assert_includes response.body, "--fp-collage-column: 1 / span 2"
    assert_includes response.body, "--fp-collage-column: 2 / span 2"
    assert_includes response.body, "Your story starts with a press kit"
    assert_includes response.body, "Create press kit"
    assert_includes response.body, "Add photos"
    assert_includes response.body, "Invite a writer"
    assert_includes response.body, "title_size"
    assert_includes response.body, "fp-empty-state"
    assert_includes response.body, "fp-display"
    assert_includes response.body, "fp-card"
    assert_match(/fp-card[^>]*>\s*One\s*</, response.body)
    assert_match(/fp-card[^>]*>\s*Nine\s*</, response.body)
    refute_includes response.body, "collage_card"
    refute_includes response.body, "object-cover"
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
