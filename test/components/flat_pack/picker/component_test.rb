# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Picker
    class ComponentTest < ViewComponent::TestCase
      def sample_items
        [
          {
            id: "img-1",
            kind: "image",
            name: "hero.png",
            label: "Hero",
            content_type: "image/png",
            byte_size: 1024,
            thumbnail_url: "https://example.com/hero.png"
          },
          {
            id: "file-1",
            kind: "file",
            name: "brief.pdf",
            label: "Brief",
            content_type: "application/pdf",
            byte_size: 4096
          }
        ]
      end

      def test_renders_picker_modal_shell
        render_inline(Component.new(id: "demo-picker", items: sample_items))

        assert_selector "div#demo-picker[data-controller='flat-pack--modal']"
        assert_selector "div[data-controller='flat-pack--picker'][data-flat-pack--picker-modal-value='true']"
        assert_includes rendered_content, "demo-picker"
      end

      def test_renders_inline_picker_without_modal_wrapper
        render_inline(Component.new(id: "inline-picker", items: sample_items, modal: false))

        assert_selector "div#inline-picker"
        assert_selector "div#inline-picker div[data-controller='flat-pack--picker'][data-flat-pack--picker-modal-value='false']"
        assert_no_selector "div#inline-picker[data-controller='flat-pack--modal']"
        assert_no_match(/flat-pack--modal#close/, rendered_content)
      end

      def test_defaults_to_list_results_layout
        render_inline(Component.new(id: "layout-default-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-results-layout-value='list']"
      end

      def test_defaults_auto_confirm_to_false
        render_inline(Component.new(id: "manual-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-auto-confirm-value='false']"
      end

      def test_supports_auto_confirm_for_single_select
        render_inline(Component.new(id: "auto-confirm-picker", items: sample_items, selection_mode: :single, auto_confirm: true))

        assert_selector "div[data-flat-pack--picker-selection-mode-value='single'][data-flat-pack--picker-auto-confirm-value='true']"
      end

      def test_supports_grid_results_layout
        render_inline(Component.new(id: "layout-grid-picker", items: sample_items, results_layout: :grid))

        assert_selector "div[data-flat-pack--picker-results-layout-value='grid']"
      end

      def test_renders_search_input_when_searchable
        render_inline(Component.new(id: "searchable-picker", items: sample_items, searchable: true))

        assert_selector "input[name='picker_query_searchable-picker'][placeholder='Search assets...']"
        assert_selector "input[data-flat-pack--picker-target='searchInput']"
      end

      def test_requires_search_endpoint_for_remote_search
        assert_raises(ArgumentError) do
          Component.new(
            id: "remote-picker",
            items: sample_items,
            searchable: true,
            search_mode: :remote
          )
        end
      end

      def test_rejects_unsafe_remote_search_endpoint
        assert_raises(ArgumentError) do
          Component.new(
            id: "unsafe-picker",
            items: sample_items,
            searchable: true,
            search_mode: :remote,
            search_endpoint: "javascript:alert('xss')"
          )
        end
      end

      def test_rejects_invalid_results_layout
        assert_raises(ArgumentError) do
          Component.new(
            id: "invalid-layout-picker",
            items: sample_items,
            results_layout: :masonry
          )
        end
      end

      def test_uses_fixed_modal_body_height_by_default
        render_inline(Component.new(id: "stable-height-picker", items: sample_items))

        assert_selector "div[style*='--flatpack-modal-body-height: clamp(20rem, 55vh, 30rem)'][style*='height: var(--flatpack-modal-body-height)']"
      end

      def test_renders_empty_state_in_stable_results_region
        render_inline(Component.new(id: "stable-results-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-target='emptyState'].hidden.h-full.min-h-32.items-center.justify-center"
      end
    end
  end
end
