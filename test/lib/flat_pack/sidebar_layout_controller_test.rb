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

    test "kit CSS fades sidebar labels instead of recentering icons" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/sidebar_layout_controller.js").read

      assert_includes css, ".fp-sidebar-label"
      assert_match(/opacity\s+var\(--duration-fast\)\s+var\(--easing-standard\)/, css)
      assert_includes css, "[data-flat-pack-sidebar-collapsed=\"true\"] .fp-sidebar-label"
      refute_includes controller, "delayContentReveal"
      refute_includes controller, "justify-center"
      refute_includes controller, "setDesktopExpandedContentVisible"
    end
  end
end
