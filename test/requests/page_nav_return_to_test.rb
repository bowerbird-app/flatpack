# frozen_string_literal: true

require "test_helper"

class PageNavReturnToTest < ActionDispatch::IntegrationTest
  REJECTED_RETURN_TO = [
    "//evil.com",
    "https://evil.com",
    "javascript:alert(1)",
    "/\\evil.com",
    "/\\\\evil.com",
    "https://evil.com%2F.example.com",
    "https%3A%2F%2Fevil.com",
    ""
  ].freeze

  setup do
    host! "www.example.com"
  end

  test "page nav demo shows a hidden back control and a back link" do
    get "/demo/page_nav"

    assert_response :success
    assert_includes response.body, "Custom order"
    assert_includes response.body, "The back icon is a link."
    refute_includes response.body, "show_back:"
    refute_includes response.body, "right_slot"
    refute_includes response.body, "anchor_url"
  end

  test "the carry screen keeps its own close link and passes that link along" do
    get demo_page_nav_carry_path, params: {return_to: "/demo/forms"}

    assert_response :success
    assert_select "div.mb-4 > nav.flat-pack-page-nav a[href='/demo/page_nav']"
    assert_select "nav.flat-pack-page-nav a[href='/demo/forms']", count: 0
    assert_select "a[href='/demo/page_nav/carry/next?return_to=%2Fdemo%2Fpage_nav']"
    assert_select "nav[data-controller='flat-pack--page-nav'][data-flat-pack--page-nav-fallback-url-value='/demo/page_nav']"
    assert_includes response.body, "Take the close icon along"
  end

  test "no page nav call and no return_to renders nothing" do
    get demo_page_nav_carry_next_path

    assert_response :success
    assert_select "nav.flat-pack-page-nav", count: 0
    assert_select "input[name=return_to]", count: 0
    assert_includes response.body, "Save and close"
  end

  test "an omitted anchor uses a valid relative return_to" do
    get demo_page_nav_carry_next_path, params: {return_to: "/demo/page_nav"}

    assert_response :success
    assert_select "nav.flat-pack-page-nav a[href='/demo/page_nav']"
    assert_select "nav[data-flat-pack--page-nav-fallback-url-value='/demo/page_nav']"
    assert_select "form[action='/demo/page_nav/carry']" do
      assert_select "input[type=hidden][name=return_to][value='/demo/page_nav']"
      assert_select "button[type=submit]", text: "Save and close"
    end
  end

  test "an omitted anchor uses a same-host absolute return_to" do
    url = "http://www.example.com/demo/page_nav"

    get demo_page_nav_carry_next_path, params: {return_to: url}

    assert_response :success
    assert_select "nav.flat-pack-page-nav a[href='#{url}']"
    assert_select "input[name=return_to][value='#{url}']"
  end

  test "rejected return_to values do not become the anchor" do
    REJECTED_RETURN_TO.each do |value|
      get demo_page_nav_carry_next_path, params: {return_to: value}

      assert_response :success
      assert_select "nav.flat-pack-page-nav", count: 0
      assert_select "input[name=return_to]", count: 0
      refute_match(/href=(["'])#{Regexp.escape(value)}\1/, response.body) if value.present?
    end
  end

  test "post with a valid return_to redirects there" do
    post demo_page_nav_carry_path, params: {return_to: "/demo/page_nav"}

    assert_redirected_to "/demo/page_nav"
  end

  test "post with a same-host absolute return_to redirects there" do
    url = "http://www.example.com/demo/forms"

    post demo_page_nav_carry_path, params: {return_to: url}

    assert_redirected_to url
  end

  test "post with a rejected return_to redirects to the fallback" do
    REJECTED_RETURN_TO.each do |value|
      post demo_page_nav_carry_path, params: {return_to: value}

      assert_redirected_to "/demo/page_nav"
      refute_includes response.location.to_s, "evil.com"
      refute_includes response.location.to_s, "javascript:"
    end
  end

  test "post with no return_to redirects to the fallback" do
    post demo_page_nav_carry_path

    assert_redirected_to "/demo/page_nav"
  end

  test "redirect_to_return_to requires a fallback" do
    controller = PageNavFlowController.new

    assert_raises(ArgumentError) { controller.redirect_to_return_to(fallback: "") }
    assert_raises(ArgumentError) { controller.redirect_to_return_to(fallback: nil) }
  end
end
