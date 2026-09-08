# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class ModalControllerTest < ActiveSupport::TestCase
    test "node tests wrap tab at the ends of the dialog" do
      test_file = FlatPack::Engine.root.join("test/javascript/modal_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
