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
        refute row.key?(:examples)
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

    test "show Button includes JSON-safe initialize literal defaults" do
      payload = FlatPack::ComponentCatalog.show("Button::Component")
      style = parameter_named(payload, "style")
      size = parameter_named(payload, "size")
      icon_only = parameter_named(payload, "icon_only")
      text = parameter_named(payload, "text")
      system_arguments = parameter_named(payload, "system_arguments")

      assert_equal "default", style.fetch(:default)
      assert_equal "md", size.fetch(:default)
      assert_equal false, icon_only.fetch(:default)
      assert_nil text.fetch(:default)
      assert text.key?(:default)
      refute system_arguments.key?(:default)
    end

    test "show EmailCard omits constant-backed defaults and keeps literal align" do
      payload = FlatPack::ComponentCatalog.show("EmailCard::Component")
      max_width = parameter_named(payload, "max_width")
      padding = parameter_named(payload, "padding")
      align = parameter_named(payload, "align")

      refute max_width.key?(:default)
      refute padding.key?(:default)
      assert_equal "center", align.fetch(:default)
    end

    test "show does not invent defaults for required kwargs" do
      payload = FlatPack::ComponentCatalog.show("Button::Pill::Component")
      items = parameter_named(payload, "items")
      system_arguments = parameter_named(payload, "system_arguments")

      assert items.fetch(:required)
      refute items.key?(:default)
      refute system_arguments.key?(:default)
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

    test "show Card maps registered *_slot names to public ERB methods" do
      payload = FlatPack::ComponentCatalog.show("Card::Component")
      slots = payload.fetch(:slots)

      assert_equal(
        [
          {name: "body", collection: false},
          {name: "footer", collection: false},
          {name: "header", collection: false},
          {name: "media", collection: false}
        ],
        slots
      )
      refute(slots.any? { |slot| slot.fetch(:name).end_with?("_slot") })
    end

    test "show Button and Avatar advertise an empty slots array" do
      button = FlatPack::ComponentCatalog.show("Button::Component")
      avatar = FlatPack::ComponentCatalog.show("Avatar::Component")

      assert_equal [], button.fetch(:slots)
      assert_equal [], avatar.fetch(:slots)
    end

    test "show Button includes erb examples from the first Example section" do
      examples = FlatPack::ComponentCatalog.show("Button::Component").fetch(:examples)

      assert_operator examples.size, :>=, 1
      examples.each do |example|
        assert_equal %i[erb], example.keys
        assert_includes example.fetch(:erb), "FlatPack::Button::Component"
      end
      assert(
        examples.any? { |example| example.fetch(:erb).include?("Delete") || example.fetch(:erb).include?("magnifying-glass") }
      )
    end

    test "show Button Pill has no examples because its snippet sits outside Example" do
      payload = FlatPack::ComponentCatalog.show("Button::Pill::Component")

      assert_equal [], payload.fetch(:examples)
    end

    test "show Alert includes at least one example that names the class" do
      examples = FlatPack::ComponentCatalog.show("Alert::Component").fetch(:examples)

      assert_operator examples.size, :>=, 1
      assert_equal %i[erb], examples.first.keys
      assert_includes examples.first.fetch(:erb), "FlatPack::Alert::Component"
    end

    test "show Checkbox has no examples when it shares inputs.md without a named fence" do
      payload = FlatPack::ComponentCatalog.show("Checkbox::Component")

      assert_equal [], payload.fetch(:examples)
    end

    test "reset! clears the doc examples cache" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "snippet.md")
        File.write(path, <<~MD)
          ## Example
          ```erb
          <%= render FlatPack::Button::Component.new(text: "Cached") %>
          ```
        MD

        examples = FlatPack::ComponentCatalog.const_get(:DocExamples)
        first = examples.for(FlatPack::Button::Component, path)
        File.write(path, <<~MD)
          ## Example
          ```erb
          <%= render FlatPack::Button::Component.new(text: "Fresh") %>
          ```
        MD
        cached = examples.for(FlatPack::Button::Component, path)

        assert_includes first.first.fetch(:erb), "Cached"
        assert_includes cached.first.fetch(:erb), "Cached"

        FlatPack::ComponentCatalog.reset!
        fresh = examples.for(FlatPack::Button::Component, path)

        assert_includes fresh.first.fetch(:erb), "Fresh"
      end
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
