# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavRoleStylesTest < ActiveSupport::TestCase
    test "solid and quiet are role maps" do
      assert_equal :primary, PageNavRoleStyles.entry(PageNavRoleStyles::SOLID, :primary)[:style]
      assert_equal :sm, PageNavRoleStyles.entry(PageNavRoleStyles::SOLID, "secondary")[:size]
      assert_equal :danger, PageNavRoleStyles.entry(PageNavRoleStyles::SOLID, :destructive)[:style]

      assert_equal :secondary, PageNavRoleStyles.entry(PageNavRoleStyles::QUIET, :primary)[:style]
      assert_equal :secondary, PageNavRoleStyles.entry(PageNavRoleStyles::QUIET, :secondary)[:style]
      assert_equal :sm, PageNavRoleStyles.entry(PageNavRoleStyles::QUIET, :secondary)[:size]
      assert_equal :danger, PageNavRoleStyles.entry(PageNavRoleStyles::QUIET, :destructive)[:style]
      assert_equal :md, PageNavRoleStyles.entry(PageNavRoleStyles::PIN, :primary)[:size]
    end

    test "a caller map chooses the button" do
      item = PageNavItem.new("New press kit", "/press-kits/new", role: :primary, icon: :plus, aria: {label: "Create"})
      button = PageNavRoleStyles.button_for(
        item,
        styles: {primary: {style: :ghost, size: :md}},
        size: :sm
      )

      assert_equal "New press kit", button.instance_variable_get(:@text)
      assert_equal "/press-kits/new", button.instance_variable_get(:@href)
      assert_equal :ghost, button.instance_variable_get(:@style)
      assert_equal :sm, button.instance_variable_get(:@size)
      assert_equal :plus, button.instance_variable_get(:@icon)
    end

    test "rejects an unknown role, a partial entry, and a component" do
      assert_raises(ArgumentError) { PageNavRoleStyles.entry({bold: {style: :primary, size: :sm}}, :primary) }
      assert_raises(ArgumentError) { PageNavRoleStyles.entry({primary: {style: :nope, size: :sm}}, :primary) }
      assert_raises(ArgumentError) { PageNavRoleStyles.entry({primary: {style: :primary}}, :primary) }
      assert_raises(ArgumentError) { PageNavRoleStyles.entry({primary: {style: :primary, size: :xs}}, :primary) }
      assert_raises(ArgumentError) { PageNavRoleStyles.normalize!(nil) }
      assert_raises(ArgumentError) { PageNavRoleStyles.entry(PageNavRoleStyles::PIN, :secondary) }

      component = PageNavItem.new(role: :primary, component: Object.new)
      assert_raises(ArgumentError) { PageNavRoleStyles.button_for(component, styles: PageNavRoleStyles::SOLID) }
    end
  end
end
