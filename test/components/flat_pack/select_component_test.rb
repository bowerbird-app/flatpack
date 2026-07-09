# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Select
    class ComponentTest < ViewComponent::TestCase
      def test_renders_native_select_with_name
        render_inline(Component.new(name: "country", options: ["USA", "Canada"]))

        assert_selector "select[name='country']"
      end

      def test_renders_with_string_options
        render_inline(Component.new(name: "color", options: ["Red", "Blue", "Green"]))

        assert_selector "option", text: "Red"
        assert_selector "option", text: "Blue"
        assert_selector "option", text: "Green"
        assert_selector "option[value='Red']"
        assert_selector "option[value='Blue']"
        assert_selector "option[value='Green']"
      end

      def test_renders_with_array_options
        render_inline(Component.new(name: "size", options: [["Small", "s"], ["Medium", "m"], ["Large", "l"]]))

        assert_selector "option", text: "Small"
        assert_selector "option", text: "Medium"
        assert_selector "option", text: "Large"
        assert_selector "option[value='s']"
        assert_selector "option[value='m']"
        assert_selector "option[value='l']"
      end

      def test_renders_with_hash_options
        options = [
          {label: "Option 1", value: "opt1", disabled: false},
          {label: "Option 2", value: "opt2", disabled: true}
        ]
        render_inline(Component.new(name: "choice", options: options))

        assert_selector "option", text: "Option 1"
        assert_selector "option", text: "Option 2"
        assert_selector "option[value='opt1']"
        assert_selector "option[value='opt2'][disabled]"
      end

      def test_renders_with_selected_value
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], value: "Blue"))

        assert_selector "option[value='Blue'][selected]"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], label: "Choose a color"))

        assert_selector "label", text: "Choose a color"
      end

      def test_renders_help_text_for_native_select
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], id: "color", help_text: "Choose one color."))

        assert_selector "p#color_help_text", text: "Choose one color."
        assert_selector "select[aria-describedby='color_help_text']"
      end

      def test_renders_help_text_for_searchable_select
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], id: "color", searchable: true, help_text: "Search and choose one color."))

        assert_selector "p#color_help_text", text: "Search and choose one color."
        assert_selector "button[aria-describedby='color_help_text']"
        assert_selector "input[type='hidden'][aria-describedby='color_help_text']", visible: :all
      end

      def test_raises_error_with_non_text_help_text
        assert_raises(ArgumentError) do
          Component.new(name: "color", options: ["Red"], help_text: [:not_text])
        end
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], placeholder: "Pick a color"))

        assert_selector "option[disabled][selected]", text: "Pick a color"
      end

      def test_renders_disabled_select
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], disabled: true))

        assert_selector "select[disabled]"
      end

      def test_renders_required_select
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], required: true))

        assert_selector "select[required]"
      end

      def test_renders_native_multiple_select
        render_inline(Component.new(name: "colors", options: ["Red", "Blue", "Green"], value: ["Red", "Green"], multiple: true))

        assert_selector "select[multiple][name='colors[]']"
        assert_selector "option[value='Red'][selected]"
        assert_selector "option[value='Green'][selected]"
      end

      def test_preserves_existing_array_name_for_native_multiple
        render_inline(Component.new(name: "colors[]", options: ["Red", "Blue"], multiple: true))

        assert_selector "select[multiple][name='colors[]']"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], error: "Please select a color"))

        assert_selector "p", text: "Please select a color"
        assert_selector "select[aria-invalid='true']"
        assert_selector "select[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "color", options: ["Red"], error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-warning)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "color", options: ["Red"], class: "custom-select"))

        assert_selector "select.custom-select"
      end

      def test_has_base_flat_pack_select_class
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "select.flat-pack-select"
      end

      def test_native_select_uses_custom_chevron_with_reserved_space
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "div.relative > select.flat-pack-select.appearance-none"
        assert_selector "div.relative > span.absolute.inset-y-0.right-0.pr-3.pointer-events-none"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "div.flat-pack-select-wrapper"
      end

      def test_renders_searchable_custom_select
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], searchable: true))

        # Should render custom dropdown instead of native select
        refute_selector "select"
        assert_selector "input[type='hidden'][name='color']", visible: false
        assert_selector "button[data-action='flat-pack--select#toggle']"
        assert_selector "div[data-flat-pack--select-target='dropdown']", visible: false
        assert_selector "input[data-flat-pack--select-target='searchInput']", visible: false
      end

      def test_searchable_renders_trigger_button
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], searchable: true, placeholder: "Select color"))

        assert_selector "button span", text: "Select color"
      end

      def test_searchable_renders_options_in_dropdown
        render_inline(Component.new(name: "color", options: ["Red", "Blue", "Green"], searchable: true))

        assert_selector "div[role='option']", count: 3
        assert_selector "div[role='option'][data-value='Red']"
        assert_selector "div[role='option'][data-value='Blue']"
        assert_selector "div[role='option'][data-value='Green']"
      end

      def test_searchable_shows_selected_value
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], value: "Blue", searchable: true))

        assert_selector "button span", text: "Blue"
        assert_selector "input[type='hidden'][value='Blue']", visible: false
      end

      def test_searchable_multiple_renders_hidden_inputs
        render_inline(Component.new(
          name: "frameworks",
          options: [["Rails", "rails"], ["Hotwire", "hotwire"], ["React", "react"]],
          value: ["rails", "react"],
          searchable: true,
          multiple: true
        ))

        assert_selector "input[type='hidden'][name='frameworks[]'][value='rails']", visible: false
        assert_selector "input[type='hidden'][name='frameworks[]'][value='react']", visible: false
      end

      def test_searchable_multiple_renders_selected_chips
        render_inline(Component.new(
          name: "frameworks",
          options: [["Rails", "rails"], ["Hotwire", "hotwire"], ["React", "react"]],
          value: ["rails", "react"],
          placeholder: "Search frameworks",
          searchable: true,
          multiple: true
        ))

        assert_selector "[data-flat-pack--select-target='chip'][data-value='rails'] .inline-flex", text: "Rails"
        assert_selector "[data-flat-pack--select-target='chip'][data-value='react'] .inline-flex", text: "React"
        assert_selector "[data-flat-pack--select-target='chip'][data-value='hotwire']", visible: false
        assert_selector "[data-flat-pack--select-target='placeholder'].hidden", text: "Search frameworks"
      end

      def test_searchable_multiple_chip_has_remove_action
        render_inline(Component.new(
          name: "frameworks",
          options: [["Rails", "rails"], ["Hotwire", "hotwire"]],
          value: ["rails"],
          searchable: true,
          multiple: true
        ))

        assert_selector "[data-flat-pack--select-target='chip'][data-value='rails'] [data-action*='flat-pack--select#removeChip']"
        assert_selector "[data-flat-pack--select-target='chip'][data-value='rails'] svg[data-flat-pack--icon-name-value='x-mark']"
      end

      def test_nested_multiselect_forces_custom_select_and_renders_parent_child_options
        render_inline(Component.new(
          name: "locations",
          label: "Service Locations",
          options: [
            {
              label: "Australia",
              value: "australia",
              children: [
                {label: "VIC", value: "vic"},
                {label: "NSW", value: "nsw", disabled: true}
              ]
            }
          ],
          value: ["australia"],
          multiple: true
        ))

        refute_selector "select"
        assert_selector "div[data-controller='flat-pack--select']"
        assert_selector "div[data-flat-pack--select-nested-value='true']"
        assert_selector "div[role='option'][data-option-type='parent'][data-value='australia'][data-parent-value='australia']", text: "Australia"
        assert_selector "div[role='option'][data-option-type='child'][data-value='vic'][data-parent-value='australia']", text: "VIC"
        assert_selector "div[role='option'][data-option-type='child'][data-value='nsw'][data-disabled='true']", text: "NSW"
        assert_selector "input[type='hidden'][name='locations[]'][value='australia']", visible: false
        assert_selector "input[type='hidden'][name='locations[]'][value='vic']", visible: false
      end

      def test_nested_multiselect_accepts_id_values_and_orders_hidden_inputs
        render_inline(Component.new(
          name: "locations",
          options: [
            {
              id: "australia",
              label: "Australia",
              children: [
                {id: "vic", label: "VIC"},
                {id: "nsw", label: "NSW"}
              ]
            },
            {
              id: "malaysia",
              label: "Malaysia",
              children: [
                {id: "penang", label: "Penang"}
              ]
            }
          ],
          value: ["vic", "nsw", "penang"],
          multiple: true,
          searchable: true
        ))

        hidden_values = page.all("input[type='hidden'][name='locations[]']", visible: false).map { |input| input[:value] }

        assert_equal ["australia", "vic", "nsw", "malaysia", "penang"], hidden_values
        assert_selector "div[role='option'][data-value='australia']"
        assert_selector "div[role='option'][data-value='vic']"
        assert_selector "span[data-flat-pack--select-target='chip'][data-value='australia']", visible: false
        assert_selector "span[data-flat-pack--select-target='chip'][data-value='vic']", visible: false
        assert_selector "span[data-flat-pack--select-target='chip'][data-value='nsw']", visible: false
        assert_selector "span[data-flat-pack--select-target='chip'][data-value='penang']", visible: false
      end

      def test_searchable_has_stimulus_controller
        render_inline(Component.new(name: "color", options: ["Red"], searchable: true))

        assert_selector "div[data-controller='flat-pack--select']"
      end

      def test_searchable_remote_sets_controller_values
        render_inline(Component.new(
          name: "assignee",
          options: [],
          searchable: true,
          search_mode: :remote,
          search_endpoint: "/demo/forms/select/options",
          search_param: "query",
          min_search_length: 3
        ))

        assert_selector "div[data-flat-pack--select-search-mode-value='remote']"
        assert_selector "div[data-flat-pack--select-search-endpoint-value='/demo/forms/select/options']"
        assert_selector "div[data-flat-pack--select-search-param-value='query']"
        assert_selector "div[data-flat-pack--select-min-search-length-value='3']"
        assert_selector "[data-flat-pack--select-target='searchHint']", text: "Type at least 3 characters to search"
      end

      def test_raises_error_for_invalid_search_mode
        assert_raises(ArgumentError) do
          Component.new(name: "color", options: ["Red"], searchable: true, search_mode: :invalid)
        end
      end

      def test_raises_error_for_remote_without_endpoint
        assert_raises(ArgumentError) do
          Component.new(name: "color", options: ["Red"], searchable: true, search_mode: :remote)
        end
      end

      def test_raises_error_for_unsafe_search_endpoint
        assert_raises(ArgumentError) do
          Component.new(
            name: "color",
            options: ["Red"],
            searchable: true,
            search_mode: :remote,
            search_endpoint: "javascript:alert(1)"
          )
        end
      end

      def test_renders_with_data_attributes
        render_inline(Component.new(name: "color", options: ["Red"], data: {controller: "custom"}))

        assert_selector "select[data-controller='custom']"
      end

      def test_renders_with_aria_attributes
        render_inline(Component.new(name: "color", options: ["Red"], aria: {label: "Custom color"}))

        assert_selector "select[aria-label='Custom color']"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new(name: nil, options: ["Red"])
        end
      end

      def test_raises_error_with_empty_name
        assert_raises(ArgumentError) do
          Component.new(name: "", options: ["Red"])
        end
      end

      def test_raises_error_without_options
        assert_raises(ArgumentError) do
          Component.new(name: "color", options: nil)
        end
      end

      def test_allows_empty_options_array
        # Empty options should be allowed for dynamic select elements
        render_inline(Component.new(name: "color", options: []))

        assert_selector "select[name='color']"
      end

      def test_label_for_attribute_matches_select_id
        render_inline(Component.new(name: "color", options: ["Red"], label: "Color", id: "color-select"))

        assert_selector "label[for='color-select']"
        assert_selector "select#color-select"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "size",
          options: [["Small", "s"], ["Medium", "m"]],
          value: "m",
          label: "Choose size",
          placeholder: "Select...",
          disabled: false,
          required: true,
          class: "custom-class"
        ))

        assert_selector "label", text: "Choose size"
        assert_selector "select[name='size']"
        assert_selector "option[value='m'][selected]"
        assert_selector "select[required]"
        assert_selector "select.custom-class"
      end
    end
  end
end
