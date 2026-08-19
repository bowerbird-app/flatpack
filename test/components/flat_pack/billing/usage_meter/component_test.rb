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
          assert_selector "[role='progressbar']"
        end

        def test_renders_unlimited_without_progress
          render_inline(Component.new(label: "Storage", used: 2.4, limit: nil, unit: "GB"))

          assert_text "2.4 GB · Unlimited"
          assert_no_selector "[role='progressbar']"
        end

        def test_requires_label
          assert_raises(ArgumentError) { Component.new(label: "", used: 1) }
        end

        def test_rejects_negative_used
          assert_raises(ArgumentError) { Component.new(label: "Seats", used: -1) }
        end
      end
    end
  end
end
