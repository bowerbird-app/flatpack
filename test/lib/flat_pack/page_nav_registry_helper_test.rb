# frozen_string_literal: true

require "test_helper"

class PageNavRegistryHelperProbesController < ApplicationController
  def nominate
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus
    helpers.register_page_nav "Share", "/press-kits/share", role: :secondary, into: :title
    helpers.register_page_nav "Delete", "/press-kits/delete", role: :destructive
    helpers.register_page_nav component: PublishableQuickActionsComponent.new, role: :secondary, into: "title"
    default_labels = helpers.page_nav_items.map { |item| "#{item.label}:#{item.role}" }
    title_labels = helpers.page_nav_items(from: :title).map { |item| item.component? ? "component" : item.label }
    render plain: "default=#{default_labels.join(",")};title=#{title_labels.join(",")}"
  end

  def read
    labels = helpers.page_nav_items.map(&:label)
    render plain: labels.join(",")
  end

  def render_title
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus, into: :title
    helpers.register_page_nav "Share", "/press-kits/share", role: :secondary, into: :title
    styles = {
      primary: {style: :ghost, size: :md},
      secondary: {style: :secondary, size: :sm},
      destructive: {style: :danger, size: :sm}
    }
    @buttons = helpers.page_nav_items(from: :title).map do |item|
      FlatPack::PageNavRoleStyles.button_for(item, styles: styles)
    end
    render inline: <<~ERB, layout: false
      <%= render FlatPack::ButtonGroup::Component.new(collapse: :menu, menu_label: "Actions") do |group| %>
        <% @buttons.each do |button| %>
          <% group.button button %>
        <% end %>
      <% end %>
    ERB
  end

  def rejected_class
    helpers.register_page_nav "New", "/new", role: :primary, class: "btn"
    head :ok
  end

  def rejected_style
    helpers.register_page_nav "New", "/new", role: :primary, style: :primary
    head :ok
  end

  def rejected_role
    helpers.register_page_nav "New", "/new"
    head :ok
  end

  def rejected_component_label
    helpers.register_page_nav "New", "/new", component: PublishableQuickActionsComponent.new, role: :primary
    head :ok
  end

  def rejected_bucket
    helpers.register_page_nav "New", "/new", role: :primary, into: ""
    head :ok
  end

  def render_group
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus, data: {controller: "press-kit"}, aria: {label: "Create a press kit"}
    helpers.register_page_nav "Share", "/press-kits/share", role: :secondary
    helpers.register_page_nav "Delete", "/press-kits/delete", role: :destructive
    helpers.register_page_nav component: PublishableQuickActionsComponent.new, role: :secondary
    helpers.register_page_nav "Notes", "/notes", role: :secondary, into: :notes
    render inline: "<%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::QUIET, collapse: :menu) %>", layout: false
  end

  def render_solid
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary
    helpers.register_page_nav "Share", "/press-kits/share", role: :secondary
    render inline: "<%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::SOLID, collapse: :menu) %>", layout: false
  end

  def render_plain
    helpers.register_page_nav "Share", "/press-kits/share", role: :secondary
    helpers.register_page_nav "Delete", "/press-kits/delete", role: :destructive
    render inline: "<%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::QUIET) %>", layout: false
  end

  def render_bucket
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary
    helpers.register_page_nav "Notes", "/notes", role: :secondary, into: :notes
    render inline: "<%= page_nav_button_group(from: :notes, styles: FlatPack::PageNavRoleStyles::QUIET) %>", layout: false
  end

  def render_empty
    html = helpers.page_nav_button_group(styles: FlatPack::PageNavRoleStyles::SOLID, collapse: :menu)
    render plain: html.to_s
  end

  def render_missing_role
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary
    helpers.page_nav_button_group(styles: {secondary: {style: :secondary, size: :sm}})
    head :ok
  end

  def render_bad_collapse
    helpers.register_page_nav "New press kit", "/press-kits/new", role: :primary
    helpers.page_nav_button_group(styles: FlatPack::PageNavRoleStyles::SOLID, collapse: :overflow)
    head :ok
  end
end

