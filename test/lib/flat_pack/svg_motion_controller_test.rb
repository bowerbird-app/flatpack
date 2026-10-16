# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class SvgMotionControllerTest < ActiveSupport::TestCase
    test "node tests play setState reduced motion and icon presets" do
      test_file = FlatPack::Engine.root.join("test/javascript/svg_motion_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
