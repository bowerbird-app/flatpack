# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class FloatingFrameControllerTest < ActiveSupport::TestCase
    test "node tests mount the iframe once and move focus" do
      test_file = FlatPack::Engine.root.join("test/javascript/floating_frame_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
