# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Divider
      class ComponentTest < ViewComponent::TestCase
        def test_renders_divider
          render_inline(Component.new)

          assert_selector "div.h-px"
        end

        def test_applies_sidebar_divider_color_class
          render_inline(Component.new)

          assert_includes page.native.to_html, "bg-[var(--sidebar-divider-color)]"
        end

        def test_merges_custom_class
          render_inline(Component.new(class: "custom-divider"))

          assert_selector "div.custom-divider"
        end
      end
    end
  end
end
