# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    module Pill
      class ComponentTest < ViewComponent::TestCase
        def test_renders_pill_group
          render_inline(Component.new(
            id: "pill-group",
            items: [
              {text: "Overview", href: "/demo/buttons", active: true, id: "overview-pill"},
              {text: "Tables", href: "/demo/tables"}
            ]
          ))

          assert_selector "div#pill-group.inline-flex"
          assert_selector "a", count: 2
          assert_selector "a#overview-pill[href='/demo/buttons'][aria-current='page']", text: "Overview"
          assert_includes page.native.to_html, "bg-[var(--tabs-pill-active-background-color)]"
          assert_includes page.native.to_html, "shadow-[var(--tabs-pill-active-shadow)]"
          assert_includes page.native.to_html, "fp-touch-manipulation"
        end

        def test_renders_inactive_pill_item_classes
          render_inline(Component.new(items: [{text: "Tables", href: "/demo/tables"}]))

          assert_selector "a[href='/demo/tables']", text: "Tables"
          assert_includes page.native.to_html, "border-transparent"
          assert_includes page.native.to_html, "text-[var(--tabs-pill-inactive-text-color)]"
          assert_includes page.native.to_html, "hover:bg-[var(--tabs-pill-inactive-hover-background-color)]"
        end

        def test_adds_rel_for_blank_target_item
          render_inline(Component.new(items: [{text: "External", href: "https://example.com", target: "_blank"}]))

          assert_selector "a[href='https://example.com'][target='_blank'][rel='noopener noreferrer']", text: "External"
        end

        def test_requires_items
          error = assert_raises(ArgumentError) do
            Component.new(items: [])
          end

          assert_equal "items must contain at least one pill", error.message
        end

        def test_requires_item_href
          error = assert_raises(ArgumentError) do
            Component.new(items: [{text: "Broken", href: ""}])
          end

          assert_equal "Each pill item must have href", error.message
        end

        def test_requires_item_text
          error = assert_raises(ArgumentError) do
            Component.new(items: [{text: "", href: "/demo/buttons"}])
          end

          assert_equal "Each pill item must have text", error.message
        end

        def test_rejects_unsafe_item_href
          error = assert_raises(ArgumentError) do
            Component.new(items: [{text: "Broken", href: "javascript:alert('xss')"}])
          end

          assert_match(/Unsafe URL detected/, error.message)
        end

        def test_default_size_is_medium
          render_inline(Component.new(items: [{text: "Overview", href: "/demo/buttons"}]))

          assert_includes page.native.to_html, FlatPack::Shared::PadTextSizes.classes_for(:md)
        end

        def test_renders_small_size
          render_inline(Component.new(size: :sm, items: [{text: "Overview", href: "/demo/buttons"}]))

          assert_includes page.native.to_html, FlatPack::Shared::PadTextSizes.classes_for(:sm)
        end

        def test_renders_large_size
          render_inline(Component.new(size: :lg, items: [{text: "Overview", href: "/demo/buttons"}]))

          assert_includes page.native.to_html, FlatPack::Shared::PadTextSizes.classes_for(:lg)
        end

        def test_raises_error_for_invalid_size
          error = assert_raises(ArgumentError) do
            Component.new(size: :xl, items: [{text: "Overview", href: "/demo/buttons"}])
          end

          assert_includes error.message, "Invalid size"
        end

        def test_omitted_style_and_primary_stamp_the_group
          [nil, :primary].each do |style|
            arguments = {
              data: {fp_style: "ghost"},
              items: [{text: "Overview", href: "/demo/buttons", active: true}]
            }
            arguments[:style] = style unless style.nil?

            render_inline(Component.new(**arguments))

            group = page.find("div.fp-pill-style")
            assert_equal "primary", group["data-fp-style"]
            assert_includes group[:class].split, "fp-pill-style"
            refute_includes group[:class].split, "fp-pill-button-slots"
            assert_includes page.native.to_html, "bg-[var(--tabs-pill-active-background-color)]"
          end
        end

        def test_default_style_sets_data_fp_style
          render_inline(Component.new(
            style: :default,
            items: [{text: "Overview", href: "/demo/buttons", active: true}]
          ))

          group = page.find("div.fp-pill-style")
          assert_equal "default", group["data-fp-style"]
          assert_includes group[:class].split, "fp-pill-button-slots"
        end

        def test_danger_style_uses_button_slots
          render_inline(Component.new(
            style: :danger,
            items: [{text: "Overview", href: "/demo/buttons", active: true}]
          ))

          group = page.find("div.fp-pill-style")
          assert_equal "danger", group["data-fp-style"]
          assert_includes group[:class].split, "fp-pill-button-slots"
        end

        def test_unknown_style_raises_the_registry_message
          error = assert_raises(ArgumentError) do
            Component.new(style: :nope, items: [{text: "Overview", href: "/demo/buttons"}])
          end

          assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:nope), error.message
        end

        def test_group_does_not_use_the_button_class
          render_inline(Component.new(items: [
            {text: "Overview", href: "/demo/buttons", active: true},
            {text: "Tables", href: "/demo/tables"}
          ]))

          classes = page.native.to_html.scan(/class="([^"]*)"/).flatten.flat_map(&:split)
          refute_includes classes, "fp-button"
          refute_includes classes, "fp-button-raised"
          refute_includes classes, "fp-button-flat"
          assert_includes classes, "fp-pill-style"
        end
      end
    end
  end
end
