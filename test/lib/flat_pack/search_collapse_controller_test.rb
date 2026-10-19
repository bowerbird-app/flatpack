# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class SearchCollapseControllerTest < ActiveSupport::TestCase
    test "node tests cover expand collapse escape outside click and focus" do
      test_file = FlatPack::Engine.root.join("test/javascript/search_collapse_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
