# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class RangeInputControllerTest < ActiveSupport::TestCase
    test "node tests paint --range-progress on the native input" do
      test_file = FlatPack::Engine.root.join("test/javascript/range_input_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
