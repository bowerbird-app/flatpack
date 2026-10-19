# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class NavigableControllerTest < ActiveSupport::TestCase
    test "node tests cover push back close history and error chrome" do
      test_file = FlatPack::Engine.root.join("test/javascript/navigable_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
