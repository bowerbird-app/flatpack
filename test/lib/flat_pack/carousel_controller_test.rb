# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class CarouselControllerTest < ActiveSupport::TestCase
    test "carousel controller opens the lightbox on the current slide" do
      test_file = FlatPack::Engine.root.join("test/javascript/carousel_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end
  end
end
