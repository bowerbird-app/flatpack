# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class ColorSwatchControllerTest < ActiveSupport::TestCase
    test "node tests cover update reset and clear" do
      test_file = FlatPack::Engine.root.join("test/javascript/color_swatch_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
