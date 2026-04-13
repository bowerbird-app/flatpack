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
          },
          {
            id: "folder-1",
            kind: "record",
            name: "Brand Assets",
            label: "Brand Assets",
            description: "Shared folder for approved creative",
            path: "/Marketing/Brand Assets",
            badge: "Folder",
            meta: "12 items",
            payload: {
              record_type: "Folder",
              record_id: 42
            }
          }
        ]
      end

      def explicit_slot_items
        [
          {
            id: "record-1",
            kind: "record",
            name: "brand-assets",
            title: "Brand Assets",
            description: "Shared folder for approved creative",
            right_text: "12 items",
            icon: "folder",
            payload: {
              record_id: 42
            }
          }
        ]
      end

      def test_renders_picker_modal_shell_when_modal_enabled
        render_inline(Component.new(id: "demo-picker", items: sample_items, modal: true))

        assert_selector "div#demo-picker[data-controller='flat-pack--modal']"
        assert_selector "div[data-controller='flat-pack--picker'][data-flat-pack--picker-modal-value='true']"
        assert_includes rendered_content, "demo-picker"
      end

      def test_renders_inline_picker_without_modal_wrapper_by_default
        render_inline(Component.new(id: "inline-picker", items: sample_items))

        assert_selector "div#inline-picker"
        assert_selector "div#inline-picker div[data-controller='flat-pack--picker'][data-flat-pack--picker-modal-value='false']"
        assert_no_selector "div#inline-picker[data-controller='flat-pack--modal']"
        assert_selector "div#inline-picker > div[style*='--flatpack-modal-body-height: clamp(20rem, 55vh, 30rem)'][style*='height: fit-content'][style*='max-height: var(--flatpack-modal-body-height)']"
        assert_no_match(/flat-pack--modal#close/, rendered_content)
        assert_match(/border-\[var\(--modal-border-color\)\]/, rendered_content)
        assert_match(/bg-\[var\(--modal-surface-color\)\]/, rendered_content)
        assert_match(/shadow-lg/, rendered_content)
        assert_match(/max-w-2xl/, rendered_content)
      end

      def test_defaults_to_list_results_layout
        render_inline(Component.new(id: "layout-default-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-results-layout-value='list']"
      end

      def test_defaults_items_region_to_wrapper_filling_height
        render_inline(Component.new(id: "items-height-default-picker", items: sample_items))

        assert_selector "div[data-flat-pack-picker-items-region='true'].min-h-0.flex-1.overflow-y-auto"
        assert_no_match(/--flatpack-picker-items-height/, rendered_content)
      end

      def test_supports_min_content_items_region_height
        render_inline(Component.new(id: "items-height-min-picker", items: sample_items.first(1), items_height: "min-content"))

        assert_selector "div[data-flat-pack-picker-items-region='true'].min-h-0.shrink-0.overflow-y-auto[style*='--flatpack-picker-items-height: min-content'][style*='height: var(--flatpack-picker-items-height)'][style*='max-height: 100%']"
      end

      def test_supports_fixed_items_region_height
        render_inline(Component.new(id: "items-height-fixed-picker", items: sample_items, items_height: "240px"))

        assert_selector "div[data-flat-pack-picker-items-region='true'].min-h-0.shrink-0.overflow-y-auto[style*='--flatpack-picker-items-height: 240px'][style*='height: var(--flatpack-picker-items-height)'][style*='max-height: 100%']"
      end

      def test_defaults_auto_confirm_to_false
        render_inline(Component.new(id: "manual-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-auto-confirm-value='false']"
      end

      def test_supports_auto_confirm_for_single_select
        render_inline(Component.new(id: "auto-confirm-picker", items: sample_items, selection_mode: :single, auto_confirm: true))

        assert_selector "div[data-flat-pack--picker-selection-mode-value='single'][data-flat-pack--picker-auto-confirm-value='true']"
      end

      def test_hides_action_buttons_for_single_select_auto_confirm
        render_inline(Component.new(id: "auto-confirm-picker", items: sample_items, selection_mode: :single, auto_confirm: true))

        assert_no_selector "button", text: "Close"
        assert_no_selector "button", text: "Use Selected"
      end

      def test_supports_grid_results_layout
        render_inline(Component.new(id: "layout-grid-picker", items: sample_items, results_layout: :grid))

        assert_selector "div[data-flat-pack--picker-results-layout-value='grid']"
      end

      def test_supports_record_kind_items
        render_inline(Component.new(id: "record-picker", items: sample_items, accepted_kinds: [:record]))

        assert_includes rendered_content, "data-flat-pack--picker-accepted-kinds-value=\"[&quot;record&quot;]\""
        assert_includes rendered_content, "&quot;kind&quot;:&quot;record&quot;"
        assert_includes rendered_content, "&quot;title&quot;:&quot;Brand Assets&quot;"
        assert_includes rendered_content, "&quot;icon&quot;:&quot;folder&quot;"
        assert_includes rendered_content, "&quot;right_text&quot;:&quot;12 items&quot;"
        assert_includes rendered_content, "&quot;description&quot;:&quot;Shared folder for approved creative • /Marketing/Brand Assets&quot;"
        assert_includes rendered_content, "&quot;path&quot;:&quot;/Marketing/Brand Assets&quot;"
        assert_includes rendered_content, "&quot;badge&quot;:&quot;Folder&quot;"
      end

      def test_supports_explicit_display_slot_fields
        render_inline(Component.new(id: "slot-picker", items: explicit_slot_items, accepted_kinds: [:record]))

        assert_includes rendered_content, "&quot;title&quot;:&quot;Brand Assets&quot;"
        assert_includes rendered_content, "&quot;description&quot;:&quot;Shared folder for approved creative&quot;"
        assert_includes rendered_content, "&quot;right_text&quot;:&quot;12 items&quot;"
        assert_includes rendered_content, "&quot;icon&quot;:&quot;folder&quot;"
      end

      def test_renders_builtin_form_wrapper_when_form_config_present
        render_inline(Component.new(
          id: "form-picker",
          items: sample_items,
          selection_mode: :single,
          form: {
            url: "/demo/picker_submissions",
            scope: :picker_assignment,
            field: :folder_record_id,
            value_path: "payload.record_id"
          }
        ))

        assert_selector "form[action='/demo/picker_submissions']"
        assert_selector "form[data-turbo='true']"
        assert_selector "div.hidden[data-flat-pack--picker-target='formFields']"
        assert_selector "button[type='submit']", text: "Use Selected"
        assert_includes rendered_content, "&quot;field&quot;:&quot;folder_record_id&quot;"
        assert_includes rendered_content, "&quot;scope&quot;:&quot;picker_assignment&quot;"
        assert_includes rendered_content, "&quot;valueMode&quot;:&quot;id&quot;"
        assert_includes rendered_content, "&quot;valuePath&quot;:&quot;payload.record_id&quot;"
      end

      def test_renders_search_input_by_default_for_local_picker
        render_inline(Component.new(id: "searchable-picker", items: sample_items))

        assert_selector "input[name='picker_query_searchable-picker'][placeholder='Search assets...']"
        assert_selector "input[data-flat-pack--picker-target='searchInput']"
      end

      def test_does_not_render_search_input_when_searchable_is_false_for_local_picker
        render_inline(Component.new(id: "hidden-search-picker", items: sample_items, searchable: false))

        assert_no_selector "input[name='picker_query_hidden-search-picker']"
        assert_selector "div[data-flat-pack--picker-searchable-value='false']"
      end

      def test_hides_search_input_when_local_item_count_is_at_or_below_minimum_searchable
        render_inline(Component.new(id: "threshold-hidden-picker", items: sample_items, minimum_searchable: 3))

        assert_no_selector "input[name='picker_query_threshold-hidden-picker']"
        assert_selector "div[data-flat-pack--picker-searchable-value='false']"
      end

      def test_renders_search_input_when_local_item_count_exceeds_minimum_searchable
        render_inline(Component.new(id: "threshold-visible-picker", items: sample_items, minimum_searchable: 2))

        assert_selector "input[name='picker_query_threshold-visible-picker']"
        assert_selector "div[data-flat-pack--picker-searchable-value='true']"
      end

      def test_renders_search_input_for_remote_picker_even_when_searchable_is_false
        render_inline(Component.new(
          id: "remote-search-picker",
          items: sample_items,
          searchable: false,
          search_mode: :remote,
          search_endpoint: "/demo/picker_results"
        ))

        assert_selector "input[name='picker_query_remote-search-picker']"
        assert_selector "div[data-flat-pack--picker-searchable-value='true'][data-flat-pack--picker-search-mode-value='remote']"
      end

      def test_requires_search_endpoint_for_remote_search
        assert_raises(ArgumentError) do
          Component.new(
            id: "remote-picker",
            items: sample_items,
            search_mode: :remote
          )
        end
      end

      def test_rejects_unsafe_remote_search_endpoint
        assert_raises(ArgumentError) do
          Component.new(
            id: "unsafe-picker",
            items: sample_items,
            search_mode: :remote,
            search_endpoint: "javascript:alert('xss')"
          )
        end
      end

      def test_rejects_negative_minimum_searchable
        assert_raises(ArgumentError) do
          Component.new(
            id: "invalid-minimum-searchable-picker",
            items: sample_items,
            minimum_searchable: -1
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

      def test_rejects_form_mode_without_url
        assert_raises(ArgumentError) do
          Component.new(
            id: "invalid-form-picker",
            items: sample_items,
            form: {
              field: :asset_ids
            }
          )
        end
      end

      def test_rejects_form_mode_without_field
        assert_raises(ArgumentError) do
          Component.new(
            id: "invalid-form-field-picker",
            items: sample_items,
            form: {
              url: "/demo/picker_submissions"
            }
          )
        end
      end

      def test_rejects_single_select_ids_form_mode
        assert_raises(ArgumentError) do
          Component.new(
            id: "invalid-single-form-picker",
            items: sample_items,
            selection_mode: :single,
            form: {
              url: "/demo/picker_submissions",
              field: :asset_ids,
              value_mode: :ids
            }
          )
        end
      end

      def test_uses_fixed_modal_body_height_by_default_when_modal_enabled
        render_inline(Component.new(id: "stable-height-picker", items: sample_items, modal: true))

        assert_selector "div[style*='--flatpack-modal-body-height: clamp(20rem, 55vh, 30rem)'][style*='height: var(--flatpack-modal-body-height)']"
      end

      def test_renders_empty_state_in_stable_results_region
        render_inline(Component.new(id: "stable-results-picker", items: sample_items))

        assert_selector "div[data-flat-pack--picker-target='emptyState'].hidden.h-full.min-h-32.items-center.justify-center"
      end
    end
  end
end
