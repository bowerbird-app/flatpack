# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class TextStreamControllerTest < ActiveSupport::TestCase
    test "node tests cover typing, the caret, and reduced motion" do
      test_file = FlatPack::Engine.root.join("test/javascript/text_stream_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "controller keeps the source text and treats the caret as decorative" do
      source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/text_stream_controller.js").read

      assert_includes source, "controllers/flat_pack/reduced_motion"
      assert_includes source, "sourceTarget.textContent"
      assert_includes source, "--reveal-stagger"
      assert_includes source, "caretTarget.hidden = true"
      refute_match(/prefers-reduced-motion/, source)
    end
  end
end
