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
