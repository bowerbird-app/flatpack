# frozen_string_literal: true

require "test_helper"

module FlatPack
  class SlideIndicatorTest < ActiveSupport::TestCase
    test "normalize accepts slide and treats blanks as off" do
      assert_nil FlatPack::Shared::SlideIndicator.normalize(nil)
      assert_nil FlatPack::Shared::SlideIndicator.normalize(false)
      assert_nil FlatPack::Shared::SlideIndicator.normalize("")
      assert_equal :slide, FlatPack::Shared::SlideIndicator.normalize(:slide)
      assert_equal :slide, FlatPack::Shared::SlideIndicator.normalize("slide")
    end

    test "normalize rejects unknown names" do
      error = assert_raises(ArgumentError) { FlatPack::Shared::SlideIndicator.normalize(:bounce) }
      assert_includes error.message, "Invalid indicator"
    end
  end
end
