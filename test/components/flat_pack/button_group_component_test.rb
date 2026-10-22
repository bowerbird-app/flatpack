# frozen_string_literal: true

require "test_helper"
require "open3"

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
        assert_selector ".fp-button-group-menu__row", count: 1
        assert_selector ".fp-button-group-menu__panel", count: 1
        assert_selector ".fp-button-group-menu__row .fp-button", text: "Rename", count: 1
        assert_selector ".fp-button-group-menu__row .fp-button", text: "Archive", count: 1
        assert_selector ".fp-button-group-menu__panel .fp-menu-row", text: "Rename", count: 1
        assert_selector ".fp-button-group-menu__panel .fp-menu-row[data-fp-style=danger]", text: "Archive", count: 1
        assert_no_selector ".fp-button-group-menu__panel .fp-button"
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

      def test_wide_row_styles_direct_children_only
        render_inline(Component.new(collapse: :menu)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary, href: "/rename", icon: "pencil"))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :danger, id: "archive-button"))
        end

        refute_includes rendered_content, "button-dropdown-target"
        assert_includes rendered_content, '.fp-button-group-menu[data-collapse-at="768"] > .fp-button-group-menu__row > *'
        assert_includes rendered_content, '.fp-button-group-menu[data-collapse-at="768"] > .fp-button-group-menu__row > :first-child'
        assert_includes rendered_content, '.fp-button-group-menu[data-collapse-at="768"] > .fp-button-group-menu__row > :last-child'

        assert_selector ".fp-button-group-menu__row a.fp-button[href='/rename']", text: "Rename"
        assert_selector ".fp-button-group-menu__panel a.fp-menu-row[href='/rename']", text: "Rename"
        assert_selector ".fp-button-group-menu__panel a.fp-menu-row svg"
        assert_selector ".fp-button-group-menu__row #archive-button.fp-button[data-fp-style=danger]", text: "Archive"
        assert_selector ".fp-button-group-menu__panel .fp-menu-row[data-fp-style=danger]", text: "Archive", count: 1
        assert_no_selector ".fp-button-group-menu__panel #archive-button"

        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        refute_includes css, 'data-flat-pack--button-dropdown-target="trigger"'
        assert_includes css, ".fp-button-group > .fp-button-dropdown > .fp-button-dropdown__trigger"
        assert_includes css, "border-radius: inherit"
      end

      def test_plain_group_joins_a_dropdown_on_its_root
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Dropdown::Component.new(text: "Share", style: :secondary)) do |dropdown|
            dropdown.menu_item(text: "Copy link", href: "#")
          end
        end

        assert_selector ".fp-button-group > .fp-button-dropdown", count: 1
        assert_selector ".fp-button-group > .fp-button-dropdown > .fp-button-dropdown__trigger", text: "Share"
        assert_no_selector ".fp-menu-collapse"
        assert_no_selector ".fp-button-group-menu"

        render_inline(FlatPack::Button::Dropdown::Component.new(text: "Share", style: :secondary)) do |dropdown|
          dropdown.menu_item(text: "Copy link", href: "#")
        end

        assert_selector ".fp-button-dropdown", count: 1
        assert_no_selector ".fp-button-group"
        assert_no_selector ".fp-menu-collapse"
      end

      def test_plain_group_does_not_restyle_a_wrapped_dropdown
        render_inline(Component.new) do |group|
          group.button('<div class="host-wrap"><button type="button" class="inner">Share</button></div>'.html_safe)
        end

        assert_selector ".fp-button-group > .host-wrap > .inner", text: "Share"
        refute_includes rendered_content, "button-dropdown-target"
      end

      def test_collapse_menu_renders_a_dropdown_as_its_own_menu_row
        render_inline(Component.new(collapse: :menu, menu_label: "More")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Dropdown::Component.new(text: "Share", style: :secondary, icon: "pencil")) do |dropdown|
            dropdown.menu_item(text: "Copy link", href: "/copy", icon: "pencil")
            dropdown.menu_divider
            dropdown.menu_item(text: "Remove", destructive: true)
          end
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :danger))
        end

        assert_selector ".fp-button-group-menu__row .fp-button-dropdown", count: 1
        assert_selector ".fp-button-group-menu__row .fp-button-dropdown__trigger", text: "Share"
        assert_no_selector ".fp-button-group-menu__panel .fp-button-dropdown"
        assert_no_selector ".fp-button-group-menu__dropdown"
        assert_no_selector ".fp-button-group-menu__inline"
        assert_selector ".fp-button-group-menu__panel > .fp-menu-collapse", count: 1
        assert_selector ".fp-menu-collapse__button", text: "Share"
        assert_equal "false", page.find(".fp-menu-collapse__button")["aria-expanded"]
        assert_selector ".fp-menu-collapse__items a", text: "Copy link", visible: :all
        assert_selector ".fp-menu-collapse__items a svg", visible: :all
        assert_selector ".fp-menu-collapse__divider[role='separator']", visible: :all
        assert_selector ".fp-menu-collapse__items button[data-fp-style='danger']", text: "Remove", visible: :all
        refute_match(/display:\s*contents/, rendered_content)
      end

      def test_collapse_menu_repeats_a_child_without_menu_row
        render_inline(Component.new(collapse: :menu)) do |group|
          group.button('<span class="raw-child">Raw</span>'.html_safe)
        end

        assert_selector ".fp-button-group-menu__row > .raw-child", text: "Raw", count: 1
        assert_selector ".fp-button-group-menu__panel > .raw-child", text: "Raw", count: 1
        assert_no_selector ".fp-menu-row"
        assert_no_selector ".fp-menu-collapse"
      end

      def test_plain_group_leaves_a_dropdown_floating
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Dropdown::Component.new(text: "Share", style: :secondary)) do |dropdown|
            dropdown.menu_item(text: "Copy link", href: "/copy")
          end
        end

        assert_selector "[data-controller='flat-pack--button-dropdown']", count: 1
        assert_no_selector ".fp-menu-collapse"
        assert_no_selector ".fp-button-group-menu__inline"
      end

      def test_portaled_child_dropdown_menu_is_not_an_outside_click
        test_file = FlatPack::Engine.root.join("test/javascript/button_group_menu_controller_test.js")
        stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

        assert status.success?, stdout
      end
    end
  end
end
