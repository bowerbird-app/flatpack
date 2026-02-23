# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Tabs
    class ComponentTest < ViewComponent::TestCase
      def test_renders_tablist_tabs_and_panels
        render_inline(Component.new) do |tabs|
          tabs.tab(id: "overview", label: "Overview")
          tabs.tab(id: "details", label: "Details")

          tabs.panel(id: "overview") { "Overview panel" }
          tabs.panel(id: "details") { "Details panel" }
        end

        assert_selector "div[role='tablist']"
        assert_selector "button[role='tab']", count: 2
        assert_selector "div[role='tabpanel']", count: 2, visible: :all
      end

      def test_underline_variant_is_default
        render_inline(Component.new) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.tab(id: "second", label: "Second")

          tabs.panel(id: "first") { "First panel" }
          tabs.panel(id: "second") { "Second panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_includes tablist[:class], "border-b"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"bg-[var(--surface-background-color)] text-primary border-b-2 border-primary -mb-px\""
      end

      def test_pills_variant_applies_pill_classes
        render_inline(Component.new(variant: :pills)) do |tabs|
          tabs.tab(id: "alpha", label: "Alpha")
          tabs.tab(id: "beta", label: "Beta")

          tabs.panel(id: "alpha") { "Alpha panel" }
          tabs.panel(id: "beta") { "Beta panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_includes tablist[:class], "rounded-full"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]\""
      end

      def test_invalid_variant_raises_argument_error
        error = assert_raises(ArgumentError) { Component.new(variant: :unknown) }
        assert_includes error.message, "Invalid variant"
      end
    end
  end
end