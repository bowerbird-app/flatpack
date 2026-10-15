# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class LightboxControllerTest < ActiveSupport::TestCase
    test "lightbox controller opens, traps focus through the dialog, and returns it" do
      test_file = FlatPack::Engine.root.join("test/javascript/lightbox_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
