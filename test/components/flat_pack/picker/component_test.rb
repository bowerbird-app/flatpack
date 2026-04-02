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

      def test_renders_picker_modal_shell_when_modal_enabled
        render_inline(Component.new(id: "demo-picker", items: sample_items, modal: true))

        assert_selector "div#demo-picker[data-controller='flat-pack--modal']"
        assert_selector "div[data-controller='flat-pack--picker'][data-flat-pack--picker-config-value]"
        assert_includes rendered_content, "&quot;presentation&quot;:{&quot;modal&quot;:true,&quot;resultsLayout&quot;:&quot;list&quot;}"
        refute_includes rendered_content, "data-flat-pack--picker-modal-value"
        assert_includes rendered_content, "demo-picker"
      end

      def test_renders_inline_picker_without_modal_wrapper_by_default
        render_inline(Component.new(id: "inline-picker", items: sample_items))

        assert_selector "div#inline-picker"
        assert_selector "div#inline-picker div[data-controller='flat-pack--picker'][data-flat-pack--picker-config-value]"
        assert_includes rendered_content, "&quot;presentation&quot;:{&quot;modal&quot;:false,&quot;resultsLayout&quot;:&quot;list&quot;}"
        assert_no_selector "div#inline-picker[data-controller='flat-pack--modal']"
        assert_no_match(/flat-pack--modal#close/, rendered_content)
        assert_match(/border-\[var\(--modal-border-color\)\]/, rendered_content)
        assert_match(/bg-\[var\(--modal-surface-color\)\]/, rendered_content)
        assert_match(/shadow-lg/, rendered_content)
        assert_match(/max-w-2xl/, rendered_content)
      end

      def test_defaults_to_list_results_layout
        render_inline(Component.new(id: "layout-default-picker", items: sample_items))

        assert_includes rendered_content, "&quot;resultsLayout&quot;:&quot;list&quot;"
      end

      def test_defaults_auto_confirm_to_false
        render_inline(Component.new(id: "manual-picker", items: sample_items))

        assert_includes rendered_content, "&quot;autoConfirm&quot;:false"
      end

      def test_supports_auto_confirm_for_single_select
        render_inline(Component.new(id: "auto-confirm-picker", items: sample_items, selection_mode: :single, auto_confirm: true))

        assert_includes rendered_content, "&quot;selection&quot;:{&quot;mode&quot;:&quot;single&quot;"
        assert_includes rendered_content, "&quot;autoConfirm&quot;:true"
      end

      def test_hides_action_buttons_for_single_select_auto_confirm
        render_inline(Component.new(id: "auto-confirm-picker", items: sample_items, selection_mode: :single, auto_confirm: true))

        assert_no_selector "button", text: "Close"
        assert_no_selector "button", text: "Use Selected"
      end

      def test_supports_grid_results_layout
        render_inline(Component.new(id: "layout-grid-picker", items: sample_items, results_layout: :grid))

        assert_includes rendered_content, "&quot;resultsLayout&quot;:&quot;grid&quot;"
      end

      def test_supports_record_kind_items
        render_inline(Component.new(id: "record-picker", items: sample_items, accepted_kinds: [:record]))

        assert_includes rendered_content, "data-flat-pack--picker-config-value="
        assert_includes rendered_content, "&quot;selection&quot;:{&quot;mode&quot;:&quot;multiple&quot;,&quot;acceptedKinds&quot;:[&quot;record&quot;],&quot;autoConfirm&quot;:false}"
        assert_includes rendered_content, "&quot;kind&quot;:&quot;record&quot;"
        assert_includes rendered_content, "&quot;description&quot;:&quot;Shared folder for approved creative&quot;"
        assert_includes rendered_content, "&quot;path&quot;:&quot;/Marketing/Brand Assets&quot;"
        assert_includes rendered_content, "&quot;badge&quot;:&quot;Folder&quot;"
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
        assert_selector "div[data-flat-pack--picker-target='formFields']"
        assert_selector "button[type='submit']", text: "Use Selected"
        assert_includes rendered_content, "&quot;field&quot;:&quot;folder_record_id&quot;"
        assert_includes rendered_content, "&quot;scope&quot;:&quot;picker_assignment&quot;"
        assert_includes rendered_content, "&quot;valueMode&quot;:&quot;id&quot;"
        assert_includes rendered_content, "&quot;valuePath&quot;:&quot;payload.record_id&quot;"
        assert_includes rendered_content, "&quot;output&quot;:{&quot;mode&quot;:&quot;event&quot;,&quot;target&quot;:null,&quot;form&quot;:{&quot;field&quot;:&quot;folder_record_id&quot;,&quot;scope&quot;:&quot;picker_assignment&quot;,&quot;valueMode&quot;:&quot;id&quot;,&quot;valuePath&quot;:&quot;payload.record_id&quot;}}"
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
