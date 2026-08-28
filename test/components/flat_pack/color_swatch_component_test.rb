# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ColorSwatch
    class ComponentTest < ViewComponent::TestCase
      def test_renders_color_swatch_with_text
        render_inline(Component.new(text: "Background", value: "#ffffff"))

        assert_selector "[data-controller='flat-pack--color-swatch']"
        assert_selector "input[type='color'][value='#ffffff']"
        assert_selector "input[aria-label='Background']"
        assert_includes page.native.to_html, "background-color: #ffffff"
      end

      def test_requires_text
        assert_raises(ArgumentError) do
          Component.new(text: "")
        end
      end

      def test_renders_form_name_when_provided
        render_inline(Component.new(text: "Accent", value: "#333333", name: "theme[accent]"))

        assert_selector "input[type='color'][name='theme[accent]']"
      end

      def test_omits_form_name_when_absent
        render_inline(Component.new(text: "Accent", value: "#333333"))

        refute_selector "input[name]"
      end

      def test_renders_selected_label
        render_inline(Component.new(text: "Background", value: "#f8f9fa", selected: true))

        assert_selector "[data-selected='true']", text: "Background"
        assert_includes page.native.to_html, "ring-[var(--color-swatch-selected-ring-color)]"
      end

      def test_hides_label_when_not_selected
        render_inline(Component.new(text: "Background", value: "#f8f9fa", selected: false))

        assert_selector "[data-selected='false']"
        refute_selector "span.text-xs", text: "Background"
      end

      def test_wraps_with_tooltip_by_default
        render_inline(Component.new(text: "Text", value: "#333333"))

        assert_selector "[data-controller='flat-pack--tooltip']"
        assert_selector "[role='tooltip']", text: "Text"
      end

      def test_can_disable_tooltip
        render_inline(Component.new(text: "Text", value: "#333333", show_tooltip: false))

        refute_selector "[data-controller='flat-pack--tooltip']"
      end

      def test_renders_sizes
        Component::SIZES.each do |size, classes|
          render_inline(Component.new(text: "Accent", value: "#000000", size: size))

          assert_includes page.native.to_html, classes.split.first
        end
      end

      def test_raises_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(text: "Accent", size: :huge)
        end
      end

      def test_defaults_invalid_color_to_black
        render_inline(Component.new(text: "Accent", value: "not-a-color"))

        assert_selector "input[type='color'][value='#000000']"
        assert_includes page.native.to_html, "background-color: #000000"
      end

      def test_expands_short_hex
        render_inline(Component.new(text: "Accent", value: "#abc"))

        assert_selector "input[type='color'][value='#aabbcc']"
      end

      def test_accepts_css_variables_for_display
        render_inline(Component.new(text: "Primary", value: "var(--color-primary)"))

        assert_includes page.native.to_html, "background-color: var(--color-primary)"
        assert_selector "input[type='color'][value='#000000']"
      end

      def test_renders_disabled_state
        render_inline(Component.new(text: "Accent", value: "#333333", disabled: true))

        assert_selector "input[type='color'][disabled]"
        assert_includes page.native.to_html, "cursor-not-allowed"
      end

      def test_applies_stimulus_targets_and_actions
        render_inline(Component.new(text: "Accent", value: "#123456"))

        assert_selector "[data-flat-pack--color-swatch-target='swatch']"
        assert_selector "[data-flat-pack--color-swatch-target='input']"
        assert_selector "input[data-action*='flat-pack--color-swatch#update']"
      end
    end
  end
end
