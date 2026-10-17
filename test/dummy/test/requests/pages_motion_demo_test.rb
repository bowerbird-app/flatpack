# frozen_string_literal: true

require "test_helper"

class PagesMotionDemoTest < ActionDispatch::IntegrationTest
  test "motion demo renders every feature in its resting state" do
    get "/demo/motion"

    assert_response :success
    assert_includes response.body, "Motion"
    assert_includes response.body, "Sequence"
    assert_includes response.body, "Pack it once"
    assert_includes response.body, "Walnut, oiled, ready Friday."
    assert_includes response.body, "Start packing"
    assert_includes response.body, "--reveal-duration: var(--motion-duration-slower)"
    assert_includes response.body, "--reveal-delay: var(--motion-delay-md)"
    assert_includes response.body, "--reveal-delay: var(--motion-delay-lg)"
    assert_includes response.body, "--reveal-stagger: var(--motion-stagger-lg)"
    assert_includes response.body, "duration: :slower"
    assert_includes response.body, "delay: :md"
    assert_includes response.body, "delay: :lg"
    assert_includes response.body, "stagger: :lg"
    assert_includes response.body, "Same rise"
    assert_includes response.body, "--motion-duration-slow: var(--motion-duration-fast)"
    assert_includes response.body, "Gallery"
    assert_includes response.body, "fp-reveal--strong"
    assert_includes response.body, ">Default<"
    assert_includes response.body, ">Strong<"
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
    assert_includes response.body, "Numbers"
    assert_includes response.body, "fp-number--count"
    assert_includes response.body, "fp-number--roll"
    assert_includes response.body, "fp-number--fade"
    assert_includes response.body, "fp-number--none"
    assert_includes response.body, "is-static"
    assert_includes response.body, ">2,480<"
    assert_includes response.body, "$1,280.00"
    assert_includes response.body, ">64%<"
    assert_includes response.body, ">12K<"
    assert_includes response.body, "About 18 left"
    refute_includes response.body, "is-pending"
    refute_includes response.body, "is-streaming"
    refute_includes response.body, "is-settled"
  end

  test "motion specimen clip renders one reveal" do
    get "/demo/motion?clip=fade"

    assert_response :success
    assert_includes response.body, "id=\"motion-clip\""
    assert_includes response.body, "fp-reveal--fade"
    assert_includes response.body, "fp-reveal--strong"
    assert_includes response.body, ">Fade<"
    assert_includes response.body, ">Default<"
    assert_includes response.body, ">Strong<"
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

  test "motion number clip renders one counter" do
    get "/demo/motion?clip=count"

    assert_response :success
    assert_includes response.body, "id=\"motion-clip\""
    assert_includes response.body, "fp-number--count"
    assert_includes response.body, ">2,480<"
    assert_includes response.body, ">Count<"
    refute_includes response.body, "fp-number--roll"
    refute_includes response.body, "fp-reveal--fade"
    refute_includes response.body, "is-pending"
    refute_includes response.body, "Same rise"
  end

  test "motion number fade clip renders one fade" do
    get "/demo/motion?clip=number-fade"

    assert_response :success
    assert_includes response.body, "fp-number--fade"
    assert_includes response.body, ">Fade<"
    assert_includes response.body, ">2,480<"
    refute_includes response.body, "fp-reveal--fade"
    refute_includes response.body, "fp-number--count"
  end

  test "motion sequence clip renders the timed hero" do
    get "/demo/motion?clip=sequence"

    assert_response :success
    assert_includes response.body, "id=\"motion-clip\""
    assert_includes response.body, "Pack it once"
    assert_includes response.body, "var(--motion-duration-slower)"
    assert_includes response.body, "var(--motion-delay-md)"
    assert_includes response.body, "var(--motion-delay-lg)"
    assert_includes response.body, "var(--motion-stagger-lg)"
    assert_includes response.body, "Start packing"
    refute_includes response.body, "Same rise"
    refute_includes response.body, ">Gallery<"
    refute_includes response.body, "is-pending"
  end

  test "sidebar includes motion" do
    get "/demo/motion"

    assert_response :success
    assert_includes response.body, 'href="/demo/motion"'
  end
end
