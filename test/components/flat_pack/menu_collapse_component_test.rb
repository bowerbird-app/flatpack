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

        def test_header_icon_uses_icon_options_without_a_colour
          render_inline(Component.new(title: "Share", icon: "pencil"))

          icon = page.find(".fp-menu-collapse__icon svg")
          chevron = page.find(".fp-menu-collapse__chevron svg")

          assert_includes icon[:class], "fp-button-icon"
          assert_equal "outline", icon["data-flat-pack--icon-variant-value"]
          assert_nil icon["data-icon-style"]
          refute_includes chevron[:class].to_s, "fp-button-icon"
          assert_nil chevron["data-icon-style"]
        end

        def test_header_icon_takes_variant_and_style
          render_inline(Component.new(
            title: "Publish",
            icon: "check-circle",
            icon_variant: :solid,
            icon_style: :success
          ))

          icon = page.find(".fp-menu-collapse__icon svg")

          assert_equal "solid", icon["data-flat-pack--icon-variant-value"]
          assert_equal "success", icon["data-icon-style"]
          assert_equal "check-circle", icon["data-flat-pack--icon-name-value"]
          assert_includes icon[:class], "fp-button-icon"
          assert_includes page.native.to_html, FlatPack::Button::IconOptions::STYLES.fetch(:success)
          chevron = page.find(".fp-menu-collapse__chevron svg")
          assert_nil chevron["data-icon-style"]
          refute_includes chevron[:class].to_s, "fp-button-icon"
        end

        def test_invalid_icon_variant_and_icon_style
          assert_raises(ArgumentError) { Component.new(title: "Share", icon_variant: :filled) }
          assert_raises(ArgumentError) { Component.new(title: "Share", icon_style: :info) }
        end
      end
    end
  end
end
