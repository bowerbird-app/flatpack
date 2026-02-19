# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Header
      class ComponentTest < ViewComponent::TestCase
        def test_renders_default_header_structure
          render_inline(Component.new)

          assert_text "FP"
          assert_text "FlatPack"
          assert_no_text "Workspace"
          assert_selector "div.flex.items-center.gap-3"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerBrand']"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel']"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'].flex.items-center.h-8"
          assert_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          assert_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
          assert_selector "[data-flat-pack--sidebar-layout-target='desktopToggle'][data-action='click->flat-pack--sidebar-layout#toggleDesktop click->flat-pack--sidebar-layout#toggleMobile']"
        end

        def test_renders_custom_brand_values
          render_inline(Component.new(brand_abbr: "AC", title: "Acme", subtitle: "Dummy App"))

          assert_text "AC"
          assert_text "Acme"
          assert_no_text "Dummy App"
        end

        def test_hides_toggle_buttons_when_not_collapsible
          render_inline(Component.new(collapsible: false))

          assert_no_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
        end

        def test_hides_brand_badge_when_brand_abbr_is_blank
          render_inline(Component.new(brand_abbr: nil, title: "Menu", subtitle: nil, collapsible: false))

          assert_text "Menu"
          assert_no_text "FP"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='headerBrand'] > .w-8.h-8"
        end

        def test_hides_subtitle_when_blank
          render_inline(Component.new(subtitle: nil))

          assert_no_text "Workspace"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > div", count: 1
        end

        def test_does_not_render_subtitle_even_when_provided
          render_inline(Component.new(subtitle: "Workspace"))

          assert_no_text "Workspace"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > div", count: 1
        end
      end
    end
  end
end
