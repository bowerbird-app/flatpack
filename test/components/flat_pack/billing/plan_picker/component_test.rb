# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module PlanPicker
      class ComponentTest < ViewComponent::TestCase
        def test_renders_plan_cards
          render_inline(Component.new(items: [
            {name: "Basic", price_text: "$9 / month", features: ["3 seats"], href: "/plans/basic"},
            {name: "Pro", price_text: "$29 / month", current: true, highlighted: true, cta_text: "Current plan"}
          ]))

          assert_text "Basic"
          assert_text "Pro"
          assert_text "Popular"
          assert_text "Current"
          assert_text "Current plan"
          assert_text "3 seats"
        end

        def test_current_without_cta_keeps_footer_spacer
          render_inline(Component.new(items: [
            {name: "Monthly plan", price_text: "$49 / month", current: true, cta: false, features: ["Priority support"]}
          ]))

          assert_text "Monthly plan"
          assert_text "Current"
          assert_no_text "Current plan"
          assert_no_text "Get started"
          assert_no_selector "button"
          assert_no_selector "a[href]"
          assert_selector "[data-flat-pack-plan-picker='cta-spacer']"
          assert_selector "[data-flat-pack-plan-picker='cta-spacer'][aria-hidden='true']"
          assert_includes page.native.to_html, "min-h-[calc(1.25rem+2*var(--button-padding-y-md)+2px)]"
          assert_selector ".border-t.border-\\[var\\(--card-border-color\\)\\]"
        end

        def test_cta_text_false_omits_button
          render_inline(Component.new(items: [
            {name: "Monthly plan", current: true, cta_text: false}
          ]))

          assert_text "Current"
          assert_no_text "Current plan"
          assert_no_selector "button"
          assert_selector "[data-flat-pack-plan-picker='cta-spacer']"
        end

        def test_current_with_cta_renders_secondary_button
          render_inline(Component.new(items: [
            {name: "Pro", price_text: "$29 / month", current: true, href: "/plans/pro"}
          ]))

          assert_text "Current"
          assert_selector "a[href='/plans/pro']", text: "Current plan"
          assert_includes page.native.to_html, "bg-[var(--button-secondary-background-color)]"
          assert_no_selector "[data-flat-pack-plan-picker='cta-spacer']"
        end

        def test_highlighted_plan_renders_popular_badge
          render_inline(Component.new(items: [
            {name: "Monthly plan", price_text: "$1 / month", highlighted: true, href: "/plans/monthly", cta_text: "Choose this plan"}
          ]))

          assert_text "Popular"
          assert_no_text "Current"
          assert_selector "a[href='/plans/monthly']", text: "Choose this plan"
          assert_includes page.native.to_html, "border-[var(--color-primary)]"
          assert_includes page.native.to_html, "bg-[var(--button-primary-background-color)]"
        end

        def test_requires_item_name
          assert_raises(ArgumentError) { Component.new(items: [{price_text: "$9"}]) }
        end

        def test_rejects_unsafe_href
          assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", href: "javascript:alert(1)"}])
          end
        end
      end
    end
  end
end
