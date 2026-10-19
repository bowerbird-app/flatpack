# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class SidebarLayoutControllerTest < ActiveSupport::TestCase
    test "desktop collapse keeps labels in flow until width finishes" do
      test_file = FlatPack::Engine.root.join("test/javascript/sidebar_layout_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "collapsed icon tooltips follow the rail instead of sr-only" do
      test_file = FlatPack::Engine.root.join("test/javascript/tooltip_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "kit CSS fades sidebar labels without overlaying the hamburger" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/sidebar_layout_controller.js").read

      assert_includes css, ".fp-sidebar-label"
      assert_match(/opacity\s+var\(--duration-fast\)\s+var\(--easing-standard\)/, css)
      assert_includes css, "[data-flat-pack-sidebar-collapsed=\"true\"] .fp-sidebar-label"
      assert_includes css, "padding-left: var(--sidebar-item-padding-collapsed) !important"
      assert_includes css, "padding-left: 0 !important"
      assert_includes css, "gap: 0 !important"
      assert_includes css, "margin-left: calc((4rem - 1px - (var(--sidebar-item-inset) * 2) - 1.25rem) / 2 - var(--sidebar-item-padding-collapsed)) !important"
      assert_includes css, "[data-flat-pack-sidebar-floating=\"true\"]"
      assert_includes css, "margin-top: var(--sidebar-float-inset) !important;"
      assert_includes css, "margin-left: calc((4rem - 2px - (var(--sidebar-item-inset) * 2) - 1.25rem) / 2 - var(--sidebar-item-padding-collapsed)) !important"
      assert_includes css, "border-radius: var(--sidebar-float-radius);"
      assert_includes css, "[data-flat-pack-layout-background]"
      assert_includes css, "isolation: isolate;"
      assert_includes css, ".fp-layout-background"
      assert_includes css, "filter: blur(var(--layout-background-blur));"
      assert_includes css, "background-color: var(--layout-background-tint-color);"
      assert_includes css, "opacity: var(--layout-background-tint-opacity);"
      assert_includes css, "@media (prefers-reduced-transparency: reduce)"
      assert_includes css, ".fp-layout-background-media {\n    visibility: hidden;\n  }"
      assert_includes css, "@supports not ((filter: blur(1px)) or (-webkit-filter: blur(1px)))"
      assert_includes css, "--surface-page-background-color: transparent;"
      assert_includes css, "html[data-theme]:not([data-theme=\"rounded\"]) [data-flat-pack-sidebar-floating=\"true\"] aside"
      assert_includes css, "[data-flat-pack-top-nav-floating=\"behind\"]"
      assert_includes css, "[data-flat-pack-top-nav-floating=\"below\"]"
      assert_includes css, "padding-top: var(--top-nav-float-clearance);"
      assert_includes css, "scroll-padding-top: var(--top-nav-float-clearance);"
      assert_includes css, "background-color: var(--sidebar-float-background-color);"
      assert_includes css, "box-shadow: var(--sidebar-float-shadow);"
      assert_includes css, "border-radius: var(--sidebar-float-radius);"
      assert_includes css, "border-radius: var(--top-nav-float-radius);"
      assert_includes css, "overflow: visible;"
      assert_includes css, "padding-inline: max(0.25rem, min(0.75rem, calc(var(--top-nav-float-radius) - var(--sidebar-float-radius))));"
      assert_includes css, "[data-flat-pack-top-nav-section=\"right\"] > *"
      assert_includes css, "[data-flat-pack-top-nav-section=\"right\"] > [class*=\"--button-round-border-radius\"]"
      assert_includes css, "border-radius: var(--button-round-border-radius);"
      assert_includes css, "html[data-theme]:not([data-theme=\"rounded\"]) [data-flat-pack-top-nav-floating]"
      top_nav_float = css[/Floating top nav\..*?^\}/m]
      refute_nil top_nav_float
      refute_includes top_nav_float, "@media (min-width: 768px)"
      desktop_rail = css[/Sidebar layout:.*?\n  \}/m]
      refute_nil desktop_rail
      assert_includes desktop_rail, "@media (min-width: 768px)"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"]"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"]:not([data-flat-pack-sidebar-height=\"content\"])"
      assert_includes desktop_rail, "height: calc(100vh - (var(--sidebar-float-inset) * 2)) !important;"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"][data-flat-pack-sidebar-height=\"content\"]"
      assert_includes desktop_rail, "height: auto !important;"
      assert_includes desktop_rail, "max-height: calc(100vh - (var(--sidebar-float-inset) * 2)) !important;"
      refute_includes css.sub(desktop_rail, ""), "[data-flat-pack-sidebar-height=\"content\"]"
      refute_includes css, "margin-left: calc((100% - 1.25rem) / 2)"
      refute_includes css, "justify-content: center"
      refute_includes css, "desktopToggle"
      refute_includes controller, "delayContentReveal"
      refute_includes controller, "setDesktopExpandedContentVisible"
      refute_includes controller, "Align active navigation item to the top"
      refute_includes controller, "applyCollapsedRestState"
      refute_includes controller, "scheduleCollapsedRestState"
      assert_includes controller, "scheduleScrollRestore"
      assert_includes controller, "markItemCurrent"
      assert_includes controller, "isSectionTitleLabel"
    end
  end
end
