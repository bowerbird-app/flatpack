# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class TriggerOriginTest < ActiveSupport::TestCase
    test "node tests cover trigger origin math and fallbacks" do
      test_file = FlatPack::Engine.root.join("test/javascript/trigger_origin_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "trigger origin helper is isolated from modal drawer and picker controllers" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/trigger_origin.js").read
      modal = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/modal_controller.js").read
      drawer = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/drawer_controller.js").read
      picker = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/picker_controller.js").read

      assert_includes helper, "export function computeTriggerOriginMotion"
      assert_includes helper, "export function canUseTriggerOrigin"
      assert_includes helper, "MIN_VIEWPORT_WIDTH = 640"
      assert_includes modal, "controllers/flat_pack/trigger_origin"
      refute_includes drawer, "trigger_origin"
      refute_includes picker, "trigger_origin"
      refute_includes modal, "style.transform"
      assert_includes helper, "style.transform"
    end
  end
end
