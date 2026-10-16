# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class RevealControllerTest < ActiveSupport::TestCase
    test "node tests cover one-shot reveal, reduced motion, and stagger indexes" do
      test_file = FlatPack::Engine.root.join("test/javascript/reveal_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "controller uses one observer and the reduced motion helper" do
      source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/reveal_controller.js").read

      assert_includes source, "controllers/flat_pack/reduced_motion"
      assert_includes source, "observeOnce"
      assert_includes source, "is-revealed"
      assert_includes source, "is-pending"
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/reduced_motion.js").read
      assert_includes helper, "export function observeOnce"
      assert_includes helper, "IntersectionObserver"
      refute_match(/prefers-reduced-motion/, source)
    end
  end
end
