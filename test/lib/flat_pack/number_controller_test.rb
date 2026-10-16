# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class NumberControllerTest < ActiveSupport::TestCase
    test "node tests cover count, roll, fade, reduced motion, and later updates" do
      test_file = FlatPack::Engine.root.join("test/javascript/number_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "controller shares the reveal in-view trigger and the reduced motion helper" do
      source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/number_controller.js").read

      assert_includes source, "controllers/flat_pack/reduced_motion"
      assert_includes source, "observeOnce"
      assert_includes source, "motionTokenMs"
      assert_includes source, "setValue"
      refute_includes source, "aria-live"
      refute_match(/prefers-reduced-motion/, source)
      refute_includes source, "IntersectionObserver"
    end
  end
end
