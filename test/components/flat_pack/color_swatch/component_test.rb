# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ColorSwatch
    class ComponentTest < ViewComponent::TestCase
      def test_renders_color_swatch_with_color
        render_inline(Component.new(color: "#ffffff", text: "Background"))

        assert_selector "[data-controller='flat-pack--color-swatch']"
        assert_selector "button[aria-label='Background'][aria-haspopup='dialog']"
        assert_includes page.native.to_html, "background-color: #ffffff"
      end

      def test_requires_color
        assert_raises(ArgumentError) do
          Component.new(color: "")
        end
      end

      def test_rejects_invalid_color
        assert_raises(ArgumentError) do
          Component.new(color: "not-a-color")
        end
      end

      def test_opens_picker_via_flatpack_popover
        render_inline(Component.new(color: "#333333", text: "Accent"))

        assert_selector "[data-controller='flat-pack--popover']"
        assert_selector "[data-flat-pack--color-swatch-target='panel']"
        assert_selector "label", text: "Choose colour"
        assert_selector "input[type='color'][value='#333333']"
        assert_selector "[data-flat-pack--color-swatch-target='hex']", text: "#333333"
      end

      def test_renders_form_name_when_provided
        render_inline(Component.new(color: "#333333", text: "Accent", name: "theme[accent]"))

        assert_selector "input[type='color'][name='theme[accent]']"
      end

      def test_omits_form_name_when_absent
        render_inline(Component.new(color: "#333333", text: "Accent"))

        refute_selector "input[name]"
      end

      def test_renders_selected_label_when_text_present
        render_inline(Component.new(color: "#f8f9fa", text: "Background", selected: true))

        assert_selector "[data-selected='true']", text: "Background"
        assert_includes page.native.to_html, "ring-[var(--color-swatch-selected-ring-color)]"
      end

      def test_hides_label_when_not_selected
        render_inline(Component.new(color: "#f8f9fa", text: "Background", selected: false))

        assert_selector "[data-selected='false']"
        refute_selector "span.text-xs", text: "Background"
      end

      def test_wraps_with_tooltip_when_text_present
        render_inline(Component.new(color: "#333333", text: "Text"))

        assert_selector "[data-controller='flat-pack--tooltip']"
        assert_selector "[role='tooltip']", text: "Text"
      end

      def test_skips_tooltip_when_text_blank
        render_inline(Component.new(color: "#333333"))

        refute_selector "[data-controller='flat-pack--tooltip']"
        assert_selector "button[aria-label='Color']"
      end

      def test_can_disable_tooltip
        render_inline(Component.new(color: "#333333", text: "Text", show_tooltip: false))

        refute_selector "[data-controller='flat-pack--tooltip']"
      end

      def test_omits_popover_when_disabled
        render_inline(Component.new(color: "#333333", text: "Accent", disabled: true))

        assert_selector "button[disabled]"
        refute_selector "[data-controller='flat-pack--popover']"
      end

      def test_renders_sizes
        Component::SIZES.each do |size, size_classes|
          render_inline(Component.new(color: "#000000", text: "Accent", size: size))

          assert_includes page.native.to_html, size_classes.split.first
        end
      end

      def test_raises_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(color: "#000000", size: :huge)
        end
      end

      def test_expands_short_hex
        render_inline(Component.new(color: "#abc", text: "Accent"))

        assert_selector "input[type='color'][value='#aabbcc']"
      end

      def test_accepts_css_variables_for_display
        render_inline(Component.new(color: "var(--color-primary)", text: "Primary"))

        assert_includes page.native.to_html, "background-color: var(--color-primary)"
        assert_selector "input[type='color'][value='#000000']"
      end

      def test_value_overrides_input_hex
        render_inline(Component.new(color: "var(--color-primary)", value: "#123456", text: "Primary"))

        assert_includes page.native.to_html, "background-color: var(--color-primary)"
        assert_selector "input[type='color'][value='#123456']"
        assert_selector "[data-flat-pack--color-swatch-target='hex']", text: "#123456"
      end

      def test_applies_stimulus_targets_and_actions
        render_inline(Component.new(color: "#123456", text: "Accent"))

        assert_selector "[data-flat-pack--color-swatch-target='swatch']"
        assert_selector "[data-flat-pack--color-swatch-target='preview']"
        assert_selector "[data-flat-pack--color-swatch-target='input']"
        assert_selector "input[data-action*='flat-pack--color-swatch#update']"
      end

      def test_wires_popover_to_trigger_id
        render_inline(Component.new(color: "#123456", text: "Accent", id: "accent-swatch"))

        assert_selector "button#accent-swatch_trigger"
        assert_selector "[data-flat-pack--popover-trigger-id-value='accent-swatch_trigger']"
      end

      def test_applies_size_fallback_style_for_lg
        render_inline(Component.new(color: "#123456", size: :lg))

        assert_selector "span[style*='width: 3rem'][style*='height: 3rem']"
      end
    end
  end
end
