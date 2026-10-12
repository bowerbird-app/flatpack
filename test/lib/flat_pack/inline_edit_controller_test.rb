# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class InlineEditControllerTest < ActiveSupport::TestCase
    test "node tests cover save cancel wrap and turbo streams" do
      test_file = FlatPack::Engine.root.join("test/javascript/inline_edit_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
