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

    test "a folded dropdown is not restyled as a disclosure" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/top_nav_controller.js").read
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes js, "prepareDisclosures"
      refute_includes js, "restoreDisclosures"
      refute_includes js, "flat-pack-top-nav-disclosure"
      refute_includes js, "flatPackTopNavDisclosure"
      refute_includes js, "flatPackTopNavExpanded"
      refute_includes css, "[data-flat-pack-top-nav-disclosure]"
      refute_includes css, "data-flat-pack-top-nav-expanded"
      refute_includes css, ".fp-top-nav [data-flat-pack-top-nav-section=\"center\"] input"
    end
  end
end
