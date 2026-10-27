# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class ClickOutsideTest < ActiveSupport::TestCase
    OUTSIDE = {
      "popover_controller.js" => {event: "click", capture: true},
      "search_controller.js" => {event: "click", capture: false},
      "select_controller.js" => {event: "click", capture: false},
      "button_dropdown_controller.js" => {event: "click", capture: true},
      "flatpack_date_picker_controller.js" => {event: "click", capture: true},
      "collection_editor_controller.js" => {event: "click", capture: false, keeps_listener: true},
      "combobox_controller.js" => {event: "mousedown", capture: false},
      "fab_controller.js" => {event: "pointerdown", capture: true},
      "button_group_menu_controller.js" => {event: "pointerdown", capture: false},
      "trash_button_controller.js" => {event: "pointerdown", capture: false},
      "search_collapse_controller.js" => {event: "pointerdown", capture: false},
      "chat_message_actions_controller.js" => {event: nil, capture: false}
    }.freeze

    DIALOGS = %w[
      modal_controller.js
      drawer_controller.js
      command_palette_controller.js
      lightbox_controller.js
    ].freeze

    test "node tests cover outside clicks, triggers, disconnect, and backdrop clicks" do
      test_file = FlatPack::Engine.root.join("test/javascript/click_outside_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "outside controllers share onClickOutside and drop their document listener copies" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/click_outside.js").read

      assert_includes helper, "export function isOutside"
      assert_includes helper, "export function onClickOutside"
      assert_includes helper, "export function isBackdropClick"

      OUTSIDE.each do |name, expected|
        source = controller_source(name)

        assert_includes source, 'from "flat_pack/click_outside"', name
        if expected[:event]
          assert_includes source, "onClickOutside", name
          unless expected[:keeps_listener]
            refute_includes source, "document.addEventListener(\"#{expected[:event]}\"", name
          end
          if expected[:capture]
            assert_includes source, "capture: true", name
          else
            refute_includes source, "capture: true", name
          end
        else
          assert_includes source, "isOutside", name
        end
      end

      date_picker = controller_source("flatpack_date_picker_controller.js")
      popover = controller_source("popover_controller.js")
      dropdown = controller_source("button_dropdown_controller.js")

      assert_includes date_picker, "document.addEventListener(\"keydown\", this.handleEscape, true)"
      assert_includes popover, "document.addEventListener(\"keydown\", this.handleEscape, true)"
      assert_includes dropdown, "document.addEventListener(\"keydown\", this.handleEscape, true)"
      assert_includes controller_source("combobox_controller.js"), 'event: "mousedown"'
      assert_includes controller_source("collection_editor_controller.js"), "isOutside"
      assert_equal 1, controller_source("collection_editor_controller.js").scan('document.addEventListener("click"').length
    end

    test "dialogs share isBackdropClick and keep their own escape handling" do
      DIALOGS.each do |name|
        source = controller_source(name)

        assert_includes source, 'from "flat_pack/click_outside"', name
        assert_includes source, "isBackdropClick", name
        refute_includes source, "event.target === event.currentTarget", name
      end

      assert_includes controller_source("lightbox_controller.js"), "data-flat-pack--lightbox-target='stage'"
      assert_includes controller_source("modal_controller.js"), "closeOnBackdropValue"
      assert_includes controller_source("drawer_controller.js"), "closeOnBackdropValue"
      refute_includes controller_source("command_palette_controller.js"), "closeOnBackdropValue"
    end

    private

    def controller_source(name)
      FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
    end
  end
end
