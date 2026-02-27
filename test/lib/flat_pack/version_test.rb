# frozen_string_literal: true

require "test_helper"

module FlatPack
  class VersionTest < ActiveSupport::TestCase
    test "version constant is present" do
      assert_predicate FlatPack::VERSION, :present?
      assert_match(/\A\d+\.\d+\.\d+\z/, FlatPack::VERSION)
    end
  end
end
