# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module UsageMeter
      class ComponentTest < ViewComponent::TestCase
        def test_renders_limited_usage
          render_inline(Component.new(label: "Seats", used: 8, limit: 10, unit: "seats"))

          assert_text "Seats"
          assert_text "8 of 10 seats"
          assert_selector "[role='progressbar']", count: 1
        end

        def test_renders_unlimited_without_progress
          render_inline(Component.new(label: "Storage", used: 2.4, limit: nil, unit: "GB"))

          assert_text "2.4 GB · Unlimited"
          assert_no_selector "[role='progressbar']"
        end

        def test_limit_zero_renders_none_on_plan_without_progress
          render_inline(Component.new(label: "Exports", used: 0, limit: 0, unit: "exports"))

          assert_text "Exports"
          assert_text "None on plan"
          assert_no_text "0 of 0"
          assert_no_selector "[role='progressbar']"
          assert_no_selector ".fp-progress-fill"
        end

        def test_limit_zero_ignores_used_count_in_the_helper
          render_inline(Component.new(label: "Exports", used: 4, limit: 0))

          assert_text "None on plan"
          assert_no_text "4"
          assert_no_selector "[role='progressbar']"
        end

        def test_default_warning_ratio_is_eighty_percent
          render_inline(Component.new(label: "Seats", used: 7, limit: 10))

          assert_no_selector ".fp-progress-fill--warning"
          assert_no_selector ".fp-progress-fill--danger"

          render_inline(Component.new(label: "Seats", used: 8, limit: 10))

          assert_selector ".fp-progress-fill--warning"
          assert_no_selector ".fp-progress-fill--danger"
        end

        def test_over_limit_stays_danger
          render_inline(Component.new(label: "Storage", used: 10, limit: 10, unit: "GB"))

          assert_selector ".fp-progress-fill--danger"
          assert_no_selector ".fp-progress-fill--warning"

          render_inline(Component.new(label: "Storage", used: 12, limit: 10, unit: "GB", warning_ratio: 0.5))

          assert_selector ".fp-progress-fill--danger"
          assert_no_selector ".fp-progress-fill--warning"
        end

        def test_warning_ratio_moves_the_warning_line
          render_inline(Component.new(label: "Minutes", used: 4, limit: 10, warning_ratio: 0.5))

          assert_no_selector ".fp-progress-fill--warning"

          render_inline(Component.new(label: "Minutes", used: 5, limit: 10, warning_ratio: 0.5))

          assert_selector ".fp-progress-fill--warning"
          assert_no_selector ".fp-progress-fill--danger"
        end

        def test_warning_ratio_of_one_never_warns_before_danger
          render_inline(Component.new(label: "Seats", used: 9, limit: 10, warning_ratio: 1))

          assert_no_selector ".fp-progress-fill--warning"
          assert_no_selector ".fp-progress-fill--danger"
        end

        def test_included_and_purchased_sum_to_one_bar
          render_inline(Component.new(label: "API calls", used: 80, included: 100, purchased: 50, unit: "calls"))

          assert_text "80 of 150 calls"
          assert_text "100 included + 50 purchased"
          assert_selector "[role='progressbar']", count: 1
          assert_selector "[role='progressbar'][aria-valuemax='150.0']"
          assert_selector ".fp-progress-fill", count: 1
          assert_no_selector ".fp-progress-fill--warning"
          assert_no_selector ".fp-progress-fill--danger"
        end

        def test_breakdown_formats_whole_floats_and_keeps_fractions
          render_inline(Component.new(label: "API calls", used: 1, included: 100.0, purchased: 50.0))

          assert_text "1 of 150"
          assert_text "100 included + 50 purchased"

          render_inline(Component.new(label: "Storage", used: 1, included: 1.5, purchased: 2.25, unit: "GB"))

          assert_text "1 of 3.75 GB"
          assert_text "1.5 included + 2.25 purchased"
          assert_selector "[role='progressbar']", count: 1
        end

        def test_zero_allowance_pair_renders_none_on_plan
          render_inline(Component.new(label: "Exports", used: 0, included: 0, purchased: 0))

          assert_text "None on plan"
          assert_no_text "included"
          assert_no_selector "[role='progressbar']"
        end

        def test_french_none_on_plan
          I18n.with_locale(:fr) do
            render_inline(Component.new(label: "Exports", used: 0, limit: 0))
          end

          assert_text "Aucun dans le forfait"
          assert_no_text "None on plan"
        end

        def test_french_breakdown
          I18n.with_locale(:fr) do
            render_inline(Component.new(label: "Appels", used: 80, included: 100, purchased: 50, unit: "appels"))
          end

          assert_text "80 sur 150 appels"
          assert_text "100 inclus + 50 achetés"
          assert_no_text "included"
        end

        def test_requires_label
          assert_raises(ArgumentError) { Component.new(label: "", used: 1) }
        end

        def test_rejects_negative_used
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: -1) }
        end

        def test_rejects_negative_limit
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 0, limit: -1) }
        end

        def test_rejects_warning_ratio_outside_zero_to_one
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 1, limit: 10, warning_ratio: -0.1) }
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 1, limit: 10, warning_ratio: 1.1) }
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 1, limit: 10, warning_ratio: "high") }
        end

        def test_requires_included_and_purchased_together
          error = assert_raises(ArgumentError) { Component.new(label: "Seats", used: 1, included: 10) }
          assert_equal "included and purchased must both be set", error.message

          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 1, purchased: 10) }
        end

        def test_rejects_limit_with_included_and_purchased
          error = assert_raises(ArgumentError) do
            Component.new(label: "Seats", used: 1, limit: 150, included: 100, purchased: 50)
          end
          assert_equal "pass limit or included and purchased, not both", error.message
        end

        def test_rejects_negative_included_or_purchased
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 0, included: -1, purchased: 5) }
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 0, included: 5, purchased: -1) }
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: 0, included: "100", purchased: 50) }
        end
      end
    end
  end
end
