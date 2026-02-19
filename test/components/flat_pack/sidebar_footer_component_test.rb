# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Footer
      class ComponentTest < ViewComponent::TestCase
        def test_renders_footer_content
          render_inline(Component.new) { "Signed in as demo@flatpack.app" }

          assert_text "Signed in as demo@flatpack.app"
        end

        def test_renders_default_footer_classes
          render_inline(Component.new) { "Footer" }

          assert_selector "div.shrink-0.p-4.border-t"
          assert_includes page.native.to_html, "border-[var(--color-border)]"
          assert_selector "div[data-flat-pack--sidebar-layout-target='footer']"
        end

        def test_merges_custom_classes
          render_inline(Component.new(class: "text-sm text-[var(--color-text-muted)]")) { "Footer" }

          assert_includes page.native.to_html, "text-sm"
          assert_includes page.native.to_html, "text-[var(--color-text-muted)]"
        end
      end
    end
  end
end
