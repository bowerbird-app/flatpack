# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavTest < ActiveSupport::TestCase
    setup do
      @previous_styles = FlatPack.configuration.page_nav_styles
    end

    teardown do
      FlatPack.configuration.page_nav_styles = @previous_styles
    end

    test "header maps primary to solid, secondary to subtle, and destructive to danger" do
      resolved = PageNav.resolve(:header)

      assert_equal({style: :primary, size: :sm}, resolved[:primary])
      assert_equal({style: :secondary, size: :sm}, resolved[:secondary])
      assert_equal({style: :danger, size: :sm}, resolved[:destructive])
    end

    test "top nav maps primary to a subtle style and secondary to ghost" do
      resolved = PageNav.resolve(:top_nav)

      assert_equal({style: :secondary, size: :sm}, resolved[:primary])
      assert_equal({style: :ghost, size: :sm}, resolved[:secondary])
      assert_equal({style: :danger, size: :sm}, resolved[:destructive])
    end

    test "the host map overrides the default and a layout map overrides the host" do
      FlatPack.configuration.page_nav_styles = {
        header: {primary: {style: :ghost}}
      }

      assert_equal :ghost, PageNav.resolve(:header)[:primary][:style]
      assert_equal :sm, PageNav.resolve(:header)[:primary][:size]
      assert_equal :secondary, PageNav.resolve(:header)[:secondary][:style]
      assert_equal :secondary, PageNav.resolve(:top_nav)[:primary][:style]

      resolved = PageNav.resolve(:header, {header: {primary: {style: :secondary, size: :md}}})

      assert_equal :secondary, resolved[:primary][:style]
      assert_equal :md, resolved[:primary][:size]
      assert_equal :ghost, PageNav.resolve(:header)[:primary][:style]
    end

    test "unknown context, role, button style, and size raise" do
      assert_raises(ArgumentError) { PageNav.resolve(:mobile) }
      assert_raises(ArgumentError) { PageNav.resolve(:header, {bold: {style: :primary}}) }
      error = assert_raises(ArgumentError) do
        PageNav.resolve(:header, {header: {primary: {style: :nope}}})
      end
      assert_match(/Invalid style: nope/, error.message)
      assert_raises(ArgumentError) do
        FlatPack.configuration.page_nav_styles = {header: {primary: {size: :xs}}}
      end
    end
  end
end
