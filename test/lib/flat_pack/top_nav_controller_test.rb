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
  end
end
