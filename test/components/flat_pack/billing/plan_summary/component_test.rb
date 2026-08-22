# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module PlanSummary
      class ComponentTest < ViewComponent::TestCase
        def test_renders_plan_name_price_and_status
          render_inline(Component.new(
            plan_name: "Pro",
            price_text: "$29 / month",
            status: :active,
            renews_on: "Renews 1 Sep 2026"
          ))

          assert_selector "h3", text: "Pro"
          assert_text "$29 / month"
          assert_text "Active"
          assert_text "Renews 1 Sep 2026"
        end

        def test_renders_trial_timing_for_trialing_status
          render_inline(Component.new(
            plan_name: "Pro",
            status: :trialing,
            trial_ends_on: "Trial ends 1 Sep 2026",
            renews_on: "Renews 1 Oct 2026"
          ))

          assert_text "Trial"
          assert_text "Trial ends 1 Sep 2026"
          assert_no_text "Renews 1 Oct 2026"
        end

        def test_renders_actions_slot
          render_inline(Component.new(plan_name: "Pro")) do |summary|
            summary.actions { "Change plan" }
          end

          assert_text "Change plan"
        end

        def test_renders_footer_slot_inside_card_footer
          render_inline(Component.new(plan_name: "Pro")) do |summary|
            summary.actions { "Change plan" }
            summary.footer { '<button type="button">Cancel plan</button>'.html_safe }
          end

          assert_text "Change plan"
          assert_selector "button", text: "Cancel plan"
          html = page.native.to_html
          assert_includes html, "border-t"
          body_html, footer_html = html.split("border-t", 2)
          assert_includes body_html, "Change plan"
          refute_includes body_html, "Cancel plan"
          assert_includes footer_html, "Cancel plan"
          refute_includes footer_html, "Change plan"
        end

        def test_requires_plan_name
          assert_raises(ArgumentError) { Component.new(plan_name: "") }
        end

        def test_status_nil_renders_plan_name_without_status_badge
          render_inline(Component.new(
            plan_name: "Pro",
            price_text: "$29 / month",
            status: nil,
            renews_on: "Renews 1 Sep 2026"
          ))

          assert_selector "h3", text: "Pro"
          assert_text "$29 / month"
          assert_no_text "Active"
          assert_no_text "Trial"
          assert_no_text "Past due"
          assert_no_text "Canceled"
          assert_no_text "Incomplete"
          assert_no_selector "span", text: /\A(Active|Trial|Past due|Canceled|Incomplete)\z/
        end

        def test_status_false_omits_badge_without_raising
          render_inline(Component.new(plan_name: "Pro", status: false))

          assert_selector "h3", text: "Pro"
          assert_no_text "Active"
        end

        def test_rejects_invalid_status
          assert_raises(ArgumentError) { Component.new(plan_name: "Pro", status: :bogus) }
        end
      end
    end
  end
end
