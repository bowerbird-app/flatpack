# frozen_string_literal: true

require "test_helper"

class PageActionHelperProbesController < ApplicationController
  def nominate
    helpers.page_action "New press kit", "/press-kits/new", role: :primary, icon: :plus
    helpers.page_action "Share", "/press-kits/share", role: :secondary
    helpers.page_action "Delete", "/press-kits/delete", role: :destructive
    labels = helpers.page_action_registry.actions.map { |action| "#{action.label}:#{action.role}" }
    render plain: labels.join(",")
  end

  def read
    labels = helpers.page_action_registry.actions.map(&:label)
    render plain: labels.join(",")
  end

  def render_header
    nominate_actions
    render inline: "<%= page_actions(:header) %>", layout: false
  end

  def render_override
    nominate_actions
    render inline: "<%= page_actions(:header, styles: { primary: :ghost }) %>", layout: false
  end

  def rejected_class
    helpers.page_action "New", "/new", class: "btn"
    head :ok
  end

  def rejected_style
    helpers.page_action "New", "/new", style: :primary
    head :ok
  end

  private

  def nominate_actions
    helpers.page_action "New press kit", "/press-kits/new", role: :primary, icon: :plus
    helpers.page_action "Share", "/press-kits/share", role: :secondary, icon: :share
    helpers.page_action "Delete", "/press-kits/delete", role: :destructive, icon: :trash
  end
end

class PageActionHelperTest < ActionDispatch::IntegrationTest
  test "each request has its own registry in source order" do
    with_page_action_routes do
      get "/demo/page_action_helper/nominate"

      assert_response :success
      assert_equal "New press kit:primary,Share:secondary,Delete:destructive", response.body

      get "/demo/page_action_helper/read"

      assert_response :success
      assert_equal "", response.body
    end
  end

  test "the helper renders the header map and an override" do
    with_page_action_routes do
      get "/demo/page_action_helper/render_header"

      assert_response :success
      assert_select "a[data-fp-style=primary]", text: "New press kit"
      assert_select "a[data-fp-style=secondary]", text: "Share"
      assert_select "a[data-fp-style=danger]", text: "Delete"

      get "/demo/page_action_helper/render_override"

      assert_select "a[data-fp-style=ghost]", text: "New press kit"
      assert_select "a[data-fp-style=secondary]", text: "Share"
    end
  end

  test "a view cannot pass a class or a button style" do
    with_page_action_routes do
      assert_raises(ArgumentError) { get "/demo/page_action_helper/rejected_class" }
      assert_raises(ArgumentError) { get "/demo/page_action_helper/rejected_style" }
    end
  end

  private

  def with_page_action_routes
    with_routing do |set|
      set.draw do
        get "/demo/page_action_helper/nominate", to: "page_action_helper_probes#nominate"
        get "/demo/page_action_helper/read", to: "page_action_helper_probes#read"
        get "/demo/page_action_helper/render_header", to: "page_action_helper_probes#render_header"
        get "/demo/page_action_helper/render_override", to: "page_action_helper_probes#render_override"
        get "/demo/page_action_helper/rejected_class", to: "page_action_helper_probes#rejected_class"
        get "/demo/page_action_helper/rejected_style", to: "page_action_helper_probes#rejected_style"
      end

      yield
    end
  end
end
