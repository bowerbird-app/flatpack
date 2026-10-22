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
      assert_select ".fp-button-group-menu a", count: 2
      assert_select "button", text: "Actions"
    end
  end

  test "the helper records data and does not render" do
    refute_includes FlatPack::PageNavRegistryHelper.instance_methods, :render_page_nav
    refute_respond_to FlatPack.configuration, :page_nav_styles
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
      end

      yield
    end
  end
end
