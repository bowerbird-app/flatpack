# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class PositioningTest < ActiveSupport::TestCase
    test "node tests cover placement, flip, clamp, and viewport listeners" do
      helper = FlatPack::Engine.root.join("test/javascript/positioning_test.js")
      popover = FlatPack::Engine.root.join("test/javascript/popover_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", helper.to_s, popover.to_s)

      assert status.success?, stdout
    end

    test "popover places through the shared helper and the other overlays keep their own math" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/positioning.js").read
      popover = controller_source("popover_controller.js")

      assert_includes helper, "export function place"
      assert_includes helper, "export function readEdgeOffset"
      assert_includes helper, "export function applyFixedPosition"
      assert_includes helper, "export function watchViewport"

      assert_includes popover, 'from "flat_pack/positioning"'
      assert_includes popover, "PANEL_GAP = 12"
      assert_includes popover, "readEdgeOffset(this.element)"
      refute_includes popover, "resolvePlacement"
      refute_includes popover, "computePosition"
      refute_includes popover, "viewportPadding"
      refute_includes popover, 'window.addEventListener("scroll"'
      refute_includes popover, 'window.addEventListener("resize"'

      tooltip = controller_source("tooltip_controller.js")
      dropdown = controller_source("button_dropdown_controller.js")
      date_picker = controller_source("flatpack_date_picker_controller.js")
      collection = controller_source("collection_editor_controller.js")

      [tooltip, dropdown, date_picker, collection].each do |source|
        refute_includes source, 'from "flat_pack/positioning"'
      end

      assert_includes tooltip, "clampToViewport"
      assert_includes dropdown, "VIEWPORT_PADDING"
      assert_includes date_picker, "positionPanel"
      assert_includes collection, "rect.bottom + 4"
    end

    private

    def controller_source(name)
      FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
    end
  end
end
