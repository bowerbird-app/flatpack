# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ComponentCatalogTest < ActiveSupport::TestCase
    setup do
      FlatPack::ComponentCatalog.reset!
    end

    teardown do
      FlatPack::ComponentCatalog.reset!
    end

    test "list includes public components and nested item classes" do
      names = listed_names

      assert_includes names, "Button::Component"
      assert_includes names, "List::Item"
      assert_includes names, "Timeline::Item"
      assert_includes names, "ChartButtons::ButtonComponent"
    end

    test "list excludes internals, shared helpers, and non-components" do
      names = listed_names

      refute_includes names, "BaseComponent"
      refute_includes names, "Shared::IconComponent"
      refute_includes names, "FormField::Component"
      refute_includes names, "Tree::Builder"
      refute_includes names, "TextArea::RichTextOptions"
    end

    test "list rows are skinny and meta.count matches records" do
      payload = FlatPack::ComponentCatalog.list
      records = payload.fetch(:records)
      meta = payload.fetch(:meta)

      assert_equal records.size, meta.fetch(:count)
      assert_equal FlatPack::VERSION, meta.fetch(:gem_version)
      assert_equal "public", meta.fetch(:publicity).fetch(:scope)
      excludes = meta.fetch(:publicity).fetch(:excludes)
      assert_includes excludes, "FlatPack::BaseComponent"
      assert_includes excludes, "FlatPack::Shared::*"
      assert_includes excludes, "FlatPack::FormField::Component"
      assert_includes excludes, "non-classes"
      assert_includes excludes, "classes that do not inherit FlatPack::BaseComponent"
      records.each do |row|
        assert_equal %i[name class description category], row.keys
        refute row.key?(:parameters)
      end
    end

    test "show Button binds SCHEMES to style and SIZES to size" do
      payload = FlatPack::ComponentCatalog.show("Button::Component")

      assert_equal "Button::Component", payload.fetch(:name)
      assert_equal "FlatPack::Button::Component", payload.fetch(:class)
      assert_equal "Button", payload.fetch(:category)

      style = parameter_named(payload, "style")
      size = parameter_named(payload, "size")

      assert_equal FlatPack::Button::Component::SCHEMES.keys.map(&:to_s), style.fetch(:enum)
      assert_equal "string", style.fetch(:type)
      assert_equal false, style.fetch(:required)
      assert_equal FlatPack::Button::Component::SIZES.keys.map(&:to_s), size.fetch(:enum)
      refute(payload.fetch(:parameters).any? { |parameter| parameter.fetch(:name) =~ /icon_only_size/i })
    end

    test "show Alert binds VARIANTS to style" do
      payload = FlatPack::ComponentCatalog.show("Alert::Component")
      style = parameter_named(payload, "style")

      assert_equal FlatPack::Alert::Component::VARIANTS.keys.map(&:to_s), style.fetch(:enum)
      refute payload.fetch(:parameters).any? { |parameter| parameter.fetch(:name) == "variant" }
    end

    test "show Tabs binds VARIANTS to variant" do
      initialize_names = FlatPack::Tabs::Component.instance_method(:initialize).parameters.map(&:last)

      assert_includes initialize_names, :variant

      payload = FlatPack::ComponentCatalog.show("Tabs::Component")
      variant = parameter_named(payload, "variant")

      assert_equal FlatPack::Tabs::Component::VARIANTS.keys.map(&:to_s), variant.fetch(:enum)
      refute payload.fetch(:parameters).any? { |parameter| parameter.fetch(:name) == "style" }
    end

    test "show Avatar binds SHAPES to shape" do
      payload = FlatPack::ComponentCatalog.show("Avatar::Component")
      shape = parameter_named(payload, "shape")

      assert_equal FlatPack::Avatar::Component::SHAPES.keys.map(&:to_s), shape.fetch(:enum)
    end

    test "show Tooltip binds PLACEMENTS to placement" do
      payload = FlatPack::ComponentCatalog.show("Tooltip::Component")
      placement = parameter_named(payload, "placement")

      assert_equal FlatPack::Tooltip::Component::PLACEMENTS.keys.map(&:to_s), placement.fetch(:enum)
    end

    test "show Stepper binds ORIENTATIONS to orientation" do
      payload = FlatPack::ComponentCatalog.show("Stepper::Component")
      orientation = parameter_named(payload, "orientation")

      assert_equal FlatPack::Stepper::Component::ORIENTATIONS.map(&:to_s), orientation.fetch(:enum)
    end

    test "show Pagination binds MODES to mode" do
      payload = FlatPack::ComponentCatalog.show("Pagination::Component")
      mode = parameter_named(payload, "mode")

      assert_equal FlatPack::Pagination::Component::MODES.keys.map(&:to_s), mode.fetch(:enum)
    end

    test "show returns nil for unknown names and accepts URL aliases" do
      assert_nil FlatPack::ComponentCatalog.show("nope")

      dashed = FlatPack::ComponentCatalog.show("Button--Component")
      prefixed = FlatPack::ComponentCatalog.show("FlatPack::Button::Component")

      assert_equal "Button::Component", dashed.fetch(:name)
      assert_equal dashed, prefixed
    end

    test "reset! rebuilds the catalog" do
      first = FlatPack::ComponentCatalog.list
      first_entries = FlatPack::ComponentCatalog.entries

      FlatPack::ComponentCatalog.reset!
      second = FlatPack::ComponentCatalog.list

      assert_equal first, second
      refute_same first_entries, FlatPack::ComponentCatalog.entries
      assert_includes listed_names, "Button::Component"
    end

    private

    def listed_names
      FlatPack::ComponentCatalog.list.fetch(:records).map { |row| row.fetch(:name) }
    end

    def parameter_named(payload, name)
      payload.fetch(:parameters).find { |parameter| parameter.fetch(:name) == name } ||
        flunk("missing parameter #{name}")
    end
  end
end
