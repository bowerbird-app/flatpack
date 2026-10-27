# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class PositioningTest < ActiveSupport::TestCase
    test "node tests cover placement, flip, clamp, and viewport listeners" do
      helper = FlatPack::Engine.root.join("test/javascript/positioning_test.js")
      popover = FlatPack::Engine.root.join("test/javascript/popover_controller_test.js")
      dropdown = FlatPack::Engine.root.join("test/javascript/button_dropdown_controller_test.js")
      date_picker = FlatPack::Engine.root.join("test/javascript/flatpack_date_picker_controller_test.js")
      date_picker_position = FlatPack::Engine.root.join("test/javascript/flatpack_date_picker_position_test.js")
      collection = FlatPack::Engine.root.join("test/javascript/collection_editor_position_test.js")
      stdout, status = Open3.capture2e(
        "node", "--test",
        helper.to_s,
        popover.to_s,
        dropdown.to_s,
        date_picker.to_s,
        date_picker_position.to_s,
        collection.to_s
      )

      assert status.success?, stdout
    end

    test "popover, button dropdown, date picker, and collection editor place through the shared helper" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/positioning.js").read
      popover = controller_source("popover_controller.js")
      dropdown = controller_source("button_dropdown_controller.js")

      assert_includes helper, "export function place"
      assert_includes helper, "stickToEdge = false"
      assert_includes helper, "export function readEdgeOffset"
      assert_includes helper, "export function applyFixedPosition"
      assert_includes helper, "export function watchViewport"

      assert_includes popover, 'from "flat_pack/positioning"'
      assert_includes popover, "PANEL_GAP = 12"
      assert_includes popover, "readEdgeOffset(this.element)"
      refute_includes popover, "stickToEdge"
      refute_includes popover, "resolvePlacement"
      refute_includes popover, "computePosition"
      refute_includes popover, "viewportPadding"
      refute_includes popover, 'window.addEventListener("scroll"'
      refute_includes popover, 'window.addEventListener("resize"'

      assert_includes dropdown, 'from "flat_pack/positioning"'
      assert_includes dropdown, "MENU_GAP = 8"
      assert_includes dropdown, "flip: false"
      assert_includes dropdown, "stickToEdge: true"
      assert_includes dropdown, "readEdgeOffset(menu)"
      refute_includes dropdown, "computePosition"
      refute_includes dropdown, "VIEWPORT_PADDING"
      refute_includes dropdown, 'window.addEventListener("scroll"'
      refute_includes dropdown, 'window.addEventListener("resize"'

      date_picker = controller_source("flatpack_date_picker_controller.js")
      assert_includes date_picker, 'from "flat_pack/positioning"'
      assert_includes date_picker, "PANEL_GAP = 8"
      assert_includes date_picker, 'placement: "bottom"'
      assert_includes date_picker, "flip: true"
      assert_includes date_picker, "stickToEdge: true"
      assert_includes date_picker, "readEdgeOffset(this.panelElement)"
      assert_includes date_picker, "positionPanel"
      assert_includes date_picker, "isMobileViewport"
      assert_includes date_picker, "100dvh"
      refute_includes date_picker, "viewportPadding"
      refute_includes date_picker, 'window.addEventListener("scroll"'
      refute_includes date_picker, 'window.addEventListener("resize"'

      collection = controller_source("collection_editor_controller.js")
      assert_includes collection, 'from "flat_pack/positioning"'
      assert_includes collection, "RESULTS_GAP = 4"
      assert_includes collection, 'placement: "bottom_left"'
      assert_includes collection, "stickToEdge: true"
      assert_includes collection, "readEdgeOffset(list)"
      assert_includes collection, "list.style.left = `${rect.left}px`"
      refute_includes collection, "rect.bottom + 4"
      refute_includes collection, 'document.addEventListener("scroll"'
      refute_includes collection, 'window.addEventListener("resize"'

      tooltip = controller_source("tooltip_controller.js")
      refute_includes tooltip, 'from "flat_pack/positioning"'
      assert_includes tooltip, "clampToViewport"
    end

    private

    def controller_source(name)
      FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
    end
  end
end
