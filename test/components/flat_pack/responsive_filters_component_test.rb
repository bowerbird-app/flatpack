# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ResponsiveFilters
    class ComponentTest < ViewComponent::TestCase
      def test_renders_desktop_form_and_mobile_trigger
        render_inline(Component.new(
          id: "table-filters",
          form_url: "/demo/tables/basic",
          turbo_frame: "basic-table-generic-filter-frame"
        )) do |component|
          component.fields do
            "<input name='q' value='' />".html_safe
          end
        end

        assert_selector "div.hidden.md\\:block form[data-turbo-frame='basic-table-generic-filter-frame']"
        assert_selector "div.md\\:hidden button", text: "Filter"
        assert_selector "div#table-filters-modal"
      end

      def test_shows_active_count_in_mobile_trigger
        render_inline(Component.new(
          id: "chart-filters",
          form_url: "/demo/charts/default_filter",
          turbo_frame: "chart-default-filter-frame",
          active_count: 2
        )) do |component|
          component.fields do
            "<input name='status' value='active' />".html_safe
          end
        end

        assert_selector "button", text: "Filter 2"
      end

      def test_includes_desktop_auto_submit_data_attributes
        render_inline(Component.new(
          id: "auto-submit-filters",
          form_url: "/demo/charts/default_filter",
          turbo_frame: "chart-default-filter-frame",
          auto_submit_delay: 400
        )) do |component|
          component.fields do
            "<input name='status' value='' />".html_safe
          end
        end

        assert_selector "form[data-controller='flat-pack--auto-submit']"
        assert_selector "form[data-action*='flat-pack--auto-submit#queueSubmit']"
        assert_selector "form[data-flat-pack--auto-submit-delay-value='400']"
      end

      def test_uses_mobile_fields_slot_when_present
        render_inline(Component.new(
          id: "slot-filters",
          form_url: "/demo/tables/basic",
          turbo_frame: "basic-table-generic-filter-frame"
        )) do |component|
          component.fields do
            "<input id='desktop-only' name='q' value='' />".html_safe
          end

          component.mobile_fields do
            "<input id='mobile-only' name='q' value='' />".html_safe
          end
        end

        assert_selector "#desktop-only"
        assert_selector "#mobile-only"
      end

      def test_raises_for_missing_id
        assert_raises(ArgumentError) do
          Component.new(
            id: nil,
            form_url: "/demo/tables/basic",
            turbo_frame: "basic-table-generic-filter-frame"
          )
        end
      end
    end
  end
end
