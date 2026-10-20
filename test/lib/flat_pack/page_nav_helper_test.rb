# frozen_string_literal: true

require "test_helper"

class PageNavHelperProbesController < ApplicationController
  def bare
    render inline: "A<%= flat_pack_page_nav %>B<%= flat_pack_page_nav_tag %>", layout: false
  end

  def replace
    render inline: <<~ERB, layout: false
      <% flat_pack_page_nav(back_href: "/first", anchor_href: "/first") %>
      <% flat_pack_page_nav(anchor_href: "/second") %>
      <%= flat_pack_page_nav_tag %>
    ERB
  end

  def unknown
    helpers.flat_pack_page_nav(not_a_real_argument: true)
    head :ok
  end

  def deprecated_back
    helpers.flat_pack_page_nav(back_label: "Back")
    head :ok
  end

  def deprecated_anchor
    helpers.flat_pack_page_nav(anchor_label: "Close")
    head :ok
  end

  def return_to_url
    helpers.flat_pack_page_nav(anchor_href: "/demo/page_nav")
    render plain: helpers.flat_pack_return_to_url("/next?x=1&return_to=/old#panel")
  end

  def return_to_field
    helpers.flat_pack_page_nav(anchor_href: "/demo/page_nav")
    render inline: "<%= flat_pack_return_to_field %>", layout: false
  end

  def unchanged
    render plain: helpers.flat_pack_return_to_url("/next?x=1")
  end

  def empty_field
    render inline: "[<%= flat_pack_return_to_field %>]", layout: false
  end

  def carried
    render plain: helpers.flat_pack_return_to_url("/next?x=1")
  end

  def round_links
    helpers.flat_pack_page_nav(round: true, anchor_href: "/close", anchor_tooltip: "Close", anchor_style: :ghost) do |nav|
      nav.with_link(href: "/home", icon: "home", tooltip: "Home")
      nav.with_link(href: "/admin", icon: "squares-2x2", tooltip: "Admin")
    end
    render inline: "<%= flat_pack_page_nav_tag %>", layout: false
  end

  def unsafe_link
    helpers.flat_pack_page_nav do |nav|
      nav.with_link(href: "javascript:alert(1)", icon: "home", tooltip: "Home")
    end
    render inline: "<%= flat_pack_page_nav_tag %>", layout: false
  end

  def removed_secondary
    helpers.flat_pack_page_nav(secondary_anchor_href: "/secondary")
    head :ok
  end
end

