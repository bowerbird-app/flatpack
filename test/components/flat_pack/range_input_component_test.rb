# frozen_string_literal: true

require "test_helper"

module FlatPack
  module RangeInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_range_input
        render_inline(Component.new(name: "volume"))

        assert_selector "input[type='range']"
      end

      def test_renders_with_name
        render_inline(Component.new(name: "volume"))

        assert_selector "input[name='volume']"
      end

      def test_renders_with_id
        render_inline(Component.new(name: "volume", id: "volume-slider"))

        assert_selector "input#volume-slider"
      end

      def test_uses_name_as_id_by_default
        render_inline(Component.new(name: "volume"))

        assert_selector "input#volume"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "volume", value: 50))

        assert_selector "input[value='50']"
      end

      def test_renders_with_min_and_max
        render_inline(Component.new(name: "volume", min: 0, max: 100))

        assert_selector "input[min='0'][max='100']"
      end

      def test_renders_with_step
        render_inline(Component.new(name: "volume", step: 5))

        assert_selector "input[step='5']"
      end

      def test_renders_label_when_provided
        render_inline(Component.new(name: "volume", label: "Volume"))

        assert_selector "label", text: "Volume"
        assert_selector "label[for='volume']"
      end

      def test_renders_value_display_when_show_value_true
        render_inline(Component.new(name: "volume", value: 75, show_value: true, label: "Volume"))

        assert_selector "[data-flat-pack--range-input-target='valueDisplay']", text: "75"
      end

      def test_does_not_render_value_display_by_default_without_label
        render_inline(Component.new(name: "volume", value: 75))

        refute_selector "[data-flat-pack--range-input-target='valueDisplay']"
      end

      def test_renders_disabled_state
        render_inline(Component.new(name: "volume", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_includes_stimulus_controller
        render_inline(Component.new(name: "volume"))

        assert_selector "[data-controller='flat-pack--range-input']"
      end

      def test_includes_stimulus_targets
        render_inline(Component.new(name: "volume"))

        assert_selector "[data-flat-pack--range-input-target='input']"
      end

      def test_includes_update_action
        render_inline(Component.new(name: "volume"))

        assert_selector "[data-action='input->flat-pack--range-input#update']"
      end

      def test_includes_aria_label
        render_inline(Component.new(name: "volume", label: "Volume Control"))

        assert_selector "input[aria-label='Volume Control']"
      end

      def test_includes_default_aria_label_when_no_label
        render_inline(Component.new(name: "volume"))

        assert_selector "input[aria-label='Range input']"
      end

      def test_includes_aria_valuenow
        render_inline(Component.new(name: "volume", value: 60))

        assert_selector "input[aria-valuenow='60']"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_when_min_greater_than_max
        assert_raises(ArgumentError) do
          Component.new(name: "volume", min: 100, max: 0)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(name: "volume", class: "custom-class"))

        assert_selector ".custom-class"
      end
    end
  end
end
