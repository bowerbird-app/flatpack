# frozen_string_literal: true

require "test_helper"

class PagesEmbedDemoTest < ActionDispatch::IntegrationTest
  test "embed demo frames host iframes with titles" do
    get "/demo/embed"

    assert_response :success
    assert_includes response.body, "fp-embed"
    assert_includes response.body, 'title="Launch trailer"'
    assert_includes response.body, 'title="Studio location"'
    assert_includes response.body, 'title="Studio courtyard"'
    assert_includes response.body, "youtube-nocookie.com/embed/aqz-KE-bpKQ"
    assert_includes response.body, "openstreetmap.org/export/embed.html"
    assert_includes response.body, 'loading="lazy"'
    assert_includes response.body, 'referrerpolicy="strict-origin-when-cross-origin"'
    assert_includes response.body, 'sandbox="allow-scripts allow-same-origin allow-popups"'
    assert_includes response.body, "The workshop on OpenStreetMap"
    assert_includes response.body, "aspect-[16/9]"
    assert_includes response.body, "aspect-[4/3]"
    assert_includes response.body, "aspect-square"
  end

  test "sidebar includes embed" do
    get "/demo/embed"

    assert_response :success
    assert_includes response.body, 'href="/demo/embed"'
    assert_includes response.body, "Embed"
  end
end
