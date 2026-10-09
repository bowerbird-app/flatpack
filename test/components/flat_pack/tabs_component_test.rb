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
        assert_includes tablist[:class], "[border-radius:var(--tabs-pill-corner-radius)]"
        assert_includes page.first("button[role='tab']")[:class], "[border-radius:var(--tabs-pill-corner-radius)]"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]\""
        assert_includes page.native.to_html, "data-flat-pack-tabs-inactive-classes=\"border-transparent text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]\""
      end

      def test_stacked_variant_reuses_pill_theme_tokens
        render_inline(Component.new(variant: :stacked)) do |tabs|
          tabs.tab(id: "one", label: "One")
          tabs.tab(id: "two", label: "Two")

          tabs.panel(id: "one") { "One panel" }
          tabs.panel(id: "two") { "Two panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_includes tablist[:class], "bg-[var(--tabs-stacked-pill-list-background-color)]"
        assert_includes tablist[:class], "border-[var(--tabs-pill-list-border-color)]"
        assert_includes tablist[:class], "[border-radius:1.5rem]"
        assert_includes tablist[:class].split, "fp-pill-style"
        refute_includes tablist[:class].split, "fp-pill-button-slots"
        assert_equal "primary", tablist["data-fp-style"]
        assert_includes page.first("button[role='tab']")[:class], "[border-radius:var(--tabs-pill-corner-radius)]"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"border border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]\""
        assert_includes page.native.to_html, "data-flat-pack-tabs-inactive-classes=\"border border-transparent text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]\""
      end

      def test_pills_omit_style_and_primary_stamp_the_tablist
        [nil, :primary].each do |style|
          arguments = {variant: :pills}
          arguments[:style] = style unless style.nil?

          render_inline(Component.new(**arguments)) do |tabs|
            tabs.tab(id: "alpha", label: "Alpha")
            tabs.panel(id: "alpha") { "Alpha panel" }
          end

          tablist = page.find("div[role='tablist']")
          assert_includes tablist[:class].split, "fp-pill-style"
          refute_includes tablist[:class].split, "fp-pill-button-slots"
          assert_equal "primary", tablist["data-fp-style"]
          assert_nil tablist[:style]
          assert_nil page.find("[data-controller='flat-pack--tabs']")[:style]
          assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]\""
        end
      end

      def test_pills_default_style_sets_data_fp_style
        render_inline(Component.new(variant: :pills, style: :default)) do |tabs|
          tabs.tab(id: "alpha", label: "Alpha")
          tabs.panel(id: "alpha") { "Alpha panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_equal "default", tablist["data-fp-style"]
        assert_includes tablist[:class].split, "fp-pill-button-slots"
      end

      def test_pills_danger_style_uses_button_slots
        render_inline(Component.new(variant: :pills, style: :danger)) do |tabs|
          tabs.tab(id: "alpha", label: "Alpha")
          tabs.panel(id: "alpha") { "Alpha panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_equal "danger", tablist["data-fp-style"]
        assert_includes tablist[:class].split, "fp-pill-button-slots"
      end

      def test_pills_unknown_style_raises
        error = assert_raises(ArgumentError) { Component.new(variant: :pills, style: :nope) }
        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:nope), error.message
      end

      def test_underline_keeps_its_paint_when_style_is_primary
        render_inline(Component.new(variant: :underline, style: :primary)) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.panel(id: "first") { "First panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_includes tablist[:class], "border-b"
        refute_includes tablist[:class].split, "fp-pill-style"
        assert_nil tablist["data-fp-style"]
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"bg-[var(--surface-background-color)] text-primary border-b-2 border-primary -mb-px\""
      end

      def test_underline_unknown_style_raises
        error = assert_raises(ArgumentError) { Component.new(variant: :underline, style: :nope) }
        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:nope), error.message
      end

      def test_css_string_style_raises_instead_of_rendering
        error = assert_raises(ArgumentError) { Component.new(style: "color: red") }
        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:"color: red"), error.message
      end

      def test_invalid_variant_raises_argument_error
        error = assert_raises(ArgumentError) { Component.new(variant: :unknown) }
        assert_includes error.message, "Invalid variant"
      end

      def test_default_size_is_medium
        render_inline(Component.new) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.panel(id: "first") { "First panel" }
        end

        assert_includes page.first("button[role='tab']")[:class], FlatPack::Shared::PadTextSizes.classes_for(:md)
      end

      def test_renders_small_size
        render_inline(Component.new(size: :sm)) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.panel(id: "first") { "First panel" }
        end

        assert_includes page.first("button[role='tab']")[:class], FlatPack::Shared::PadTextSizes.classes_for(:sm)
      end

      def test_renders_large_size
        render_inline(Component.new(size: :lg)) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.panel(id: "first") { "First panel" }
        end

        assert_includes page.first("button[role='tab']")[:class], FlatPack::Shared::PadTextSizes.classes_for(:lg)
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) { Component.new(size: :xl) }
        assert_includes error.message, "Invalid size"
      end

      def test_omitted_indicator_does_not_render_slide_markup
        render_inline(Component.new) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.tab(id: "second", label: "Second")
          tabs.panel(id: "first") { "First panel" }
          tabs.panel(id: "second") { "Second panel" }
        end

        html = page.native.to_html
        refute_includes html, "fp-slide-indicator"
        refute_includes html, "flat-pack--slide-indicator"
        refute_includes page.first("button[role='tab']")[:class].to_s, "fp-slide-indicator__item"
        assert_includes html, "data-flat-pack-tabs-active-classes=\"bg-[var(--surface-background-color)] text-primary border-b-2 border-primary -mb-px\""
      end

      def test_slide_indicator_underline_renders_bar_and_text_only_tabs
        render_inline(Component.new(indicator: :slide)) do |tabs|
          tabs.tab(id: "first", label: "First")
          tabs.tab(id: "second", label: "Second")
          tabs.panel(id: "first") { "First panel" }
          tabs.panel(id: "second") { "Second panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_includes tablist[:class].split, "fp-slide-indicator-list"
        assert_equal "flat-pack--slide-indicator", tablist["data-controller"]
        assert_equal "underline", tablist["data-flat-pack--slide-indicator-kind-value"]
        assert_selector "span.fp-slide-indicator.fp-slide-indicator--underline[aria-hidden='true']", visible: :all
        assert_includes page.first("button[role='tab']")[:class].split, "fp-slide-indicator__item"
        assert_includes page.first("button[role='tab']")[:class], "text-primary"
        refute_includes page.first("button[role='tab']")[:class], "border-b-2"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"text-primary\""
        assert_selector "button[role='tab'][data-flat-pack--slide-indicator-target='item']", count: 2
      end

      def test_slide_indicator_pills_uses_pill_kind
        render_inline(Component.new(variant: :pills, indicator: :slide)) do |tabs|
          tabs.tab(id: "alpha", label: "Alpha")
          tabs.panel(id: "alpha") { "Alpha panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_equal "pill", tablist["data-flat-pack--slide-indicator-kind-value"]
        assert_includes tablist[:class].split, "fp-pill-style"
        assert_selector "span.fp-slide-indicator--pill", visible: :all
        refute_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"border-[var(--tabs-pill-active-border-color)]"
        assert_includes page.native.to_html, "data-flat-pack-tabs-active-classes=\"text-[var(--tabs-pill-active-text-color)]\""
      end

      def test_slide_indicator_stacked_keeps_vertical_orientation
        render_inline(Component.new(variant: :stacked, indicator: :slide)) do |tabs|
          tabs.tab(id: "one", label: "One")
          tabs.panel(id: "one") { "One panel" }
        end

        tablist = page.find("div[role='tablist']")
        assert_equal "pill", tablist["data-flat-pack--slide-indicator-kind-value"]
        assert_equal "vertical", page.find("[data-controller='flat-pack--tabs']")["data-flat-pack--tabs-orientation-value"]
        assert_includes page.first("button[role='tab']")[:class], "border-transparent"
        assert_includes page.first("button[role='tab']")[:class], "fp-slide-indicator__item"
      end

      def test_invalid_indicator_raises_argument_error
        error = assert_raises(ArgumentError) { Component.new(indicator: :bounce) }
        assert_includes error.message, "Invalid indicator"
      end
    end
  end
end
