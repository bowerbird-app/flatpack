# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Card
    module Stat
      class ComponentTest < ViewComponent::TestCase
        def test_label_is_sentence_case_and_value_is_tabular
          render_inline(Component.new(
            value: "$12,400",
            label: "Monthly revenue",
            trend: "+4%",
            trend_direction: :up
          ))

          html = page.native.to_html
          refute_includes html, "uppercase"
          refute_includes html, "tracking-wide"
          assert_includes html, "fp-tabular-nums"
          assert_selector "div", text: "Monthly revenue"
          assert_selector "div", text: "$12,400"
        end
      end
    end
  end
end
