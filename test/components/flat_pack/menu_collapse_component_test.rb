# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Menu
    module Collapse
      class ComponentTest < ViewComponent::TestCase
        def test_renders_a_closed_section
          render_inline(Component.new(title: "Share")) do |section|
            section.items { %(<a href="/copy">Copy link</a>).html_safe }
          end

          assert_selector "[data-controller='flat-pack--menu-collapse']"
          assert_equal "false", page.find(".fp-menu-collapse")["data-open"]
          assert_equal "false", page.find(".fp-menu-collapse")["data-flat-pack--menu-collapse-open-value"]

          button = page.find(".fp-menu-collapse__button")
          panel = page.find(".fp-menu-collapse__panel", visible: :all)

          assert_equal "button", button["type"]
          assert_equal "Share", button.text
          assert_equal "false", button["aria-expanded"]
          assert_equal panel[:id], button["aria-controls"]
          assert_match(/\Amenu-collapse-/, panel[:id])
          assert_selector ".fp-menu-collapse__panel[hidden]", visible: :all
          assert_selector ".fp-menu-collapse__chevron", visible: :all
          assert_selector ".fp-menu-collapse__items a", text: "Copy link", visible: :all
          assert_selector "[data-action='click->flat-pack--menu-collapse#toggle']"
        end

        def test_renders_an_open_section_with_an_icon
          render_inline(Component.new(title: "Share", icon: "pencil", open: true)) do |section|
            section.items { "Child" }
          end

          button = page.find(".fp-menu-collapse__button")
          panel = page.find(".fp-menu-collapse__panel")

          assert_equal "true", page.find(".fp-menu-collapse")["data-open"]
          assert_equal "true", button["aria-expanded"]
          assert_nil panel["hidden"]
          assert_selector ".fp-menu-collapse__icon svg"
          assert_text "Child"
        end
      end
    end
  end
end
