# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class VideoPreviewControllerTest < ActiveSupport::TestCase
    test "node tests cover template swap, keyboard activation, focus, and reduced motion" do
      test_file = FlatPack::Engine.root.join("test/javascript/video_preview_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "controller imports the reduced motion helper and names the play event" do
      source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/video_preview_controller.js").read

      assert_includes source, "controllers/flat_pack/reduced_motion"
      assert_includes source, "prefersReducedMotion"
      assert_includes source, "flat-pack:video-preview:play"
      refute_match(/prefers-reduced-motion/, source)
    end
  end
end
