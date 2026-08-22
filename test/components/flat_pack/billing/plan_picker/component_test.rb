# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module PlanPicker
      class ComponentTest < ViewComponent::TestCase
        def test_renders_plan_cards
          render_inline(Component.new(items: [
            {name: "Basic", price_text: "$9 / month", features: ["3 seats"], href: "/plans/basic"},
            {name: "Pro", price_text: "$29 / month", current: true, highlighted: true}
          ]))

          assert_text "Basic"
          assert_text "Pro"
          assert_text "Popular"
          assert_text "3 seats"
          assert_selector "a[href='/plans/basic']", text: "Choose plan"
          assert_selector "button[disabled]", text: "Current"
        end

        def test_default_choose_label_is_choose_plan
          render_inline(Component.new(items: [
            {name: "Basic", price_text: "$9 / month", href: "/plans/basic"}
          ]))

          assert_selector "a[href='/plans/basic']", text: "Choose plan"
          assert_no_text "Choose this plan"
          assert_no_text "Get started"
        end

        def test_current_renders_disabled_button_not_badge
          render_inline(Component.new(items: [
            {name: "Pro", price_text: "$29 / month", current: true, href: "/plans/pro"}
          ]))

          assert_selector "button[disabled]", text: "Current"
          assert_includes page.native.to_html, "bg-[var(--button-secondary-background-color)]"
          assert_includes page.native.to_html, "disabled:opacity-[var(--button-disabled-opacity)]"
          assert_no_selector "a[href='/plans/pro']"
          assert_no_selector "a", text: "Current"
          assert_no_text "Current plan"
          assert_no_includes_success_badge
          assert_no_plan_footer
        end

        def test_current_highlighted_keeps_popular_badge_only
          render_inline(Component.new(items: [
            {name: "Pro", current: true, highlighted: true}
          ]))

          assert_text "Popular"
          assert_selector "button[disabled]", text: "Current"
          assert_includes page.native.to_html, "bg-[var(--badge-primary-background-color)]"
          assert_no_includes_success_badge
        end

        def test_cta_false_omits_button_and_footer
          render_inline(Component.new(items: [
            {name: "Monthly plan", price_text: "$49 / month", current: true, cta: false, features: ["Priority support"]}
          ]))

          assert_text "Monthly plan"
          assert_no_text "Choose plan"
          assert_no_text "Current"
          assert_no_text "Current plan"
          assert_no_text "Get started"
          assert_no_selector "button"
          assert_no_selector "a[href]"
          assert_no_plan_footer
        end

        def test_cta_text_false_omits_button
          render_inline(Component.new(items: [
            {name: "Monthly plan", current: true, cta_text: false}
          ]))

          assert_text "Monthly plan"
          assert_no_text "Current"
          assert_no_selector "button"
          assert_no_plan_footer
        end

        def test_custom_cta_text_still_applies
          render_inline(Component.new(items: [
            {name: "Enterprise", href: "/billing/contact", cta_text: "Contact sales"}
          ]))

          assert_selector "a[href='/billing/contact']", text: "Contact sales"
        end

        def test_highlighted_plan_renders_popular_badge
          render_inline(Component.new(items: [
            {name: "Monthly plan", price_text: "$1 / month", highlighted: true, href: "/plans/monthly"}
          ]))

          assert_text "Popular"
          assert_no_selector "button[disabled]", text: "Current"
          assert_selector "a[href='/plans/monthly']", text: "Choose plan"
          assert_includes page.native.to_html, "bg-[var(--badge-primary-background-color)]"
          assert_includes page.native.to_html, "bg-[var(--button-primary-background-color)]"
        end

        def test_cta_renders_in_card_body_after_features
          render_inline(Component.new(items: [
            {name: "Basic", features: ["3 seats"], href: "/plans/basic"}
          ]))

          html = page.native.to_html
          assert html.index("3 seats") < html.index("Choose plan")
          assert_no_plan_footer
        end

        def test_requires_item_name
          assert_raises(ArgumentError) { Component.new(items: [{price_text: "$9"}]) }
        end

        def test_rejects_unsafe_href
          assert_raises(ArgumentError) do
            Component.new(items: [{name: "Pro", href: "javascript:alert(1)"}])
          end
        end

        private

        def assert_no_plan_footer
          assert_no_selector "[data-flat-pack-plan-picker='cta-spacer']"
          assert_no_selector ".border-t.border-\\[var\\(--card-border-color\\)\\]"
        end

        def assert_no_includes_success_badge
          assert_not_includes page.native.to_html, "bg-[var(--badge-success-background-color)]"
        end
      end
    end
  end
end
