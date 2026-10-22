# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageActionsTest < ActiveSupport::TestCase
    test "header maps primary to solid, secondary to subtle, and destructive to danger" do
      assert_equal(
        {primary: :primary, secondary: :secondary, destructive: :danger},
        PageActions.styles(:header)
      )
      assert_equal :sm, PageActions.size(:header)
    end

    test "top nav maps primary to a subtle style and secondary to ghost" do
      assert_equal(
        {primary: :secondary, secondary: :ghost, destructive: :danger},
        PageActions.styles(:top_nav)
      )
      assert_equal :sm, PageActions.size(:top_nav)
    end

    test "a layout can override one role and the others stay" do
      map = PageActions.styles(:header, primary: :ghost)

      assert_equal :ghost, map[:primary]
      assert_equal :secondary, map[:secondary]
      assert_equal :danger, map[:destructive]
    end

    test "a hash override matches the keyword form" do
      assert_equal :ghost, PageActions.styles(:top_nav, {primary: :ghost})[:primary]
    end

    test "unknown context, role, and button style raise" do
      assert_raises(ArgumentError) { PageActions.styles(:mobile) }
      assert_raises(ArgumentError) { PageActions.size(:footer) }
      assert_raises(ArgumentError) { PageActions.styles(:header, bold: :primary) }
      error = assert_raises(ArgumentError) { PageActions.styles(:header, primary: :nope) }
      assert_match(/Invalid style: nope/, error.message)
    end
  end
end
