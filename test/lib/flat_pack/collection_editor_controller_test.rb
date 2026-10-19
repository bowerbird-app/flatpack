# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class CollectionEditorControllerTest < ActiveSupport::TestCase
    test "node tests add, remove, select, and create collection rows" do
      test_file = FlatPack::Engine.root.join("test/javascript/collection_editor_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
