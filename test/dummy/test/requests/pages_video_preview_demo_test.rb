# frozen_string_literal: true

require "test_helper"

class PagesVideoPreviewDemoTest < ActionDispatch::IntegrationTest
  test "video preview demo keeps host players inside templates" do
    get "/demo/video_preview"

    assert_response :success
    assert_includes response.body, "fp-video-preview"
    assert_includes response.body, "Play: Launch trailer"
    assert_includes response.body, "Play: Packing the stool"
    assert_includes response.body, ">2:14<"
    assert_includes response.body, "/images/hero-packaging.jpg"
    assert_includes response.body, 'data-fp-placement="bottom_left"'
    assert_includes response.body, 'data-fp-inset="sm"'

    live = response.body.gsub(%r{<template\b[^>]*>.*?</template>}m, "")

    assert_match(%r{<template\b[^>]*>.*youtube-nocookie\.com/embed/aqz-KE-bpKQ\?autoplay=1.*</template>}m, response.body)
    assert_match(%r{<template\b[^>]*>.*<video\b[^>]*src="/videos/packing-sample.mp4".*</template>}m, response.body)
    refute_includes live, "youtube-nocookie.com"
    refute_includes live, "<video"
    refute_includes live, "<iframe"
  end

  test "sidebar includes video preview" do
    get "/demo/video_preview"

    assert_response :success
    assert_includes response.body, 'href="/demo/video_preview"'
    assert_includes response.body, "Video preview"
  end
end
