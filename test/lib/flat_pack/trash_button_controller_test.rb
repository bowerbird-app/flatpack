# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class TrashButtonControllerTest < ActiveSupport::TestCase
    test "node tests cover arm confirm cancel and reduced motion" do
      test_file = FlatPack::Engine.root.join("test/javascript/trash_button_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
