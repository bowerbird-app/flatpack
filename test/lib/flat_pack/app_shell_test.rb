# frozen_string_literal: true

require "test_helper"

module FlatPack
  class AppShellTest < ActiveSupport::TestCase
    test "the kit ships one app shell: SidebarLayout, not Navbar" do
      root = FlatPack::Engine.root

      assert_path_exists root.join("app/components/flat_pack/sidebar_layout/component.rb")
      assert_path_exists root.join("app/components/flat_pack/sidebar/component.rb")
      assert_path_exists root.join("app/components/flat_pack/top_nav/component.rb")
      assert_path_exists root.join("app/javascript/flat_pack/controllers/sidebar_layout_controller.js")

      refute_path_exists root.join("app/components/flat_pack/navbar/component.rb")
      refute_path_exists root.join("app/javascript/flat_pack/controllers/navbar_controller.js")
    end

    test "legacy Navbar constant is not defined" do
      error = assert_raises(NameError) { FlatPack::Navbar::Component }
      assert_match(/Navbar/, error.message)
    end
  end
end
