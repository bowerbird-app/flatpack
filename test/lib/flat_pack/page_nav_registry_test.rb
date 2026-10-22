# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavRegistryTest < ActiveSupport::TestCase
    test "stores items in source order with their roles" do
      registry = PageNavRegistry.new
      registry.add(PageNavItem.new("Share", "/share", role: :secondary, icon: :share))
      registry.add(PageNavItem.new("New press kit", "/press-kits/new", role: :primary, icon: :plus))
      registry.add(PageNavItem.new("Delete", "/press-kits/delete", role: :destructive, icon: :trash))

      items = registry.items

      assert_equal ["Share", "New press kit", "Delete"], items.map(&:label)
      assert_equal [:secondary, :primary, :destructive], items.map(&:role)
      assert_equal [:share, :plus, :trash], items.map(&:icon)
      assert_equal ["/share", "/press-kits/new", "/press-kits/delete"], items.map(&:href)
    end

    test "a second registry does not see the first" do
      first = PageNavRegistry.new
      first.add(PageNavItem.new("New press kit", "/press-kits/new", role: :primary))

      second = PageNavRegistry.new

      assert_equal ["New press kit"], first.items.map(&:label)
      assert_empty second.items
      assert_predicate second, :empty?
    end

    test "add returns nil" do
      registry = PageNavRegistry.new

      assert_nil registry.add(PageNavItem.new("Share", "/share", role: :secondary))
    end

    test "rejects a blank label, a blank path, an unsafe path, and an unknown role" do
      assert_raises(ArgumentError) { PageNavItem.new("", "/new", role: :primary) }
      assert_raises(ArgumentError) { PageNavItem.new("New", "", role: :primary) }
      assert_raises(ArgumentError) { PageNavItem.new("New", nil, role: :primary) }
      assert_raises(ArgumentError) { PageNavItem.new("New", "javascript:alert(1)", role: :primary) }
      error = assert_raises(ArgumentError) { PageNavItem.new("New", "/new", role: :danger) }
      assert_equal "role must be :primary, :secondary, or :destructive", error.message
      assert_raises(ArgumentError) { PageNavItem.new("New", "/new") }
    end

    test "keeps data and aria" do
      item = PageNavItem.new(
        "Share",
        "/share",
        role: :secondary,
        data: {turbo: false},
        aria: {label: "Share this kit"}
      )

      assert_equal :secondary, item.role
      assert_equal({turbo: false}, item.data)
      assert_equal({label: "Share this kit"}, item.aria)
      refute_predicate item, :component?
    end

    test "stores a component without styling fields and claims it once" do
      component = Object.new
      registry = PageNavRegistry.new
      item = PageNavItem.new(role: :primary, component: component)
      registry.add(item)
      registry.add(PageNavItem.new("Share", "/share", role: :secondary))

      assert_predicate item, :component?
      assert_equal component, item.component
      assert_nil item.label
      assert_equal [item], registry.claim_components
      assert_empty registry.claim_components
    end

    test "a component rejects a label, a path, and an unknown role" do
      component = Object.new
      assert_raises(ArgumentError) { PageNavItem.new("New", "/new", role: :primary, component: component) }
      assert_raises(ArgumentError) { PageNavItem.new(role: :danger, component: component) }
      assert_raises(ArgumentError) { PageNavItem.new(component: component) }
    end
  end
end
