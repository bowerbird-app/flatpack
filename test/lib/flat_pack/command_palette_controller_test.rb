# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class CommandPaletteControllerTest < ActiveSupport::TestCase
    test "node tests cycle Tab inside the dialog" do
      test_file = FlatPack::Engine.root.join("test/javascript/command_palette_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
