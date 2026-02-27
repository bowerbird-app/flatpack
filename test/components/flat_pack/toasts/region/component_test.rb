# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toasts
    module Region
      class ComponentTest < ViewComponent::TestCase
        def test_renders_region_content
          render_inline(Component.new) { "Toast slot" }

          assert_text "Toast slot"
        end

        def test_sets_aria_live_attributes
          render_inline(Component.new)

          assert_selector "div[aria-live='polite'][aria-atomic='false']"
        end

        def test_uses_fixed_container_classes
          render_inline(Component.new)

          assert_selector "div.fixed.pointer-events-none"
          assert_includes page.native.to_html, "z-[60]"
        end
      end
    end
  end
end
