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

        def test_requires_plan_name
          assert_raises(ArgumentError) { Component.new(plan_name: "") }
        end

        def test_rejects_invalid_status
          error = assert_raises(ArgumentError) { Component.new(plan_name: "Pro", status: :canceling) }

          assert_match(/Invalid status/, error.message)
          assert_match(/active/, error.message)
        end

        def test_renders_period_end_and_scheduled_change_without_changing_status
          render_inline(Component.new(
            plan_name: "Pro",
            price_text: "$29 / month",
            status: :active,
            renews_on: "Renews 1 Dec 2026",
            ends_on: Date.new(2026, 12, 1),
            scheduled_change_text: "Changes to Basic on 1 Dec",
            badges: [{text: "Annual", style: :info}]
          ))

          assert_text "Active"
          assert_text "Renews 1 Dec 2026"
          assert_text "Ends 1 Dec 2026"
          assert_text "Changes to Basic on 1 Dec"
          assert_text "Cancels at period end"
          assert_text "Annual"
          assert_selector ".bg-\\[var\\(--badge-success-background-color\\)\\]", text: "Active"
          assert_selector ".bg-\\[var\\(--badge-warning-background-color\\)\\]", text: "Cancels at period end"
          assert_selector ".bg-\\[var\\(--badge-info-background-color\\)\\]", text: "Annual"
          assert_no_text "canceling"
        end

        def test_scheduled_change_without_ends_on_skips_the_cancel_badge
          render_inline(Component.new(
            plan_name: "Pro",
            status: :active,
            scheduled_change_text: "Changes to Basic on 1 Dec",
            badges: [{text: "Team", style: "primary"}]
          ))

          assert_text "Changes to Basic on 1 Dec"
          assert_text "Team"
          assert_no_text "Cancels at period end"
          assert_no_text "Ends "
        end

        def test_accepts_a_time_for_ends_on
          render_inline(Component.new(
            plan_name: "Pro",
            status: :trialing,
            trial_ends_on: "Trial ends 1 Sep 2026",
            ends_on: Time.utc(2026, 12, 1, 15, 0, 0)
          ))

          assert_text "Trial"
          assert_text "Trial ends 1 Sep 2026"
          assert_text "Ends 1 Dec 2026"
          assert_text "Cancels at period end"
        end

        def test_french_period_end_copy
          I18n.with_locale(:fr) do
            render_inline(Component.new(
              plan_name: "Pro",
              status: :active,
              ends_on: Date.new(2026, 12, 1)
            ))
          end

          assert_text "Actif"
          assert_text "Annule en fin de période"
          assert_text "Fin le 1 Dec 2026"
          assert_no_text "Cancels at period end"
        end

        def test_rejects_a_string_ends_on
          error = assert_raises(ArgumentError) do
            Component.new(plan_name: "Pro", ends_on: "1 Dec 2026")
          end

          assert_equal "ends_on must be a date", error.message
        end

        def test_rejects_a_badge_without_text
          error = assert_raises(ArgumentError) do
            Component.new(plan_name: "Pro", badges: [{style: :info}])
          end

          assert_equal "badge text is required", error.message
        end

        def test_rejects_an_unknown_badge_style
          error = assert_raises(ArgumentError) do
            Component.new(plan_name: "Pro", badges: [{text: "Annual", style: :stripe}])
          end

          assert_match(/Invalid badge style/, error.message)
        end

        def test_rejects_badges_that_are_not_an_array
          assert_raises(ArgumentError) do
            Component.new(plan_name: "Pro", badges: {text: "Annual", style: :info})
          end
        end
      end
    end
  end
end
