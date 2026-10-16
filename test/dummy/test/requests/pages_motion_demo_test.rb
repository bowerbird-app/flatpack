# frozen_string_literal: true

require "test_helper"

class PagesMotionDemoTest < ActionDispatch::IntegrationTest
  test "motion demo renders every feature in its resting state" do
    get "/demo/motion"

    assert_response :success
    assert_includes response.body, "Motion"
    assert_includes response.body, "Same rise"
    assert_includes response.body, "--motion-duration-slow: var(--motion-duration-fast)"
    assert_includes response.body, "Gallery"
    assert_includes response.body, ">Fade<"
    assert_includes response.body, ">Rise<"
    assert_includes response.body, ">Blur<"
    assert_includes response.body, ">Scale<"
    assert_includes response.body, ">Wipe<"
    assert_includes response.body, ">Zoom<"
    assert_includes response.body, ">Words<"
    assert_includes response.body, ">Lines<"
    assert_includes response.body, "fp-reveal--fade"
    assert_includes response.body, "fp-reveal--rise"
    assert_includes response.body, "fp-reveal--blur"
    assert_includes response.body, "fp-reveal--scale"
    assert_includes response.body, "fp-reveal--stagger"
    assert_includes response.body, "fp-reveal--words"
    assert_includes response.body, "fp-reveal--lines"
    assert_includes response.body, "fp-reveal--wipe"
    assert_includes response.body, "fp-reveal--zoom"
    assert_includes response.body, "fp-reveal--parallax"
    assert_includes response.body, "fp-reveal__plain"
    assert_includes response.body, "Pack the walnut"
    assert_includes response.body, "fp-text-stream"
    assert_includes response.body, "The walnut stool ships Friday."
    refute_includes response.body, "is-pending"
    refute_includes response.body, "is-streaming"
  end

  test "motion specimen clip renders one reveal" do
    get "/demo/motion?clip=fade"

    assert_response :success
    assert_includes response.body, "id=\"motion-clip\""
    assert_includes response.body, "fp-reveal--fade"
    assert_includes response.body, ">Fade<"
    refute_includes response.body, "fp-reveal--rise"
    refute_includes response.body, "fp-reveal--wipe"
    refute_includes response.body, "Pack the walnut"
  end

  test "motion clip renders one feature on the full page layout marker" do
    get "/demo/motion?clip=text"

    assert_response :success
    assert_includes response.body, "id=\"motion-clip\""
    assert_includes response.body, "fp-reveal--words"
    assert_includes response.body, "fp-reveal--lines"
    refute_includes response.body, "fp-reveal--wipe"
    refute_includes response.body, "fp-text-stream"
    refute_includes response.body, "Same rise"
  end

  test "sidebar includes motion" do
    get "/demo/motion"

    assert_response :success
    assert_includes response.body, 'href="/demo/motion"'
  end
end
