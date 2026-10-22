# frozen_string_literal: true

require "test_helper"

class PageNavRegistryHelperProbesController < ApplicationController
  def nominate
    helpers.page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus
    helpers.page_nav "Share", "/press-kits/share", role: :secondary
    helpers.page_nav "Delete", "/press-kits/delete", role: :destructive
    labels = helpers.page_nav_registry.items.map { |item| "#{item.label}:#{item.role}" }
    render plain: labels.join(",")
  end

  def read
    labels = helpers.page_nav_registry.items.map(&:label)
    render plain: labels.join(",")
  end

  def render_header
    nominate_items
    render inline: "<%= render_page_nav(:header) %>", layout: false
  end

  def render_override
    nominate_items
    render inline: "<%= render_page_nav(:header, styles: { header: { primary: { style: :ghost } } }) %>", layout: false
  end

  def render_inline_twice
    helpers.page_nav "New press kit", "/press-kits/new", role: :primary
    helpers.page_nav component: PublishableQuickActionsComponent.new(dom_id: "publishable_quick_actions_late"), role: :destructive
    helpers.page_nav component: PublishableQuickActionsComponent.new(dom_id: "publishable_quick_actions_early"), role: :primary
    render inline: "<%= render_page_nav(:header) %><%= render_page_nav(:top_nav, place: :menu) %><%= render_page_nav(:header) %>", layout: false
  end

  def rejected_class
    helpers.page_nav "New", "/new", role: :primary, class: "btn"
    head :ok
  end

  def rejected_style
    helpers.page_nav "New", "/new", role: :primary, style: :primary
    head :ok
  end

  def rejected_role
    helpers.page_nav "New", "/new"
    head :ok
  end

  def rejected_component_label
    helpers.page_nav "New", "/new", component: PublishableQuickActionsComponent.new, role: :primary
    head :ok
  end

  private

  def nominate_items
    helpers.page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus
    helpers.page_nav "Share", "/press-kits/share", role: :secondary, icon: :share
    helpers.page_nav "Delete", "/press-kits/delete", role: :destructive, icon: :trash
  end
end

class PageNavRegistryHelperTest < ActionDispatch::IntegrationTest
  setup do
    @previous_styles = FlatPack.configuration.page_nav_styles
  end

  teardown do
    FlatPack.configuration.page_nav_styles = @previous_styles
  end

  test "each request has its own registry in source order" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/nominate"

      assert_response :success
      assert_equal "New press kit:primary,Share:secondary,Delete:destructive", response.body

      get "/demo/page_nav_registry_helper/read"

      assert_response :success
      assert_equal "", response.body
    end
  end

  test "the helper renders the header map and a layout override" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_header"

      assert_response :success
      assert_select "a[data-fp-style=primary]", text: "New press kit"
      assert_select "a[data-fp-style=secondary]", text: "Share"
      assert_select "a[data-fp-style=danger]", text: "Delete"

      get "/demo/page_nav_registry_helper/render_override"

      assert_select "a[data-fp-style=ghost]", text: "New press kit"
      assert_select "a[data-fp-style=secondary]", text: "Share"
    end
  end

  test "the host map changes the rendered button" do
    FlatPack.configuration.page_nav_styles = {
      header: {primary: {style: :ghost, size: :md}}
    }

    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_header"

      assert_select "a.text-sm[data-fp-style=ghost]", text: "New press kit"
      assert_select "a[data-fp-style=secondary]", text: "Share"
    end
  end

  test "an inline render shows a component once and leaves it out of the menu" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_inline_twice"

      assert_response :success
      assert_select "#publishable_quick_actions_early", count: 1
      assert_select "#publishable_quick_actions_late", count: 1
      assert_select "[data-fp-page-nav=menu] #publishable_quick_actions_early", count: 0
      assert_select "[data-fp-page-nav=menu] a", text: "New press kit"
      assert_operator response.body.index("publishable_quick_actions_early"), :<, response.body.index("publishable_quick_actions_late")
    end
  end

  test "a view cannot pass a class, a button style, a missing role, or a label with a component" do
    with_page_nav_routes do
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_class" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_style" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_role" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_component_label" }
    end
  end

  private

  def with_page_nav_routes
    with_routing do |set|
      set.draw do
        get "/demo/page_nav_registry_helper/nominate", to: "page_nav_registry_helper_probes#nominate"
        get "/demo/page_nav_registry_helper/read", to: "page_nav_registry_helper_probes#read"
        get "/demo/page_nav_registry_helper/render_header", to: "page_nav_registry_helper_probes#render_header"
        get "/demo/page_nav_registry_helper/render_override", to: "page_nav_registry_helper_probes#render_override"
        get "/demo/page_nav_registry_helper/render_inline_twice", to: "page_nav_registry_helper_probes#render_inline_twice"
        get "/demo/page_nav_registry_helper/rejected_class", to: "page_nav_registry_helper_probes#rejected_class"
        get "/demo/page_nav_registry_helper/rejected_style", to: "page_nav_registry_helper_probes#rejected_style"
        get "/demo/page_nav_registry_helper/rejected_role", to: "page_nav_registry_helper_probes#rejected_role"
        get "/demo/page_nav_registry_helper/rejected_component_label", to: "page_nav_registry_helper_probes#rejected_component_label"
      end

      yield
    end
  end
end
