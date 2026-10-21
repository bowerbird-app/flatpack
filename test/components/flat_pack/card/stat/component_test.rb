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
          assert_includes html, 'data-background="default"'
          assert_includes html, "[background:var(--card-background-default)]"
        end

        def test_style_paints_the_stat_surface
          render_inline(Component.new(
            value: "86",
            label: "New members",
            trend: "+12%",
            trend_direction: :up,
            background: :gradient
          ))

          html = page.native.to_html
          assert_includes html, "[background:var(--card-background-gradient)]"
          assert_includes html, 'data-background="gradient"'
          refute_includes html, "uppercase"
        end

        def test_rejects_removed_theme_option
          error = assert_raises(ArgumentError) do
            Component.new(
              value: "1",
              label: "Count",
              trend: "0",
              trend_direction: :up,
              theme: {background: "#101820"}
            )
          end

          assert_includes error.message, "unknown keyword"
          assert_includes error.message, "theme"
        end
      end
    end
  end
end
