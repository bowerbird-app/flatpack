# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chart
    class ComponentTest < ViewComponent::TestCase
      def test_renders_chart_with_valid_series_array
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series))

        assert_selector "[data-controller='flat-pack--chart']"
      end

      def test_renders_chart_with_valid_series_hash
        series = {name: "Sales", data: [10, 20, 30]}
        render_inline(Component.new(series: series))

        assert_selector "[data-controller='flat-pack--chart']"
      end

      def test_renders_chart_with_line_type
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, type: :line))

        assert_selector "[data-flat-pack--chart-type-value='line']"
      end

      def test_renders_chart_with_bar_type
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, type: :bar))

        assert_selector "[data-flat-pack--chart-type-value='bar']"
      end

      def test_renders_chart_with_area_type
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, type: :area))

        assert_selector "[data-flat-pack--chart-type-value='area']"
      end

      def test_renders_chart_with_donut_type
        series = [44, 55, 41]
        render_inline(Component.new(series: series, type: :donut))

        assert_selector "[data-flat-pack--chart-type-value='donut']"
      end

      def test_renders_chart_with_pie_type
        series = [44, 55, 41]
        render_inline(Component.new(series: series, type: :pie))

        assert_selector "[data-flat-pack--chart-type-value='pie']"
      end

      def test_renders_chart_with_radar_type
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, type: :radar))

        assert_selector "[data-flat-pack--chart-type-value='radar']"
      end

      def test_raises_error_for_invalid_type
        series = [{name: "Sales", data: [10, 20, 30]}]
        error = assert_raises(ArgumentError) do
          Component.new(series: series, type: :invalid)
        end
        assert_match(/Invalid type: invalid/, error.message)
      end

      def test_raises_error_for_invalid_series
        error = assert_raises(ArgumentError) do
          Component.new(series: "invalid")
        end
        assert_match(/series must be an Array or Hash/, error.message)
      end

      def test_raises_error_for_invalid_height
        series = [{name: "Sales", data: [10, 20, 30]}]
        error = assert_raises(ArgumentError) do
          Component.new(series: series, height: -10)
        end
        assert_match(/height must be a positive integer/, error.message)
      end

      def test_raises_error_for_non_integer_height
        series = [{name: "Sales", data: [10, 20, 30]}]
        error = assert_raises(ArgumentError) do
          Component.new(series: series, height: "280")
        end
        assert_match(/height must be a positive integer/, error.message)
      end

      def test_renders_chart_with_custom_height
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, height: 400))

        assert_selector "[data-flat-pack--chart-height-value='400']"
      end

      def test_renders_chart_with_default_height
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series))

        assert_selector "[data-flat-pack--chart-height-value='280']"
      end

      def test_renders_chart_with_custom_options
        series = [{name: "Sales", data: [10, 20, 30]}]
        options = {chart: {toolbar: {show: true}}}
        render_inline(Component.new(series: series, options: options))

        html = page.native.to_html
        assert_includes html, '"toolbar":{"show":true}'
      end

      def test_renders_chart_wrapped_in_card_by_default
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series))

        assert_selector "div[data-controller*='flat-pack--card']"
      end

      def test_renders_chart_without_card
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, card: false))

        refute_selector "div[data-controller*='flat-pack--card']"
        assert_selector "[data-controller='flat-pack--chart']"
      end

      def test_renders_chart_with_title
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, title: "Sales Chart"))

        assert_selector "h3", text: "Sales Chart"
      end

      def test_renders_chart_with_subtitle
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, title: "Sales", subtitle: "Monthly data"))

        assert_selector "p", text: "Monthly data"
      end

      def test_renders_chart_with_actions_slot
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series)) do |component|
          component.with_actions { "Export" }
        end

        assert_selector "div", text: "Export"
      end

      def test_renders_chart_with_footer_slot
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series)) do |component|
          component.with_footer { "Last updated today" }
        end

        assert_selector "div", text: "Last updated today"
      end

      def test_chart_data_contains_json_series
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series))

        html = page.native.to_html
        assert_includes html, "data-flat-pack--chart-series-value"
        assert_includes html, '"name":"Sales"'
        assert_includes html, '"data":[10,20,30]'
      end

      def test_chart_options_contains_default_options
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series))

        html = page.native.to_html
        assert_includes html, "data-flat-pack--chart-options-value"
        assert_includes html, '"fontFamily":"inherit"'
      end

      def test_default_type_is_line
        series = [{name: "Sales", data: [10, 20, 30]}]
        component = Component.new(series: series)
        render_inline(component)

        assert_selector "[data-flat-pack--chart-type-value='line']"
      end

      def test_merges_custom_options_with_defaults
        series = [{name: "Sales", data: [10, 20, 30]}]
        options = {grid: {show: false}}
        render_inline(Component.new(series: series, options: options))

        html = page.native.to_html
        # Should still have default options
        assert_includes html, '"fontFamily":"inherit"'
        # Should also have custom options
        assert_includes html, '"show":false'
      end

      def test_donut_defaults_do_not_include_axis_options
        series = [44, 55, 41]
        render_inline(Component.new(series: series, type: :donut))

        html = page.native.to_html
        assert_includes html, '"stroke":{"width":1}'
        refute_includes html, '"xaxis"'
        refute_includes html, '"yaxis"'
        refute_includes html, '"grid"'
        refute_includes html, '"curve":"smooth"'
      end

      def test_line_defaults_include_axis_options
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, type: :line))

        html = page.native.to_html
        assert_includes html, '"xaxis"'
        assert_includes html, '"yaxis"'
        assert_includes html, '"grid"'
        assert_includes html, '"curve":"smooth"'
      end

      def test_renders_chart_with_all_options
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(
          series: series,
          type: :bar,
          height: 350,
          card: true,
          title: "Test Chart",
          subtitle: "Test subtitle",
          options: {chart: {stacked: true}}
        ))

        assert_selector "h3", text: "Test Chart"
        assert_selector "p", text: "Test subtitle"
        assert_selector "[data-flat-pack--chart-type-value='bar']"
        assert_selector "[data-flat-pack--chart-height-value='350']"
      end

      def test_chart_without_card_applies_correct_container_classes
        series = [{name: "Sales", data: [10, 20, 30]}]
        render_inline(Component.new(series: series, card: false))

        assert_selector "div.w-full [data-controller='flat-pack--chart']"
      end
    end
  end
end
