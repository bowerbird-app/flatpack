# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class TopNavControllerTest < ActiveSupport::TestCase
    test "node tests frost the bar after the page has scrolled" do
      test_file = FlatPack::Engine.root.join("test/javascript/top_nav_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "the controller frosts the bar and does not fold the row" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/top_nav_controller.js").read
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes js, "collapseIntoMenu"
      refute_includes js, "hoistAlwaysDisplay"
      refute_includes js, "placeMenu"
      refute_includes js, "prepareDisclosures"
      refute_includes js, "restoreDisclosures"
      refute_includes js, "flat-pack-top-nav-disclosure"
      refute_includes js, "flatPackTopNavDisclosure"
      refute_includes js, "flatPackTopNavExpanded"
      refute_includes css, "[data-flat-pack-top-nav-disclosure]"
      refute_includes css, "data-flat-pack-top-nav-expanded"
      refute_includes css, "[data-flat-pack--top-nav-target=\"panel\"]"
      refute_includes css, "[data-flat-pack--top-nav-target=\"toggle\"]"
      refute_includes css, "[data-flat-pack--top-nav-target=\"menu\"]"
      refute_includes css, "data-flat-pack-top-nav-section"
      refute_includes css, ".fp-top-nav[data-scrolled=\"true\"]"
      assert_includes css, ".fp-layout-top-nav[data-scrolled=\"true\"]"
      assert_includes css, ".fp-top-nav__section :where(input, select, textarea)"
      none_at = css.index('.fp-top-nav[data-fp-top-nav-padding="none"]')
      refute_nil none_at
      assert_operator none_at, :>, css.index(".fp-top-nav {")
      none = css[none_at, 280]
      assert_includes none, "padding-left: env(safe-area-inset-left, 0px);"
      assert_includes none, "padding-right: env(safe-area-inset-right, 0px);"
      refute_includes none, "--top-nav-padding-inline"
    end
  end
end
