# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ModalFilter
    class ComponentTest < ViewComponent::TestCase
      def test_renders_trigger_and_modal_form
        render_inline(Component.new(
          id: "modal-table-filters",
          form_url: "/demo/modal_filter",
          turbo_frame: "modal-filter-table-frame"
        )) do |component|
          component.filter_body do
            "<input id='modal-only-filter' name='table_q' value='' />".html_safe
          end
        end

        assert_selector "button", text: "Filter"
        assert_selector "div#modal-table-filters-modal"
        assert_selector "form#modal-table-filters-mobile-form[data-turbo-frame='modal-filter-table-frame']"
        assert_selector "#modal-only-filter"
        assert_no_selector "div.hidden.md\\:block"
      end

      def test_shows_active_count_badge_when_count_is_positive
        render_inline(Component.new(
          id: "modal-chart-filters",
          form_url: "/demo/charts/default_filter",
          turbo_frame: "chart-default-filter-frame",
          active_count: 2
        )) do |component|
          component.filter_body do
            "<input name='status' value='active' />".html_safe
          end
        end

        assert_selector "button span", text: "Filter"
        assert_selector "button span.rounded-full", text: "2"
      end

      def test_hides_active_count_badge_when_count_is_zero
        render_inline(Component.new(
          id: "modal-chart-filters-zero",
          form_url: "/demo/charts/default_filter",
          turbo_frame: "chart-default-filter-frame",
          active_count: 0
        )) do |component|
          component.filter_body do
            "<input name='status' value='' />".html_safe
          end
        end

        assert_selector "button", text: "Filter"
        assert_no_selector "button span.rounded-full"
      end

      def test_renders_reset_and_submit_actions
        render_inline(Component.new(
          id: "modal-actions-filters",
          form_url: "/demo/modal_filter",
          turbo_frame: "modal-filter-table-frame",
          reset_url: "/demo/modal_filter"
        )) do |component|
          component.filter_body do
            "<input name='table_status' value='' />".html_safe
          end
        end

        assert_selector "a", text: "Reset"
        assert_selector "button[type='submit'][form='modal-actions-filters-mobile-form']", text: "Apply"
      end

      def test_raises_for_missing_filter_body_slot
        assert_raises(ArgumentError) do
          render_inline(Component.new(
            id: "modal-invalid",
            form_url: "/demo/modal_filter",
            turbo_frame: "modal-filter-table-frame"
          ))
        end
      end
    end
  end
end
