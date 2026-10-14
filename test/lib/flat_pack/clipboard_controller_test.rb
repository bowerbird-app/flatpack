# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class ClipboardControllerTest < ActiveSupport::TestCase
    test "node tests cover clipboard writing, states, and the shared controller" do
      test_file = FlatPack::Engine.root.join("test/javascript/clipboard_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
