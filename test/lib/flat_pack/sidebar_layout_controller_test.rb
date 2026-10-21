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
      assert_includes css, "[data-flat-pack-sidebar-collapsed=\"true\"] .fp-sidebar .fp-sidebar-label"
      assert_includes css, ".fp-sidebar[data-flat-pack-sidebar-collapsed=\"true\"] .fp-sidebar-label"
      assert_includes css, "padding-left: var(--sidebar-item-padding-collapsed) !important"
      assert_includes css, "padding-left: 0 !important"
      assert_includes css, "gap: 0 !important"
      assert_includes css, "margin-left: calc((var(--sidebar-collapsed-width) - var(--sidebar-collapsed-frame, 1px) - (var(--sidebar-item-inset) * 2) - 1.25rem) / 2 - var(--sidebar-item-padding-collapsed)) !important"
      assert_includes css, ".fp-sidebar[data-flat-pack-sidebar-collapsed=\"true\"] [data-flat-pack-sidebar-item=\"true\"] > [data-flat-pack-sidebar-item-icon=\"true\"]"
      refute_includes css, "[data-flat-pack-sidebar-floating=\"true\"][data-flat-pack-sidebar-collapsed=\"true\"] [data-flat-pack-sidebar-item=\"true\"]"
      assert_includes css, "[data-flat-pack-sidebar-floating=\"true\"]"
      assert_includes css, "margin-top: var(--sidebar-float-inset) !important;"
      assert_includes css, "margin-left: var(--sidebar-float-inset) !important;"
      assert_includes css, "margin-right: var(--sidebar-float-inset) !important;"
      assert_includes css, "border-radius: var(--sidebar-float-radius);"
      assert_includes css, "[data-flat-pack-layout-background]"
      assert_includes css, "isolation: isolate;"
      assert_includes css, ".fp-backdrop"
      assert_includes css, "[data-flat-pack-layout-background] > .fp-backdrop"
      assert_includes css, "position: fixed;"
      assert_includes css, "filter: blur(var(--backdrop-blur)) var(--backdrop-filter);"
      assert_includes css, "background-color: var(--backdrop-tint-color);"
      assert_includes css, "opacity: var(--backdrop-tint-opacity);"
      assert_includes css, "@media (prefers-reduced-transparency: reduce)"
      assert_includes css, ".fp-backdrop-media {\n    visibility: hidden;\n  }"
      assert_includes css, "@supports not ((filter: blur(1px)) or (-webkit-filter: blur(1px)))"
      refute_includes css, ".fp-layout-background"
      refute_includes css, "--layout-background-"
      assert_includes css, "--surface-page-background-color: transparent;"
      assert_includes css, "html[data-theme]:not([data-theme~=\"rounded\"]) [data-flat-pack-sidebar-floating=\"true\"]"
      refute_includes css, "[data-flat-pack-sidebar-floating=\"true\"] aside"
      assert_includes css, ".fp-sidebar-drawer[data-flat-pack-sidebar-floating=\"true\"] > :not(script):not(.fp-panel-resize)"
      assert_includes css, "[data-flat-pack-sidebar-floating=\"true\"] > .fp-panel-resize::after"
      assert_includes css, "content: none;"
      assert_includes css, "[data-flat-pack-panel-dragging=\"true\"]"
      assert_includes css, "border-color: var(--resize-handle-active-color) !important;"
      assert_includes css, "right: calc(-0.25rem - 1px);"
      assert_includes css, "left: calc(-0.25rem - 1px);"
      assert_includes css, "[data-flat-pack-top-nav-floating=\"behind\"]"
      assert_includes css, ".fp-layout-content"
      assert_includes css, "padding-inline: var(--layout-content-inset);"
      assert_includes css, ".fp-layout-column"
      assert_includes css, "max-width: var(--layout-content-max-width);"
      assert_includes css, "margin-inline: auto;"
      assert_includes css, "left: max(calc(var(--layout-content-inset) + var(--top-nav-float-offset) + max(0px, (100% - (var(--layout-content-inset) * 2) - var(--layout-content-max-width)) / 2)), env(safe-area-inset-left, 0px));"
      assert_includes css, "right: max(calc(var(--layout-content-inset) + var(--top-nav-float-offset) + max(0px, (100% - (var(--layout-content-inset) * 2) - var(--layout-content-max-width)) / 2)), env(safe-area-inset-right, 0px));"
      assert_includes css, "padding-left: max(var(--top-nav-padding-inline), env(safe-area-inset-left, 0px));"
      assert_includes css, "[data-flat-pack-top-nav-floating=\"below\"]"
      assert_includes css, "padding-top: var(--top-nav-float-clearance);"
      assert_includes css, "scroll-padding-top: var(--top-nav-float-clearance);"
      assert_includes css, "background-color: var(--sidebar-float-background-color);"
      assert_includes css, "box-shadow: var(--sidebar-float-shadow);"
      assert_includes css, "border-radius: var(--sidebar-float-radius);"
      assert_includes css, "border-radius: var(--top-nav-float-radius);"
      assert_includes css, "overflow: visible;"
      assert_includes css, "padding-block: var(--top-nav-float-padding-block);"
      assert_includes css, "padding-inline: var(--top-nav-float-padding-inline);"
      assert_includes css, "gap: var(--top-nav-float-gap);"
      refute_includes css, "padding-inline: max(0.25rem, min(0.75rem, calc(var(--top-nav-float-radius) - var(--sidebar-float-radius))));"
      assert_includes css, "gap: 0.5rem;"
      assert_includes css, "gap: 0.25rem;"
      assert_includes css, "flex: 1 1 0%;"
      assert_includes css, "max-width: max-content;"
      assert_includes css, "@media (max-width: 767px)"
      assert_includes css, "padding-inline: 0.25rem;"
      assert_includes controller, "syncFloatingTopNavClearance"
      assert_includes controller, "applyFloatingTopNavClearance"
      assert_includes css, "[data-flat-pack-top-nav-section=\"right\"] > *"
      assert_includes css, "[data-flat-pack-top-nav-section=\"right\"] > [class*=\"--button-round-border-radius\"]"
      assert_includes css, "border-radius: var(--button-round-border-radius);"
      assert_includes css, "html[data-theme]:not([data-theme~=\"rounded\"]) [data-flat-pack-top-nav-floating]"
      top_nav_float = css[/Floating top nav\..*?^\}/m]
      refute_nil top_nav_float
      refute_includes top_nav_float, "@media (min-width: 768px)"
      desktop_rail = css[/Sidebar layout:.*?\n  \}/m]
      refute_nil desktop_rail
      assert_includes desktop_rail, "@media (min-width: 768px)"
      assert_includes desktop_rail, "width: var(--sidebar-width) !important;"
      assert_includes desktop_rail, "width: var(--sidebar-collapsed-width) !important;"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-width=\"content\"] aside"
      assert_includes desktop_rail, "width: var(--sidebar-measured-width, max-content) !important;"
      assert_includes desktop_rail, "min-width: var(--sidebar-measured-width, var(--sidebar-content-min-width)) !important;"
      assert_includes desktop_rail, "max-width: var(--sidebar-measured-width, var(--sidebar-content-max-width)) !important;"
      assert_includes desktop_rail, "interpolate-size: allow-keywords;"
      assert_includes desktop_rail, ".fp-sidebar-drawer"
      assert_includes desktop_rail, "width: var(--sidebar-width) !important;"
      refute_includes css, "width: 16rem !important;"
      refute_includes css, "width: 4rem !important;"
      assert_includes controller, "var(--sidebar-width, 16rem)"
      assert_includes controller, "var(--sidebar-collapsed-width, 4rem)"
      assert_includes controller, "rememberOpenWidth"
      assert_includes controller, 'setProperty("transition-property", "none", "important")'
      refute_includes controller, 'style.width = "16rem"'
      refute_includes controller, 'style.width = "4rem"'
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"]"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"]:not([data-flat-pack-sidebar-height=\"content\"])"
      assert_includes desktop_rail, "height: calc(100vh - (var(--sidebar-float-inset) * 2)) !important;"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"][data-flat-pack-sidebar-height=\"content\"]"
      assert_includes desktop_rail, "height: auto !important;"
      assert_includes desktop_rail, "max-height: calc(100vh - (var(--sidebar-float-inset) * 2)) !important;"
      refute_includes css.sub(desktop_rail, ""), "[data-flat-pack-sidebar-height=\"content\"]"
      refute_includes css, "margin-left: calc((100% - 1.25rem) / 2)"
      refute_includes css, "justify-content: center"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-collapsed=\"true\"] .fp-sidebar"
      refute_includes css, "desktopToggle"
      refute_includes controller, "delayContentReveal"
      refute_includes controller, "setDesktopExpandedContentVisible"
      refute_includes controller, "Align active navigation item to the top"
      refute_includes controller, "applyCollapsedRestState"
      refute_includes controller, "scheduleCollapsedRestState"
      assert_includes controller, "scheduleScrollRestore"
      assert_includes controller, "markItemCurrent"
      refute_includes controller, "isSectionTitleLabel"
      refute_includes controller, "labelNodes"
      refute_includes controller, 'querySelector("aside")'
      refute_includes controller, "clearCollapsedRestState"
    end
  end
end
