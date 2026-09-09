# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class PasswordInputControllerTest < ActiveSupport::TestCase
    test "node tests toggle pressed state without snapping hidden" do
      test_file = FlatPack::Engine.root.join("test/javascript/password_input_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