class PageNavHelperTest < ActionDispatch::IntegrationTest
  setup do
    host! "www.example.com"
  end

  test "spec rejects unknown keys and deprecated labels" do
    assert_raises(ArgumentError) { FlatPack::PageNav::Spec.new(not_a_real_argument: true) }
    assert_raises(ArgumentError) { FlatPack::PageNav::Spec.new(back_label: "Back") }
    assert_raises(ArgumentError) { FlatPack::PageNav::Spec.new(anchor_label: "Close") }
    assert_raises(ArgumentError) { FlatPack::PageNav::Spec.new(system_arguments: {class: "x"}) }
    assert_raises(ArgumentError) { FlatPack::PageNav::Spec.new(secondary_anchor_href: "/secondary") }
  end

  test "spec keeps a non-blank anchor and fills a missing one" do
    kept = FlatPack::PageNav::Spec.new(anchor_href: "/keep", back_tooltip: "Back")

    assert_same kept, kept.with_inbound_anchor("/other")
    assert_same kept, kept.with_inbound_anchor("")
    assert_same kept, kept.with_inbound_anchor(nil)
    assert_equal "/keep", kept.to_component_kwargs[:anchor_href]

    filled = FlatPack::PageNav::Spec.new(back_tooltip: "Back").with_inbound_anchor("/demo/page_nav")

    assert_equal "/demo/page_nav", filled.to_component_kwargs[:anchor_href]
    assert_equal "Back", filled.to_component_kwargs[:back_tooltip]
  end

  test "spec accepts component keywords and html attributes" do
    spec = FlatPack::PageNav::Spec.new(
      show_back: false,
      back_href: "/studio",
      class: "custom-page-nav",
      id: "page-nav",
      data: {testid: "page-nav"},
      aria: {describedby: "title"}
    )

    assert_equal false, spec.to_component_kwargs[:show_back]
    assert_equal "/studio", spec.to_component_kwargs[:back_href]
    assert_equal "custom-page-nav", spec.to_component_kwargs[:class]
    assert_equal "page-nav", spec.to_component_kwargs[:id]
    assert_equal({testid: "page-nav"}, spec.to_component_kwargs[:data])
    assert_equal({describedby: "title"}, spec.to_component_kwargs[:aria])
  end

  test "spec stores round and middle links and keeps them when an anchor is filled" do
    spec = FlatPack::PageNav::Spec.new(round: true, back_tooltip: "Back") do |nav|
      nav.with_link(href: "/home", icon: "home", tooltip: "Home")
      nav.with_link(href: "/admin", icon: "squares-2x2", tooltip: "Admin")
    end

    assert_equal true, spec.to_component_kwargs[:round]
    assert_equal [
      {href: "/home", icon: "home", tooltip: "Home"},
      {href: "/admin", icon: "squares-2x2", tooltip: "Admin"}
    ], spec.links

    filled = spec.with_inbound_anchor("/demo/page_nav")

    assert_equal "/demo/page_nav", filled.to_component_kwargs[:anchor_href]
    assert_equal true, filled.to_component_kwargs[:round]
    assert_equal spec.links, filled.links
    assert_equal [], spec.to_component_kwargs.keys & [:anchor_href]
  end

  test "unknown key raises from the helper" do
    with_page_nav_routes do
      assert_raises(ArgumentError) { get "/demo/page_nav_helper/unknown" }
    end
  end

  test "deprecated labels raise from the helper" do
    with_page_nav_routes do
      assert_raises(ArgumentError) { get "/demo/page_nav_helper/deprecated_back" }
      assert_raises(ArgumentError) { get "/demo/page_nav_helper/deprecated_anchor" }
    end
  end

  test "a call with no kwargs renders the back button and returns nil" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/bare"

      assert_response :success
      assert_match(/\AAB<nav/, response.body)
      assert_select "button[data-action='click->flat-pack--page-nav#back']"
      assert_select "nav[data-controller='flat-pack--page-nav']"
    end
  end

  test "a second call replaces the first" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/replace"

      assert_response :success
      assert_select "a[href='/second']"
      assert_select "a[href='/first']", count: 0
      assert_select "button[data-action='click->flat-pack--page-nav#back']"
    end
  end

  test "return_to url replaces an existing return_to and keeps the rest of the path" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/return_to_url"

      assert_response :success
      assert_equal "/next?x=1&return_to=%2Fdemo%2Fpage_nav#panel", response.body
    end
  end

  test "return_to url is unchanged when there is no anchor" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/unchanged"

      assert_response :success
      assert_equal "/next?x=1", response.body
    end
  end

  test "return_to field renders the anchor and is empty without one" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/return_to_field"

      assert_response :success
      assert_select "input[type=hidden][name=return_to][value='/demo/page_nav']"

      get "/demo/page_nav_helper/empty_field"

      assert_response :success
      assert_equal "[]", response.body
    end
  end

  test "the helper passes round and middle links through to the tag" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/round_links"

      assert_response :success
      assert_select "a[href='/home'][aria-label='Home']"
      assert_select "a[href='/admin'][aria-label='Admin']"
      assert_select "a[href='/close'][aria-label='Close']"
      assert_select "a[href='/home'][data-fp-style='ghost']"
      assert_match(/rounded-\[var\(--button-round-border-radius\)\]/, response.body)
      home = response.body.index('href="/home"')
      admin = response.body.index('href="/admin"')
      close = response.body.index('href="/close"')
      assert_operator close, :<, home
      assert_operator home, :<, admin
    end
  end

  test "the helper rejects an unsafe middle link and a removed secondary anchor argument" do
    with_page_nav_routes do
      error = assert_raises(ActionView::Template::Error) { get "/demo/page_nav_helper/unsafe_link" }
      assert_match(/Unsafe URL detected/, error.message)
      assert_kind_of ArgumentError, error.cause

      error = assert_raises(ArgumentError) { get "/demo/page_nav_helper/removed_secondary" }
      assert_match(/secondary_anchor_href/, error.message)
    end
  end

  test "an omitted anchor uses a valid return_to on the url helper" do
    with_page_nav_routes do
      get "/demo/page_nav_helper/carried", params: {return_to: "/demo/page_nav"}

      assert_response :success
      assert_equal "/next?x=1&return_to=%2Fdemo%2Fpage_nav", response.body
    end
  end

  private

  def with_page_nav_routes
    with_routing do |set|
      set.draw do
        get "/demo/page_nav_helper/bare", to: "page_nav_helper_probes#bare"
        get "/demo/page_nav_helper/replace", to: "page_nav_helper_probes#replace"
        get "/demo/page_nav_helper/unknown", to: "page_nav_helper_probes#unknown"
        get "/demo/page_nav_helper/deprecated_back", to: "page_nav_helper_probes#deprecated_back"
        get "/demo/page_nav_helper/deprecated_anchor", to: "page_nav_helper_probes#deprecated_anchor"
        get "/demo/page_nav_helper/return_to_url", to: "page_nav_helper_probes#return_to_url"
        get "/demo/page_nav_helper/return_to_field", to: "page_nav_helper_probes#return_to_field"
        get "/demo/page_nav_helper/unchanged", to: "page_nav_helper_probes#unchanged"
        get "/demo/page_nav_helper/empty_field", to: "page_nav_helper_probes#empty_field"
        get "/demo/page_nav_helper/carried", to: "page_nav_helper_probes#carried"
        get "/demo/page_nav_helper/round_links", to: "page_nav_helper_probes#round_links"
        get "/demo/page_nav_helper/unsafe_link", to: "page_nav_helper_probes#unsafe_link"
        get "/demo/page_nav_helper/removed_secondary", to: "page_nav_helper_probes#removed_secondary"
      end

      yield
    end
  end
end
