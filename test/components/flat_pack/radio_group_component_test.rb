# frozen_string_literal: true

require "test_helper"

module FlatPack
  module RadioGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_radio_group_with_name
        render_inline(Component.new(name: "color", options: ["Red", "Blue"]))

        assert_selector "input[type='radio'][name='color']", count: 2
      end

      def test_renders_with_string_options
        render_inline(Component.new(name: "color", options: ["Red", "Blue", "Green"]))

        assert_selector "label", text: "Red"
        assert_selector "label", text: "Blue"
        assert_selector "label", text: "Green"
        assert_selector "input[value='Red']"
        assert_selector "input[value='Blue']"
        assert_selector "input[value='Green']"
      end

      def test_renders_with_array_options
        render_inline(Component.new(name: "size", options: [["Small", "s"], ["Medium", "m"], ["Large", "l"]]))

        assert_selector "label", text: "Small"
        assert_selector "label", text: "Medium"
        assert_selector "label", text: "Large"
        assert_selector "input[value='s']"
        assert_selector "input[value='m']"
        assert_selector "input[value='l']"
      end

      def test_renders_with_hash_options
        options = [
          {label: "Option 1", value: "opt1", disabled: false},
          {label: "Option 2", value: "opt2", disabled: true}
        ]
        render_inline(Component.new(name: "choice", options: options))

        assert_selector "label", text: "Option 1"
        assert_selector "label", text: "Option 2"
        assert_selector "input[value='opt1']"
        assert_selector "input[value='opt2'][disabled]"
      end

      def test_renders_with_selected_value
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], value: "Blue"))

        assert_selector "input[value='Blue'][checked]"
        refute_selector "input[value='Red'][checked]"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], label: "Choose a color"))

        assert_selector "legend", text: "Choose a color"
      end

      def test_renders_all_radios_disabled_when_group_disabled
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], disabled: true))

        assert_selector "input[disabled]", count: 2
      end

      def test_renders_individual_radio_disabled
        options = [
          {label: "Option 1", value: "opt1", disabled: true},
          {label: "Option 2", value: "opt2", disabled: false}
        ]
        render_inline(Component.new(name: "choice", options: options))

        assert_selector "input[value='opt1'][disabled]"
        refute_selector "input[value='opt2'][disabled]"
      end

      def test_renders_required_radios
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], required: true))

        assert_selector "input[required]", count: 2
      end

      def test_renders_with_error
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], error: "Please select a color"))

        assert_selector "p", text: "Please select a color"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "color", options: ["Red"], error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-warning"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "color", options: ["Red"], class: "custom-radio"))

        assert_selector "input.custom-radio"
      end

      def test_has_base_flat_pack_radio_class
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "input.flat-pack-radio"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "div.flat-pack-radio-group-wrapper"
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

      def test_raises_error_with_empty_options
        assert_raises(ArgumentError) do
          Component.new(name: "color", options: [])
        end
      end

      def test_disabled_label_has_disabled_styles
        options = [{label: "Red", value: "red", disabled: true}]
        render_inline(Component.new(name: "color", options: options))

        html = page.native.to_html
        assert_includes html, "opacity-50"
        assert_includes html, "cursor-not-allowed"
      end

      def test_generates_unique_ids_for_each_radio
        render_inline(Component.new(name: "color", options: ["Red", "Blue"]))

        assert_selector "input#color_Red"
        assert_selector "input#color_Blue"
        assert_selector "label[for='color_Red']"
        assert_selector "label[for='color_Blue']"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "size",
          options: [["Small", "s"], ["Medium", "m"]],
          value: "m",
          label: "Choose size",
          disabled: false,
          required: true,
          class: "custom-class"
        ))

        assert_selector "legend", text: "Choose size"
        assert_selector "input[type='radio'][name='size']", count: 2
        assert_selector "input[value='m'][checked]"
        assert_selector "input[required]", count: 2
        assert_selector "input.custom-class"
      end
    end
  end
end
