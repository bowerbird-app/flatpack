# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageActionRegistryTest < ActiveSupport::TestCase
    test "stores actions in source order with their roles" do
      registry = PageActionRegistry.new
      registry.add(PageAction.new("Share", "/share", role: :secondary, icon: :share))
      registry.add(PageAction.new("New press kit", "/press-kits/new", role: :primary, icon: :plus))
      registry.add(PageAction.new("Delete", "/press-kits/delete", role: :destructive, icon: :trash))

      actions = registry.actions

      assert_equal ["Share", "New press kit", "Delete"], actions.map(&:label)
      assert_equal [:secondary, :primary, :destructive], actions.map(&:role)
      assert_equal [:share, :plus, :trash], actions.map(&:icon)
      assert_equal ["/share", "/press-kits/new", "/press-kits/delete"], actions.map(&:href)
    end

    test "a second registry does not see the first" do
      first = PageActionRegistry.new
      first.add(PageAction.new("New press kit", "/press-kits/new", role: :primary))

      second = PageActionRegistry.new

      assert_equal ["New press kit"], first.actions.map(&:label)
      assert_empty second.actions
      assert_predicate second, :empty?
    end

    test "add returns nil" do
      registry = PageActionRegistry.new

      assert_nil registry.add(PageAction.new("Share", "/share"))
    end

    test "rejects a blank label, a blank path, an unsafe path, and an unknown role" do
      assert_raises(ArgumentError) { PageAction.new("", "/new") }
      assert_raises(ArgumentError) { PageAction.new("New", "") }
      assert_raises(ArgumentError) { PageAction.new("New", nil) }
      assert_raises(ArgumentError) { PageAction.new("New", "javascript:alert(1)") }
      error = assert_raises(ArgumentError) { PageAction.new("New", "/new", role: :danger) }
      assert_equal "role must be :primary, :secondary, or :destructive", error.message
    end

    test "keeps data and aria and defaults the role to secondary" do
      action = PageAction.new(
        "Share",
        "/share",
        data: {turbo: false},
        aria: {label: "Share this kit"}
      )

      assert_equal :secondary, action.role
      assert_equal({turbo: false}, action.data)
      assert_equal({label: "Share this kit"}, action.aria)
    end
  end
end
