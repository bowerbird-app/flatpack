# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class DrawerControllerTest < ActiveSupport::TestCase
    test "node tests teleport the overlay to the document body" do
      test_file = FlatPack::Engine.root.join("test/javascript/drawer_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
