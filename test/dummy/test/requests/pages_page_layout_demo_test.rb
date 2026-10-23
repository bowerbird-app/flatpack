# frozen_string_literal: true

require "test_helper"

class PagesPageLayoutDemoTest < ActionDispatch::IntegrationTest
  test "plain page is a single column with landmarks and no sidebar" do
    get "/demo/page_layout"

    assert_response :success
    assert_select "html[data-theme=rounded]"
    assert_select "#page-layout-demo[data-fp-page-layout-width=default][data-fp-page-layout-align=top]"
    assert_select "header", text: /Field notes/
    assert_select "main #page-layout-plain", text: /Packing notes/
    assert_select "footer #page-layout-footer"
    assert_select "a[href='/demo/page_layout?variant=float']"
    assert_select "a[href='/demo/page_layout?variant=article']"
    assert_select "a[href='/demo/page_layout?variant=login']"
    refute_includes response.body, "flat-pack--sidebar-layout"
    refute_includes response.body, "fp-backdrop"
    refute_includes response.body, "data-controller=\"dark-mode\""
  end

  test "floating variant pins a backdrop behind the shared bar" do
    get "/demo/page_layout?variant=float"

    assert_response :success
    assert_select "[data-flat-pack-content-scroll=behind]"
    assert_select "header.fp-top-nav .fp-card", count: 1
    assert_select "header.fp-top-nav a", text: "Sign in"
    assert_select "[data-fp-page-layout-width=wide]"
    assert_select ".fp-backdrop[aria-hidden=true]"
    assert_includes response.body, "/images/hero-packaging.jpg"
    assert_select "#page-layout-float", text: /On the road/
    refute_includes response.body, "flat-pack--sidebar-layout"
  end

  test "article variant uses the narrow column" do
    get "/demo/page_layout?variant=article"

    assert_response :success
    assert_select "[data-fp-page-layout-width=narrow][data-fp-page-layout-align=top]"
    assert_select "#page-layout-article", text: /A quieter morning/
  end

  test "login variant centers the card" do
    get "/demo/page_layout?variant=login"

    assert_response :success
    assert_select "[data-fp-page-layout-width=narrow][data-fp-page-layout-align=center]"
    assert_select "#page-layout-login", text: /Welcome back/
    assert_select "input[type=email]"
    assert_select "input[type=password]"
  end

  test "unknown variant falls back to plain" do
    get "/demo/page_layout?variant=kit"

    assert_response :success
    assert_select "#page-layout-plain"
  end

  test "light and dark themes set the page theme" do
    get "/demo/page_layout?theme=light"
    assert_response :success
    assert_select "html:not([data-theme])"

    get "/demo/page_layout?theme=dark"
    assert_response :success
    assert_select "html[data-theme=dark]"
  end
end
