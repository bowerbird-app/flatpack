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
      assert_includes css, "padding-left: 0.25rem !important"
      assert_includes css, "padding-left: 0 !important"
      assert_includes css, "gap: 0 !important"
      assert_includes css, "margin-left: calc((4rem - 1px - (var(--spacing) * 4) - 1.25rem) / 2 - 0.25rem) !important"
      assert_includes css, "[data-flat-pack-sidebar-floating=\"true\"]"
      assert_includes css, "margin-top: var(--sidebar-float-inset) !important;"
      assert_includes css, "margin-left: calc((4rem - 2px - (var(--spacing) * 4) - 1.25rem) / 2 - 0.25rem) !important"
      assert_includes css, "border-radius: var(--sidebar-float-radius);"
      assert_includes css, "html[data-theme]:not([data-theme=\"rounded\"]) [data-flat-pack-sidebar-floating=\"true\"] aside"
      desktop_rail = css[/Sidebar layout:.*?\n  \}/m]
      refute_nil desktop_rail
      assert_includes desktop_rail, "@media (min-width: 768px)"
      assert_includes desktop_rail, "[data-flat-pack-sidebar-floating=\"true\"]"
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
