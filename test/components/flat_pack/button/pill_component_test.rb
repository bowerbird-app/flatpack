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
        end

        def test_renders_inactive_pill_item_classes
          render_inline(Component.new(items: [{text: "Tables", href: "/demo/tables"}]))

          assert_selector "a[href='/demo/tables']", text: "Tables"
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
      end
    end
  end
end
