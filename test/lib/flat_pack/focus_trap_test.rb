# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class FocusTrapTest < ActiveSupport::TestCase
    SELECTOR = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'

    test "node tests cover tab wrap, empty containers, and focus on the container" do
      test_file = FlatPack::Engine.root.join("test/javascript/focus_trap_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "drawer command palette modal and dropdown share one focusable selector" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/focus_trap.js").read
      drawer = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/drawer_controller.js").read
      palette = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/command_palette_controller.js").read
      modal = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/modal_controller.js").read
      dropdown = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/button_dropdown_controller.js").read

      assert_equal 1, helper.scan(SELECTOR).length
      assert_includes helper, "export function trapTab"
      assert_includes helper, "export function focusableElements"
      assert_includes drawer, 'from "flat_pack/focus_trap"'
      assert_includes palette, 'from "flat_pack/focus_trap"'
      assert_includes modal, 'from "flat_pack/focus_trap"'
      assert_includes dropdown, 'from "flat_pack/focus_trap"'
      assert_includes dropdown, "focusableElements"
      assert_includes modal, "modal: true"
      refute_includes drawer, "modal: true"
      refute_includes palette, "modal: true"
      refute_includes drawer, SELECTOR
      refute_includes palette, SELECTOR
      refute_includes dropdown, SELECTOR
      refute_includes dropdown, "input:not([disabled]):not([type='hidden'])"
      refute_includes modal, "a[href], button:not([disabled])"
    end
  end
end
