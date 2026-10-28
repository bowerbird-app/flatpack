# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Shared
    class InlineSvgTest < ActiveSupport::TestCase
      test "a string that starts with svg is markup" do
        assert InlineSvg.markup?('<svg data-logo="mark"></svg>')
      end

      test "leading whitespace still counts as markup" do
        assert InlineSvg.markup?("  \n<svg></svg>")
      end

      test "a heroicon name is not markup" do
        refute InlineSvg.markup?("magnifying-glass")
        refute InlineSvg.markup?("search")
        refute InlineSvg.markup?(:search)
        refute InlineSvg.markup?(nil)
      end
    end
  end
end
