# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class SortableControllersTest < ActiveSupport::TestCase
    test "node tests wire drag listeners for rows and items added after connect" do
      test_file = FlatPack::Engine.root.join("test/javascript/sortable_controllers_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
