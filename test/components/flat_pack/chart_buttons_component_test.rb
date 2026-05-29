# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ChartButtons
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_with_container_turbo_defaults
        render_inline(Component.new(turbo_frame: "chart-frame")) do |controls|
          controls.button(text: "Day", url: "/demo/charts?period=day", selected: true)
        end

        assert_selector "div.flex.flex-wrap.items-center.gap-2.mb-3"
        assert_selector "a[href='/demo/charts?period=day'][data-turbo-frame='chart-frame'][data-turbo-prefetch='false'][aria-pressed='true']", text: "Day"
      end

      def test_allows_margin_bottom_override
        render_inline(Component.new(margin_bottom: "mb-6")) do |controls|
          controls.button(text: "Day", url: "/demo/charts?period=day")
        end

        assert_selector "div.flex.flex-wrap.items-center.gap-2.mb-6"
        assert_no_selector "div.mb-3"
      end

      def test_button_allows_turbo_frame_override
        render_inline(Component.new(turbo_frame: "chart-frame")) do |controls|
          controls.button(
            text: "Month",
            url: "/demo/charts?period=month",
            data: {turbo_frame: "custom-frame"}
          )
        end

        assert_selector "a[href='/demo/charts?period=month'][data-turbo-frame='custom-frame']", text: "Month"
      end

      def test_renders_dropdown_with_options
        render_inline(Component.new(turbo_frame: "chart-frame")) do |controls|
          controls.dropdown(
            text: "Range",
            options: [
              {text: "Day", url: "/demo/charts?period=day"},
              {text: "Month", url: "/demo/charts?period=month", selected: true}
            ]
          )
        end

        assert_selector "div[data-controller='flat-pack--button-dropdown']"
        assert_selector "a[href='/demo/charts?period=day'][data-turbo-frame='chart-frame'][role='menuitem']", text: "Day"
        assert_selector "a[href='/demo/charts?period=month'][aria-current='true'][data-turbo-frame='chart-frame']", text: "Month"
      end

      def test_renders_checkbox_with_auto_submit
        render_inline(Component.new(turbo_frame: "chart-frame")) do |controls|
          controls.checkbox(
            name: "compare",
            label: "Compare baseline",
            url: "/demo/charts",
            checked: true
          )
        end

        assert_selector "form[data-controller='flat-pack--chart-buttons'][data-turbo-frame='chart-frame']"
        assert_selector "input[type='hidden'][name='compare'][value='0']", visible: false
        assert_selector "input[type='checkbox'][name='compare'][value='1'][checked][data-action*='flat-pack--chart-buttons#submitForm']"
      end

      def test_renders_custom_control_content
        render_inline(Component.new) do |controls|
          controls.control do
            "<span class='custom-control'>Custom Control</span>".html_safe
          end
        end

        assert_selector "span.custom-control", text: "Custom Control"
      end
    end
  end
end
