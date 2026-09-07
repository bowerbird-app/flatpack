# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Stepper
    class ComponentTest < ViewComponent::TestCase
      def test_renders_current_step
        render_inline(Component.new(steps: ["Details", "Review", "Done"], current_step: 2))

        assert_selector "ol[aria-label='Progress']"
        assert_selector "li[data-status='complete']", text: "Details"
        assert_selector "p[aria-current='step']", text: "Review"
        assert_selector "li[data-status='upcoming']", text: "Done"
      end

      def test_vertical_with_href
        render_inline(Component.new(
          orientation: :vertical,
          current_step: 1,
          steps: [
            {label: "Account", href: "/demo/forms"},
            {label: "Finish"}
          ]
        ))

        assert_selector "a[href='/demo/forms']", text: "Account"
      end

      def test_current_step_out_of_bounds_raises
        error = assert_raises(ArgumentError) { Component.new(steps: ["A", "B"], current_step: 3) }

        assert_match(/current_step must be between/, error.message)
      end

      def test_too_few_steps_raises
        error = assert_raises(ArgumentError) { Component.new(steps: ["Only"]) }

        assert_match(/at least two labels/, error.message)
      end
    end
  end
end
