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
        trigger = page.find(".fp-button-group-menu__trigger")
        children = trigger.native.element_children
        assert_equal %w[span span], children.map(&:name)
        assert_equal "More", children.first.text
        assert_equal "chevron-down", children.last.at_css("svg")["data-flat-pack--icon-name-value"]
        assert_no_selector ".fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value='bars-3']"
        refute trigger["aria-label"]
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

        trigger = page.find(".fp-button-group-menu__trigger")
        assert_equal ["svg"], trigger_child_names(trigger)
        assert_equal "plus", trigger.find("svg")["data-flat-pack--icon-name-value"]
        assert_equal "Menu", trigger["aria-label"]
      end

      def test_menu_label_puts_an_explicit_icon_after_the_word
        render_inline(Component.new(collapse: :menu, menu_label: "View", menu_icon: :plus)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
        end

        trigger = page.find(".fp-button-group-menu__trigger")
        children = trigger.native.element_children
        assert_equal %w[span span], children.map(&:name)
        assert_equal "View", children.first.text
        assert_equal "plus", children.last.at_css("svg")["data-flat-pack--icon-name-value"]
        assert_no_selector ".fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value='chevron-down']"
        assert_no_selector ".fp-button-group-menu__trigger svg[data-flat-pack--icon-name-value='bars-3']"
        refute trigger["aria-label"]

        error = assert_raises(ArgumentError) { Component.new(menu_icon: true) }
        assert_equal "menu_icon must be a string", error.message
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
        assert_includes rendered_content, '.fp-button-group-menu[data-collapse-at="768"] > .fp-button-group-menu__row > .fp-button-dropdown'

        assert_selector ".fp-button-group-menu__row a.fp-button[href='/rename']", text: "Rename"
        assert_selector ".fp-button-group-menu__panel a.fp-menu-row[href='/rename']", text: "Rename"
        assert_selector ".fp-button-group-menu__panel a.fp-menu-row svg"
        assert_selector ".fp-button-group-menu__row #archive-button.fp-button[data-fp-style=danger]", text: "Archive"
        assert_selector ".fp-button-group-menu__panel .fp-menu-row[data-fp-style=danger]", text: "Archive", count: 1
        assert_no_selector ".fp-button-group-menu__panel #archive-button"

        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        refute_includes css, 'data-flat-pack--button-dropdown-target="trigger"'
        assert_includes css, ".fp-button-group:not(.fp-button-group--outlined) > .fp-button-dropdown > .fp-button-dropdown__trigger"
        assert_includes css, "border-radius: inherit"
        assert_includes css, ".fp-button-group:not(.fp-button-group--outlined) > .fp-button-dropdown:last-child > .fp-button-dropdown__trigger"
        assert_includes css, ".fp-button-group:not(.fp-button-group--outlined) > .fp-button-dropdown,\n.fp-button-group-menu__row:not(.fp-button-group--outlined) > .fp-button-dropdown {\n  border-width: 0;\n}"
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

      def test_visible_keeps_the_first_children_and_parks_the_rest
        render_inline(Component.new(visible: 2)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Share", style: :secondary, href: "/share"))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :danger))
        end

        assert_equal ["Rename", "Duplicate"], row_labels(".fp-button-group")
        assert_equal ["Share", "Archive"], overflow_labels
        trigger = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger")
        assert_equal "More", trigger["aria-label"]
        assert_equal ["svg"], trigger_child_names(trigger)
        assert_equal "ellipsis-horizontal", trigger.find("svg")["data-flat-pack--icon-name-value"]
        assert_no_selector ".fp-button-group__overflow > .fp-button-dropdown__trigger", text: "More"
        assert_selector ".fp-button-group__overflow .fp-menu-row[href='/share']", text: "Share"
        assert_selector ".fp-button-group__overflow .fp-menu-row[data-fp-style=danger]", text: "Archive"
        assert_no_selector ".fp-button-group > .fp-button", text: "Archive"
        assert_no_selector ".fp-button-group-menu"
      end

      def test_overflow_flag_beats_the_visible_count_and_keeps_order
        render_inline(Component.new(visible: 2, overflow_label: "Extras")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Delete", style: :danger), overflow: true)
          group.button(FlatPack::Button::Component.new(text: "Share", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary), overflow: false)
          group.button(FlatPack::Button::Component.new(text: "Move", style: :secondary))
        end

        assert_equal ["Rename", "Duplicate"], row_labels(".fp-button-group")
        assert_equal ["Delete", "Share", "Move"], overflow_labels
        trigger = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger")
        assert_equal ["span", "svg"], trigger_child_names(trigger)
        assert_equal "Extras", trigger.find("span").text
        assert_equal "chevron-down", trigger.find("svg")["data-flat-pack--icon-name-value"]
        assert_no_selector ".fp-button-group__overflow svg[data-flat-pack--icon-name-value='ellipsis-horizontal']"
        assert_selector ".fp-button-group__overflow .fp-menu-row[data-fp-style=danger]", text: "Delete"
        assert_no_selector ".fp-button-group > .fp-button", text: "Delete"
      end

      def test_overflow_true_without_a_count_still_opens_the_menu
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Delete", style: :danger), overflow: true)
        end

        assert_equal ["Rename"], row_labels(".fp-button-group")
        assert_equal ["Delete"], overflow_labels
        assert_no_selector ".fp-button-group__overflow", text: "Rename"
      end

      def test_a_full_row_has_no_overflow_menu
        render_inline(Component.new(visible: 4, overflow_label: "Extras")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary))
        end

        assert_equal ["Rename", "Duplicate"], row_labels(".fp-button-group")
        assert_no_selector ".fp-button-group__overflow"
        assert_no_text "Extras"
      end

      def test_collapse_menu_puts_every_child_in_the_phone_menu_once
        render_inline(Component.new(collapse: :menu, visible: 2)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Delete", style: :danger), overflow: true)
          group.button(FlatPack::Button::Dropdown::Component.new(text: "Share", style: :secondary, icon: "pencil")) do |dropdown|
            dropdown.menu_item(text: "Copy link", href: "/copy")
            dropdown.menu_item(text: "Remove", destructive: true)
          end
          group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary), overflow: false)
          group.button(ButtonGroupOverflowHost.new)
        end

        assert_equal ["Rename", "Duplicate"], row_labels(".fp-button-group-menu__row")
        assert_equal ["Delete", "Share", "Publish"], overflow_labels
        assert_no_selector ".fp-button-group-menu__row .fp-button-dropdown .fp-button-dropdown"
        assert_no_selector ".fp-button-group__overflow .fp-button-dropdown"
        assert_selector ".fp-button-group__overflow > .fp-menu-collapse", count: 0
        assert_selector ".fp-button-group__overflow .fp-menu-collapse", count: 1
        assert_selector ".fp-button-group__overflow .fp-menu-collapse__button", text: "Share"
        assert_selector ".fp-button-group__overflow .fp-menu-collapse__items a", text: "Copy link", visible: :all
        assert_selector ".fp-button-group__overflow .fp-menu-collapse__items button[data-fp-style='danger']", text: "Remove", visible: :all
        assert_selector ".fp-button-group__overflow .fp-menu-row[data-fp-style=danger]", text: "Delete"
        assert_selector ".fp-button-group__overflow .fp-menu-row[data-fp-style=danger]", text: "Publish"
        assert_no_selector "#publish-wide"

        assert_equal ["Rename", "Delete", "Share", "Duplicate", "Publish"], panel_labels
        assert_selector ".fp-button-group-menu__panel > .fp-menu-row", text: "Rename", count: 1
        assert_selector ".fp-button-group-menu__panel > .fp-menu-row[data-fp-style=danger]", text: "Delete", count: 1
        assert_selector ".fp-button-group-menu__panel > .fp-menu-collapse", count: 1
        assert_selector ".fp-button-group-menu__panel > .fp-menu-row", text: "Duplicate", count: 1
        assert_selector ".fp-button-group-menu__panel > .fp-menu-row[data-fp-style=danger]", text: "Publish", count: 1
        assert_no_selector ".fp-button-group-menu__panel .fp-button-group__overflow"
        assert_no_selector ".fp-button-group-menu__panel .fp-button-dropdown"
        assert_selector ".fp-button-group-menu__trigger", text: "Menu", count: 0
        assert_selector ".fp-button-group-menu__trigger[aria-label=Menu]", count: 1
      end

      def test_overflow_renders_a_child_without_menu_row_as_itself
        render_inline(Component.new(visible: 0, collapse: :menu)) do |group|
          group.button('<span class="raw-child">Raw</span>'.html_safe)
        end

        assert_selector ".fp-button-group-menu__row > .fp-button-group__overflow .raw-child", text: "Raw", count: 1
        assert_no_selector ".fp-button-group-menu__row > .raw-child"
        assert_selector ".fp-button-group-menu__panel > .raw-child", text: "Raw", count: 1
        assert_equal 2, page.all(".raw-child", visible: :all).size
      end

      def test_joined_is_the_default_and_keeps_the_merged_row
        render_inline(Component.new) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :secondary))
          group.button(FlatPack::Button::Component.new(text: "Share", style: :secondary))
        end

        group = page.find(".fp-button-group")
        assert_equal "joined", group["data-variant"]
        assert_includes group[:class], "[&>*]:rounded-none"
        assert_includes group[:class], "[&>*]:border-r-0"
        refute_includes group[:class], "fp-button-group--outlined"
      end

      def test_outlined_is_a_container_and_leaves_children_alone
        render_inline(Component.new(variant: :outlined)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Share", style: :ghost, size: :sm, href: "/share"))
        end

        group = page.find(".fp-button-group")
        assert_equal "outlined", group["data-variant"]
        assert_includes group[:class], "fp-button-group--outlined"
        assert_includes group[:class], "inline-flex"
        refute_includes group[:class], "[&>*]:rounded-none"
        refute_includes group[:class], "[&>*]:border-r-0"
        refute_includes group[:class], "shadow-sm"
        assert_selector ".fp-button-group--outlined > a.fp-button[data-fp-style=ghost][href='/share']", text: "Share"
        assert_includes page.find("a", text: "Share")[:class], "rounded-[var(--button-border-radius)]"

        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        outlined = [
          ".fp-button-group--outlined {",
          "  align-items: center;",
          "  gap: var(--space-1);",
          "  padding: var(--space-1);",
          "  border-width: 1px;",
          "  border-style: solid;",
          "  border-color: var(--fp-button-border);",
          "  border-radius: var(--button-group-radius);",
          "  background-color: var(--fp-button-background);",
          "  box-shadow: none;",
          "}"
        ].join("\n")
        assert_includes css, outlined
        refute_includes css, ".fp-button-group--outlined .fp-button"
        refute_includes css, ".fp-button-group--outlined > .fp-button"
      end

      def test_outlined_accepts_the_string_and_unknown_variants_raise
        render_inline(Component.new(variant: "outlined")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost))
        end

        assert_selector ".fp-button-group--outlined[data-variant=outlined][data-fp-style=default]"

        error = assert_raises(ArgumentError) { Component.new(variant: :stacked) }
        assert_equal "variant must be :joined or :outlined", error.message
        assert_raises(ArgumentError) { Component.new(variant: "") }
        assert_raises(ArgumentError) { Component.new(variant: true) }
      end

      def test_outlined_style_marks_the_container_and_leaves_each_child
        render_inline(Component.new(variant: :outlined, style: nil)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Keep", style: :default, size: :sm))
        end

        assert_equal "default", page.find(".fp-button-group--outlined")["data-fp-style"]
        assert_selector ".fp-button-group--outlined > .fp-button[data-fp-style=ghost]", text: "Edit"
        assert_selector ".fp-button-group--outlined > .fp-button[data-fp-style=default]", text: "Keep"

        render_inline(Component.new(variant: :outlined, style: "secondary")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Keep", style: :default, size: :sm))
        end

        assert_equal "secondary", page.find(".fp-button-group--outlined")["data-fp-style"]
        assert_selector ".fp-button-group--outlined > .fp-button[data-fp-style=ghost]", text: "Edit"
        assert_selector ".fp-button-group--outlined > .fp-button[data-fp-style=default]", text: "Keep"

        render_inline(Component.new(variant: :joined, style: :primary)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :secondary))
        end

        assert_nil page.find(".fp-button-group")["data-fp-style"]
        assert_selector ".fp-button[data-fp-style=secondary]", text: "Edit"

        render_inline(Component.new(variant: :outlined, collapse: :menu, style: :primary)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm, href: "/edit"))
        end

        assert_nil page.find(".fp-button-group-menu")["data-fp-style"]
        assert_equal "primary", page.find(".fp-button-group-menu__row.fp-button-group--outlined")["data-fp-style"]
        assert_nil page.find(".fp-button-group-menu__panel")["data-fp-style"]
        assert_selector ".fp-button-group-menu__row > a.fp-button[data-fp-style=ghost][href='/edit']", text: "Edit"

        error = assert_raises(ArgumentError) { Component.new(style: :stacked) }
        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:stacked), error.message
      end

      def test_overflow_trigger_is_ghost_when_outlined_and_secondary_when_joined
        render_inline(Component.new(variant: :outlined, visible: 1)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :ghost, size: :sm))
        end

        assert_selector ".fp-button-group--outlined > .fp-button[data-fp-style=ghost]", text: "Edit"
        assert_selector ".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=ghost][aria-label=More]"
        assert_no_selector ".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=secondary]"

        render_inline(Component.new(variant: :joined, visible: 1)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :secondary, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :secondary, size: :sm))
        end

        assert_selector ".fp-button-group:not(.fp-button-group--outlined) .fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=secondary][aria-label=More]"
        assert_no_selector ".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=ghost]"
      end

      def test_outlined_collapse_keeps_the_phone_menu_and_skips_joined_edges
        render_inline(Component.new(variant: :outlined, collapse: :menu, visible: 1)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm, href: "/edit"))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :ghost, size: :sm))
        end

        assert_selector ".fp-button-group-menu[data-variant=outlined]"
        assert_selector ".fp-button-group-menu__row.fp-button-group--outlined"
        assert_selector ".fp-button-group-menu__trigger[aria-label=Menu]"
        assert_selector ".fp-button-group-menu__panel .fp-menu-row[href='/edit']", text: "Edit"
        assert_selector ".fp-button-group-menu__panel .fp-menu-row", text: "Archive"
        assert_no_selector ".fp-button-group-menu__panel .fp-button-group__overflow"
        assert_selector ".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=ghost][aria-label=More]"
        refute_includes rendered_content, "border-radius: 0"
        refute_includes rendered_content, "border-right-width: 0"
        assert_includes rendered_content, "> .fp-button-group-menu__row {\n    display: inline-flex;\n  }"
      end

      def test_overflow_label_is_followed_by_the_chevron
        render_inline(Component.new(variant: :outlined, visible: 1, overflow_label: "More")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :ghost, size: :sm))
        end

        trigger = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=ghost]")
        assert_equal ["span", "svg"], trigger_child_names(trigger)
        assert_equal "More", trigger.find("span").text
        assert_equal "chevron-down", trigger.find("svg")["data-flat-pack--icon-name-value"]
        assert_equal "chevron", trigger.find("svg")["data-flat-pack--button-dropdown-target"]
        refute trigger["aria-label"]

        render_inline(Component.new(variant: :joined, visible: 1, overflow_label: " ")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :secondary, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Archive", style: :secondary, size: :sm))
        end

        blank = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger")
        assert_equal "More", blank["aria-label"]
        assert_equal ["svg"], trigger_child_names(blank)
      end

      def test_overflow_icon_replaces_the_default_in_both_modes
        render_inline(Component.new(variant: :outlined, visible: 1, overflow_icon: "archive")) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Share", style: :ghost, size: :sm))
        end

        icon_only = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=ghost]")
        assert_equal "More", icon_only["aria-label"]
        assert_equal ["svg"], trigger_child_names(icon_only)
        assert_equal "archive", icon_only.find("svg")["data-flat-pack--icon-name-value"]

        render_inline(Component.new(variant: :joined, visible: 1, overflow_label: "More", overflow_icon: :archive)) do |group|
          group.button(FlatPack::Button::Component.new(text: "Edit", style: :secondary, size: :sm))
          group.button(FlatPack::Button::Component.new(text: "Share", style: :secondary, size: :sm))
        end

        labeled = page.find(".fp-button-group__overflow > .fp-button-dropdown__trigger[data-fp-style=secondary]")
        assert_equal ["span", "svg"], trigger_child_names(labeled)
        assert_equal "More", labeled.find("span").text
        assert_equal "archive", labeled.find("svg")["data-flat-pack--icon-name-value"]
        assert_no_selector ".fp-button-group__overflow svg[data-flat-pack--icon-name-value='chevron-down']"
        assert_no_selector ".fp-button-group__overflow svg[data-flat-pack--icon-name-value='ellipsis-horizontal']"

        error = assert_raises(ArgumentError) { Component.new(overflow_icon: true) }
        assert_equal "overflow_icon must be a string", error.message
        assert_raises(ArgumentError) { Component.new(overflow_icon: 1) }
      end

      def test_invalid_visible_and_overflow_raise
        assert_raises(ArgumentError) { Component.new(visible: -1) }
        assert_raises(ArgumentError) { Component.new(visible: 1.5) }
        assert_raises(ArgumentError) { Component.new(visible: "2") }

        error = assert_raises(ArgumentError) do
          render_inline(Component.new(visible: 1)) do |group|
            group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary), overflow: "yes")
          end
        end
        assert_equal "overflow must be true or false", error.message
      end

      private

      def trigger_child_names(trigger)
        trigger.native.element_children.map(&:name)
      end

      def row_labels(row_selector)
        page.all("#{row_selector} > :not(.fp-button-group__overflow)", visible: :all).map { |node| entry_label(node) }
      end

      def overflow_labels
        page.all(".fp-button-group__overflow [data-flat-pack--button-dropdown-target='menu'] > *", visible: :all).map { |node| entry_label(node) }
      end

      def panel_labels
        page.all(".fp-button-group-menu__panel > *", visible: :all).map { |node| entry_label(node) }
      end

      def entry_label(node)
        return node.find(".fp-menu-collapse__button", visible: :all).text.squish if node[:class].to_s.split.include?("fp-menu-collapse")

        node.text.squish
      end
    end
  end
end

class ButtonGroupOverflowHost < ViewComponent::Base
  def call
    render(wide_button)
  end

  def menu_row
    wide_button.menu_row
  end

  private

  def wide_button
    @wide_button ||= FlatPack::Button::Component.new(text: "Publish", id: "publish-wide", style: :danger)
  end
end
