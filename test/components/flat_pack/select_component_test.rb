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

      def test_renders_with_error
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], error: "Please select a color"))

        assert_selector "p", text: "Please select a color"
        assert_selector "select[aria-invalid='true']"
        assert_selector "select[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "color", options: ["Red"], error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-warning"
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

      def test_searchable_has_stimulus_controller
        render_inline(Component.new(name: "color", options: ["Red"], searchable: true))

        assert_selector "div[data-controller='flat-pack--select']"
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
