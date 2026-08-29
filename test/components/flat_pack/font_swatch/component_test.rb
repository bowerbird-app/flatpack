# frozen_string_literal: true

require "test_helper"

module FlatPack
  module FontSwatch
    class ComponentTest < ViewComponent::TestCase
      DEMO_OPTIONS = [
        ["Sans", "ui-sans-serif"],
        ["Serif", "ui-serif"],
        ["Mono", "ui-monospace"],
        ["Georgia", "Georgia, serif"]
      ].freeze

      def test_renders_font_swatch_with_font
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans"))

        assert_selector "[data-controller='flat-pack--font-swatch']"
        assert_selector "button[aria-label='Sans']"
        assert_includes page.native.to_html, "font-family: ui-sans-serif"
        assert_text "Aa"
      end

      def test_requires_font
        assert_raises(ArgumentError) do
          Component.new(font: "", options: DEMO_OPTIONS)
        end
      end

      def test_rejects_invalid_font
        assert_raises(ArgumentError) do
          Component.new(font: "ui-sans-serif; background: url(javascript:alert(1))", options: DEMO_OPTIONS)
        end
      end

      def test_requires_options
        assert_raises(ArgumentError) do
          Component.new(font: "ui-sans-serif", options: nil)
        end
      end

      def test_rejects_empty_options
        assert_raises(ArgumentError) do
          Component.new(font: "ui-sans-serif", options: [])
        end
      end

      def test_uses_popover_menu_without_native_select
        render_inline(Component.new(font: "ui-serif", options: DEMO_OPTIONS, text: "Serif"))

        assert_selector "[data-controller='flat-pack--popover']"
        assert_selector "[data-flat-pack--font-swatch-target='menu']"
        assert_selector "button[role='option'][data-value='ui-serif'][aria-selected='true']"
        refute_selector "select"
        refute_text "Choose font"
      end

      def test_renders_option_rows_in_their_font_faces
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans"))

        assert_includes page.native.to_html, "font-family: ui-serif"
        assert_includes page.native.to_html, "font-family: ui-monospace"
        assert_includes page.native.to_html, "font-family: Georgia, serif"
        assert_selector "button[role='option']", text: "Serif"
        assert_selector "button[role='option']", text: "Mono"
        assert_selector "button[role='option']", text: "Georgia"
      end

      def test_renders_form_name_on_hidden_input_when_provided
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, name: "appearance[font]", text: "Font"))

        assert_selector "input[type='hidden'][name='appearance[font]'][value='ui-sans-serif']", visible: :hidden
      end

      def test_omits_form_name_when_absent
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Font"))

        assert_selector "input[type='hidden'][value='ui-sans-serif']", visible: :hidden
        refute_selector "input[name]", visible: :hidden
      end

      def test_renders_selected_ring_without_caption
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", selected: true))

        assert_selector "[data-selected='true']"
        assert_includes page.native.to_html, "ring-[var(--font-swatch-selected-ring-color)]"
        refute_selector "span.text-xs", text: "Sans"
      end

      def test_marks_unselected_without_caption
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", selected: false))

        assert_selector "[data-selected='false']"
        refute_selector "span.text-xs", text: "Sans"
      end

      def test_wraps_with_tooltip_when_text_present
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans"))

        assert_selector "[data-controller='flat-pack--tooltip']"
        assert_selector "[role='tooltip']", text: "Sans"
      end

      def test_defaults_tooltip_to_selected_option_label
        render_inline(Component.new(font: "ui-serif", options: DEMO_OPTIONS))

        assert_selector "[role='tooltip']", text: "Serif"
        assert_selector "button[aria-label='Serif']"
      end

      def test_can_disable_tooltip
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", show_tooltip: false))

        refute_selector "[data-controller='flat-pack--tooltip']"
      end

      def test_disables_trigger_and_omits_popover_when_disabled
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", disabled: true))

        assert_selector "button[disabled]"
        assert_selector "input[type='hidden'][disabled]", visible: :hidden
        refute_selector "[data-controller='flat-pack--popover']"
      end

      def test_renders_sizes
        Component::SIZES.each do |size, size_classes|
          render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", size: size))

          assert_includes page.native.to_html, size_classes.split.first
        end
      end

      def test_raises_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, size: :huge)
        end
      end

      def test_accepts_hash_options
        render_inline(Component.new(
          font: "Georgia, serif",
          options: [{label: "Georgia", value: "Georgia, serif"}],
          text: "Georgia"
        ))

        assert_selector "button[role='option'][data-value='Georgia, serif'][aria-selected='true']"
        assert_includes page.native.to_html, "font-family: Georgia, serif"
      end

      def test_accepts_css_variables_for_font
        options = [["Body", "var(--font-body)"]]
        render_inline(Component.new(font: "var(--font-body)", options: options, text: "Body"))

        assert_includes page.native.to_html, "font-family: var(--font-body)"
        assert_selector "button[role='option'][data-value='var(--font-body)'][aria-selected='true']"
      end

      def test_applies_stimulus_targets_and_actions
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans"))

        assert_selector "[data-flat-pack--font-swatch-target='swatch']"
        assert_selector "[data-flat-pack--font-swatch-target='trigger']"
        assert_selector "[data-flat-pack--font-swatch-target='input']", visible: :hidden
        assert_selector "[data-flat-pack--font-swatch-target='menu']", visible: :all
        assert_selector "button[data-action*='flat-pack--font-swatch#select']", visible: :all
        refute_selector "select"
      end

      def test_uses_id_for_trigger
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, text: "Sans", id: "heading-font"))

        assert_selector "button#heading-font"
        assert_selector "[data-flat-pack--popover-trigger-id-value='heading-font']"
      end

      def test_merges_extra_data_on_root
        render_inline(Component.new(
          font: "ui-sans-serif",
          options: DEMO_OPTIONS,
          text: "Sans",
          data: {default_font: "ui-sans-serif", testid: "font-swatch"}
        ))

        assert_selector "[data-controller='flat-pack--font-swatch'][data-default-font='ui-sans-serif'][data-testid='font-swatch']"
      end

      def test_applies_size_fallback_style_for_lg
        render_inline(Component.new(font: "ui-sans-serif", options: DEMO_OPTIONS, size: :lg))

        assert_includes page.native.to_html, "width: 3rem"
        assert_includes page.native.to_html, "height: 3rem"
      end
    end
  end
end
