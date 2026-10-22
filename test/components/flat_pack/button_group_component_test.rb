# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ButtonGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_group
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Component.new(text: "Left", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Right", style: :secondary))
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 2
      end

      def test_applies_group_classes
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Component.new(text: "Button", style: :secondary))
        end

        assert_selector "div.inline-flex"
      end

      def test_collapse_false_is_the_joined_row
        render_inline(Component.new(collapse: false, menu_label: "More")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Left", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Right", style: :secondary))
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 2
        assert_no_selector ".fp-button-group-menu"
        assert_no_text "More"
      end

      def test_collapse_menu_renders_the_trigger_and_each_button_once
        render_inline(Component.new(collapse: :menu, menu_label: "More")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :danger))
        end

        assert_selector ".fp-button-group-menu__trigger", count: 1
        assert_selector ".fp-button-group-menu__panel", count: 1
        assert_selector ".fp-button-group-menu__panel button", count: 2
        assert_selector "button", text: "Rename", count: 1
        assert_selector "button", text: "Archive", count: 1
        assert_selector "button", text: "More", count: 1
        assert_selector ".fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value='bars-3']"
        assert_equal "false", page.find(".fp-button-group-menu")["data-open"]
      end

      def test_collapse_menu_wires_aria
        render_inline(Component.new(collapse: :menu)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
        end

        trigger = page.find(".fp-button-group-menu__trigger")
        panel = page.find(".fp-button-group-menu__panel")

        assert_equal "false", trigger["aria-expanded"]
        assert_equal "true", trigger["aria-haspopup"]
        assert_equal panel[:id], trigger["aria-controls"]
        assert_equal "Menu", trigger["aria-label"]
        assert_equal "group", panel["role"]
        assert_equal "Menu", panel["aria-label"]
        assert_match(/\Abutton-group-menu-/, panel[:id])
      end

      def test_collapse_at_sets_the_breakpoint
        render_inline(Component.new(collapse: :menu, collapse_at: 900)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
        end

        assert_selector ".fp-button-group-menu[data-collapse-at='900']"
        assert_includes rendered_content, "@media (min-width: 900px)"
        assert_includes rendered_content, '.fp-button-group-menu[data-collapse-at="900"] > .fp-button-group-menu__trigger'
      end

      def test_menu_icon_overrides_the_hamburger
        render_inline(Component.new(collapse: :menu, menu_icon: "plus")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
        end

        assert_selector ".fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value='plus']"
      end

      def test_collapse_menu_keeps_a_caller_controller
        render_inline(Component.new(collapse: :menu, data: {controller: "segmented-buttons-demo"})) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
        end

        controllers = page.find(".fp-button-group-menu")["data-controller"]
        assert_includes controllers, "flat-pack--button-group-menu"
        assert_includes controllers, "segmented-buttons-demo"
      end

      def test_invalid_collapse_raises
        error = assert_raises(ArgumentError) { Component.new(collapse: :drawer) }
        assert_equal "collapse must be false or :menu", error.message
        assert_raises(ArgumentError) { Component.new(collapse: true) }
      end

      def test_invalid_collapse_at_raises
        assert_raises(ArgumentError) { Component.new(collapse: :menu, collapse_at: 0) }
        assert_raises(ArgumentError) { Component.new(collapse: :menu, collapse_at: "768px") }
      end
    end
  end
end
