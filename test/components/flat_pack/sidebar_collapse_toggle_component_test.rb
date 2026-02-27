# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module CollapseToggle
      class ComponentTest < ViewComponent::TestCase
        def test_renders_collapse_state_labels
          render_inline(Component.new(collapsed: false))
          assert_selector "button[aria-label='Collapse sidebar'][aria-expanded='true']"

          render_inline(Component.new(collapsed: true))
          assert_selector "button[aria-label='Expand sidebar'][aria-expanded='false']"
        end

        def test_has_toggle_action_and_target
          render_inline(Component.new)

          assert_selector "button[data-flat-pack--sidebar-layout-target='desktopToggle']"
          assert_selector "button[data-action='click->flat-pack--sidebar-layout#toggleDesktop']"
        end

        def test_renders_icon
          render_inline(Component.new)

          assert_selector "button svg"
        end
      end
    end
  end
end
