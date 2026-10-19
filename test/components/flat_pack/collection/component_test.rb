# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Collection
    class ComponentTest < ViewComponent::TestCase
      def test_renders_a_list_item_for_each_with_item
        render_inline(Component.new) do |collection|
          collection.with_item { "Logos" }
          collection.with_item { "Photos" }
        end

        assert_selector "ul.flex.flex-col.gap-4.list-none > li", count: 2
        assert_selector "ul > li", text: "Logos"
        assert_selector "ul > li", text: "Photos"
        refute_selector "nav"
      end

      def test_grid_uses_auto_fill_and_the_default_min_item_width
        render_inline(Component.new(layout: :grid)) do |collection|
          collection.with_item { "Logos" }
        end

        html = page.native.to_html
        assert_selector "ul.grid.items-stretch.gap-4"
        assert_includes html, "grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]"
        assert_includes html, "--fp-collection-min-item-width: 14rem"
        refute_includes html, "minmax(14rem"
        assert_selector "li.flex.items-stretch"
        item_class = page.find("ul > li")[:class]
        assert_includes item_class, "[&>*]:w-full"
        assert_includes item_class, "[&>*]:flex-1"
        assert_includes item_class, "[&>*]:self-stretch"
        assert_includes item_class, "[&>*]:min-w-0"
      end

      def test_grid_accepts_a_custom_min_item_width
        render_inline(Component.new(layout: :grid, min_item_width: "18rem", gap: :sm)) do |collection|
          collection.with_item { "Logos" }
        end

        html = page.native.to_html
        assert_includes html, "--fp-collection-min-item-width: 18rem"
        assert_selector "ul.gap-2"
        refute_includes html, "18rem,1fr"
      end

      def test_wrap_is_an_inline_row
        render_inline(Component.new(layout: :wrap, gap: :lg)) do |collection|
          collection.with_item { "Print" }
          collection.with_item { "Web" }
        end

        assert_selector "ul.flex.flex-wrap.items-center.gap-6 > li.flex", count: 2
        html = page.native.to_html
        refute_includes html, "--fp-collection-min-item-width"
        refute_includes html, "grid-cols-"
      end

      def test_nav_wraps_the_list_and_requires_a_label
        render_inline(Component.new(as: :nav, label: "Press kit", layout: :grid)) do |collection|
          collection.with_item { "Logos" }
        end

        assert_selector "nav[aria-label='Press kit'] > ul > li", text: "Logos"
      end

      def test_nav_without_a_label_raises
        error = assert_raises(ArgumentError) { Component.new(as: :nav, layout: :grid) }
        assert_match(/label/, error.message)
      end

      def test_blank_nav_label_raises
        error = assert_raises(ArgumentError) { Component.new(as: :nav, label: "  ") }
        assert_match(/label/, error.message)
      end

      def test_label_without_nav_raises
        error = assert_raises(ArgumentError) { Component.new(label: "Press kit") }
        assert_match(/label/, error.message)
      end

      def test_min_item_width_is_only_for_grid
        error = assert_raises(ArgumentError) { Component.new(layout: :wrap, min_item_width: "12rem") }
        assert_match(/min_item_width/, error.message)

        error = assert_raises(ArgumentError) { Component.new(layout: :grid, min_item_width: "wide") }
        assert_match(/min_item_width/, error.message)
      end

      def test_invalid_as_layout_and_gap
        error = assert_raises(ArgumentError) { Component.new(as: :ol) }
        assert_match(/as/, error.message)

        error = assert_raises(ArgumentError) { Component.new(layout: :columns) }
        assert_match(/layout/, error.message)

        error = assert_raises(ArgumentError) { Component.new(gap: :xl) }
        assert_match(/gap/, error.message)
      end

      def test_press_kit_menu_marks_one_current_link
        render_inline(Component.new(as: :nav, label: "Press kit", layout: :grid)) do |collection|
          collection.with_item { menu_button("Logos", current: true) }
          collection.with_item { menu_button("Photos", current: false) }
        end

        assert_selector "nav[aria-label='Press kit'] ul.grid > li", count: 2
        assert_selector "a[aria-current='page'].fp-button-current", text: "Logos"
        assert_selector "a[href='/photos']", text: "Photos"
        refute_selector "a[href='/photos'][aria-current]"
        assert_selector "a svg[aria-hidden='true']", count: 2
        assert_selector "span.shrink-0", text: "4", count: 2
        assert_includes page.native.to_html, "focus-visible:ring-2"
      end

      def test_kit_css_does_not_center_with_justify_content
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

        refute_includes css, "justify-content: center"
      end

      private

      def menu_button(text, current:)
        vc_test_controller.view_context.render(
          FlatPack::Button::Component.new(
            text: text,
            href: "/#{text.downcase}",
            icon: "photo",
            align: :start,
            lines: 2,
            current: current,
            title: text
          )
        ) do |button|
          button.with_trailing do
            vc_test_controller.view_context.render(FlatPack::Badge::Component.new(text: "4", size: :sm))
          end
        end
      end
    end
  end
end