class PageNavRegistryHelperTest < ActionDispatch::IntegrationTest
  test "each request has its own registry in source order" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/nominate"

      assert_response :success
      assert_equal "default=New press kit:primary,Delete:destructive;title=Share,component", response.body

      get "/demo/page_nav_registry_helper/read"

      assert_response :success
      assert_equal "", response.body
    end
  end

  test "a view renders a bucket with its own role map" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_title"

      assert_response :success
      assert_select ".fp-button-group-menu a[data-fp-style=ghost]", text: "New press kit"
      assert_select ".fp-button-group-menu a.text-sm[data-fp-style=ghost]", text: "New press kit"
      assert_select ".fp-button-group-menu a[data-fp-style=secondary]", text: "Share"
      assert_select ".fp-button-group-menu__row a", count: 2
      assert_select ".fp-button-group-menu__panel .fp-menu-row", count: 2
      assert_select "button", text: "Actions"
    end
  end

  test "register_page_nav records data and the old renderer is gone" do
    refute_includes FlatPack::PageNavRegistryHelper.instance_methods, :render_page_nav
    refute_respond_to FlatPack.configuration, :page_nav_styles
  end

  test "page_nav_button_group renders the bucket in order with the role map" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_group"

      assert_response :success
      assert_select ".fp-button-group-menu a[href='/press-kits/new'][data-fp-style=secondary][data-controller=press-kit][aria-label='Create a press kit']", text: "New press kit"
      assert_select ".fp-button-group-menu a[href='/press-kits/share'][data-fp-style=secondary]", text: "Share"
      assert_select ".fp-button-group-menu a[href='/press-kits/delete'][data-fp-style=danger]", text: "Delete"
      assert_select ".fp-button-group-menu__row a", count: 3
      assert_select ".fp-button-group-menu__row #publishable_quick_actions_demo", text: "Publish", count: 1
      assert_select ".fp-button-group-menu__panel .fp-menu-row", count: 4
      assert_select ".fp-button-group-menu__panel #publishable_quick_actions_demo", count: 0
      assert_select ".fp-button-group-menu__trigger[aria-label=Menu]"
      assert_select "a", text: "Notes", count: 0
      assert_equal ["New press kit", "Share", "Delete", "Publish"], group_labels
    end
  end

  test "page_nav_button_group uses the styles map and passes collapse through" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_solid"

      assert_select ".fp-button-group-menu a[data-fp-style=primary]", text: "New press kit"
      assert_select ".fp-button-group-menu a[data-fp-style=secondary]", text: "Share"
      assert_select ".fp-button-group-menu__panel .fp-menu-row", count: 2

      get "/demo/page_nav_registry_helper/render_plain"

      assert_select ".fp-button-group > a", count: 2
      assert_select ".fp-button-group-menu", count: 0
      assert_equal ["Share", "Delete"], css_select(".fp-button-group > a").map { |node| node.text.squish }
    end
  end

  test "page_nav_button_group reads the named bucket and returns nothing when it is empty" do
    with_page_nav_routes do
      get "/demo/page_nav_registry_helper/render_bucket"

      assert_select "a", text: "Notes"
      assert_select "a", text: "New press kit", count: 0

      get "/demo/page_nav_registry_helper/render_empty"

      assert_response :success
      assert_equal "", response.body
    end
  end

  test "page_nav_button_group raises when the map misses a role or collapse is unknown" do
    with_page_nav_routes do
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/render_missing_role" }
      error = assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/render_bad_collapse" }
      assert_match(/collapse must be false or :menu/, error.message)
    end
  end

  test "a view cannot pass a class, a button style, a missing role, a label with a component, or a blank bucket" do
    with_page_nav_routes do
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_class" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_style" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_role" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_component_label" }
      assert_raises(ArgumentError) { get "/demo/page_nav_registry_helper/rejected_bucket" }
    end
  end

  private

  def group_labels
    panel = css_select(".fp-button-group-menu__panel").first
    panel.css("> *").map { |node| node.text.squish }
  end

  def with_page_nav_routes
    with_routing do |set|
      set.draw do
        get "/demo/page_nav_registry_helper/nominate", to: "page_nav_registry_helper_probes#nominate"
        get "/demo/page_nav_registry_helper/read", to: "page_nav_registry_helper_probes#read"
        get "/demo/page_nav_registry_helper/render_title", to: "page_nav_registry_helper_probes#render_title"
        get "/demo/page_nav_registry_helper/rejected_class", to: "page_nav_registry_helper_probes#rejected_class"
        get "/demo/page_nav_registry_helper/rejected_style", to: "page_nav_registry_helper_probes#rejected_style"
        get "/demo/page_nav_registry_helper/rejected_role", to: "page_nav_registry_helper_probes#rejected_role"
        get "/demo/page_nav_registry_helper/rejected_component_label", to: "page_nav_registry_helper_probes#rejected_component_label"
        get "/demo/page_nav_registry_helper/rejected_bucket", to: "page_nav_registry_helper_probes#rejected_bucket"
        get "/demo/page_nav_registry_helper/render_group", to: "page_nav_registry_helper_probes#render_group"
        get "/demo/page_nav_registry_helper/render_solid", to: "page_nav_registry_helper_probes#render_solid"
        get "/demo/page_nav_registry_helper/render_plain", to: "page_nav_registry_helper_probes#render_plain"
        get "/demo/page_nav_registry_helper/render_bucket", to: "page_nav_registry_helper_probes#render_bucket"
        get "/demo/page_nav_registry_helper/render_empty", to: "page_nav_registry_helper_probes#render_empty"
        get "/demo/page_nav_registry_helper/render_missing_role", to: "page_nav_registry_helper_probes#render_missing_role"
        get "/demo/page_nav_registry_helper/render_bad_collapse", to: "page_nav_registry_helper_probes#render_bad_collapse"
      end

      yield
    end
  end
end
