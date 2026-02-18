# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Group
      class ComponentTest < ViewComponent::TestCase
        def test_renders_basic_group
          render_inline(Component.new(label: "More"))
          assert_selector "div[data-controller='flat-pack--sidebar-group']"
        end

        def test_renders_header_button
          render_inline(Component.new(label: "More"))
          assert_selector "button", text: "More"
        end

        def test_renders_with_icon
          render_inline(Component.new(label: "More", icon: :dots))
          assert_selector "button svg"
        end

        def test_renders_items_slot
          render_inline(Component.new(label: "More")) do |group|
            group.items do
              "Group items"
            end
          end
          assert_text "Group items"
        end

        def test_default_open_false
          render_inline(Component.new(label: "More", default_open: false))
          assert_selector "button[aria-expanded='false']"
        end

        def test_default_open_true
          render_inline(Component.new(label: "More", default_open: true))
          assert_selector "button[aria-expanded='true']"
        end

        def test_collapsed_mode_hides_label
          render_inline(Component.new(label: "More", collapsed: true))
          assert_selector "span.sr-only", text: "More"
        end

        def test_has_chevron_icon
          render_inline(Component.new(label: "More"))
          assert_selector "span[data-flat-pack--sidebar-group-target='chevron']"
        end

        def test_panel_has_correct_id
          component = Component.new(label: "More")
          render_inline(component) do |group|
            group.items { "Items" }
          end
          
          # Panel should have ID matching aria-controls
          button = page.find("button")
          panel_id = button["aria-controls"]
          assert panel_id.present?
          assert_selector "div##{panel_id}"
        end

        def test_panel_has_target
          render_inline(Component.new(label: "More")) do |group|
            group.items { "Items" }
          end
          assert_selector "div[data-flat-pack--sidebar-group-target='panel']"
        end

        def test_button_has_target
          render_inline(Component.new(label: "More"))
          assert_selector "button[data-flat-pack--sidebar-group-target='button']"
        end

        def test_button_has_action
          render_inline(Component.new(label: "More"))
          assert_selector "button[data-action='click->flat-pack--sidebar-group#toggle']"
        end

        def test_aria_controls_attribute
          render_inline(Component.new(label: "More")) do |group|
            group.items { "Items" }
          end
          assert_selector "button[aria-controls]"
        end

        def test_merges_custom_classes
          render_inline(Component.new(label: "More", class: "custom-group"))
          assert_includes page.native.to_html, "custom-group"
        end
      end
    end
  end
end
