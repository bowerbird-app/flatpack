# frozen_string_literal: true

require "test_helper"

module FlatPack
  module RangeInput
    class ComponentTest < ViewComponent::TestCase
      def test_uses_kit_range_input_class
        render_inline(Component.new(name: "volume", value: 50))

        html = page.native.to_html

        assert_selector "input.fp-range-input[type='range']"
        assert_includes html, "--range-progress: 50.0%"
        refute_includes html, "accent-[var(--color-primary)]"
      end

      def test_sets_range_progress_from_custom_min_and_max
        render_inline(Component.new(name: "temperature", min: -20, max: 40, value: 20))

        assert_includes page.native.to_html, "--range-progress: 66.6667%"
      end

      def test_sets_range_progress_at_minimum
        render_inline(Component.new(name: "volume", min: 0, max: 100, value: 0))

        assert_includes page.native.to_html, "--range-progress: 0.0%"
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

      def test_renders_help_text
        render_inline(Component.new(name: "volume", help_text: "Drag to set the preferred volume."))

        assert_selector "p#volume_help_text", text: "Drag to set the preferred volume."
        assert_selector "input[aria-describedby='volume_help_text']"
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

        assert_selector "[data-action='input->flat-pack--range-input#update change->flat-pack--range-input#update']"
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

      def test_default_markup_omits_size_slider_chrome
        render_inline(Component.new(name: "volume", value: 50))

        html = page.native.to_html

        assert_selector "div.relative > input.fp-range-input[type='range']"
        refute_selector ".fp-range-input-ends"
        refute_selector ".fp-range-input-glyph"
        refute_selector ".fp-range-input-end-icon"
        refute_selector ".fp-range-input-preview"
        refute_selector ".fp-range-input-ticks"
        refute_selector ".fp-range-input-track"
        refute_includes html, "preview-selector"
        refute_includes html, "--fp-range-value"
        refute_includes html, "--fp-range-scale"
      end

      def test_size_variant_renders_theme_font_glyphs
        render_inline(Component.new(
          name: "text_size",
          variant: :size,
          label: "Text size",
          min: 14,
          max: 32,
          step: 3,
          value: 23
        ))

        assert_selector ".fp-range-input-ends"
        assert_selector ".fp-range-input-glyph--start[aria-hidden='true']", text: "A"
        assert_selector ".fp-range-input-glyph--end[aria-hidden='true']", text: "A"
        assert_selector "input.fp-range-input[aria-label='Text size'][step='3']"
        assert_selector ".fp-range-input-ticks[aria-hidden='true']"
        assert_selector ".fp-range-input-tick", count: 7
        refute_selector "div.relative > input.fp-range-input"
      end

      def test_text_size_variant_aliases_size
        render_inline(Component.new(name: "text_size", variant: :text_size))

        assert_selector ".fp-range-input-glyph--start", text: "A"
        assert_selector ".fp-range-input-glyph--end", text: "A"
      end

      def test_zoom_variant_renders_default_magnifying_icons
        render_inline(Component.new(
          name: "zoom",
          variant: :zoom,
          label: "Icon size",
          min: 1,
          max: 3,
          step: 0.5,
          value: 2
        ))

        assert_selector ".fp-range-input-ends"
        assert_selector ".fp-range-input-end-icon--start[data-flat-pack--icon-name-value='magnifying-glass-minus'][aria-hidden='true']"
        assert_selector ".fp-range-input-end-icon--end[data-flat-pack--icon-name-value='magnifying-glass-plus'][aria-hidden='true']"
        assert_selector "input.fp-range-input[aria-label='Icon size'][step='0.5']"
        assert_selector ".fp-range-input-tick", count: 5
      end

      def test_custom_end_icons_without_variant
        render_inline(Component.new(
          name: "custom",
          start_icon: :minus,
          end_icon: :plus
        ))

        assert_selector ".fp-range-input-end-icon--start[data-flat-pack--icon-name-value='minus']"
        assert_selector ".fp-range-input-end-icon--end[data-flat-pack--icon-name-value='plus']"
        refute_selector ".fp-range-input-glyph"
      end

      def test_start_icon_overrides_size_glyph
        render_inline(Component.new(
          name: "mixed",
          variant: :size,
          start_icon: :minus
        ))

        assert_selector ".fp-range-input-end-icon--start[data-flat-pack--icon-name-value='minus']"
        assert_selector ".fp-range-input-glyph--end", text: "A"
      end

      def test_preview_slot_sets_runtime_custom_properties
        render_inline(Component.new(name: "reading", min: 14, max: 32, value: 18)) do |range|
          range.with_preview { "A" }
        end

        html = page.native.to_html

        assert_selector "[data-flat-pack--range-input-target='preview']", text: "A"
        assert_selector ".fp-range-input-preview"
        assert_includes html, "--fp-range-value: 18"
        assert_includes html, "--fp-range-scale: 0.2222"
        assert_includes html, "--fp-range-max: 32"
      end

      def test_preview_renders_below_the_slider
        render_inline(Component.new(name: "reading", variant: :size, min: 14, max: 32, step: 3, value: 23)) do |range|
          range.with_preview { "A" }
        end

        html = page.native.to_html
        input_at = html.index("fp-range-input-track")
        preview_at = html.index("fp-range-input-preview")

        assert input_at
        assert preview_at
        assert_operator preview_at, :>, input_at
      end

      def test_ticks_opt_in_on_default_variant
        render_inline(Component.new(name: "volume", ticks: true, min: 0, max: 100, step: 25, value: 50))

        assert_selector ".fp-range-input-tick", count: 5
        refute_selector ".fp-range-input-ends"
      end

      def test_ticks_opt_out_on_size_variant
        render_inline(Component.new(
          name: "text_size",
          variant: :size,
          ticks: false,
          min: 14,
          max: 32,
          step: 3
        ))

        refute_selector ".fp-range-input-ticks"
        assert_selector ".fp-range-input-glyph--start"
      end

      def test_omits_ticks_when_the_step_count_is_too_dense
        render_inline(Component.new(name: "text_size", variant: :size, min: 0, max: 100, step: 1))

        refute_selector ".fp-range-input-ticks"
        assert_selector "input.fp-range-input[step='1']"
      end

      def test_preview_target_id_becomes_a_selector_value
        render_inline(Component.new(name: "reading", preview_target: "reading-preview"))

        assert_selector "[data-flat-pack--range-input-preview-selector-value='#reading-preview']"
      end

      def test_preview_target_keeps_an_explicit_selector
        render_inline(Component.new(name: "reading", preview_target: ".reading-preview"))

        assert_selector "[data-flat-pack--range-input-preview-selector-value='.reading-preview']"
      end

      def test_disabled_size_slider_still_dims_the_input
        render_inline(Component.new(name: "text_size", variant: :size, disabled: true, value: 20))

        assert_selector "input.fp-range-input[disabled]"
        assert_selector ".fp-range-input-glyph--start"
      end

      def test_raises_on_invalid_variant
        error = assert_raises(ArgumentError) do
          Component.new(name: "volume", variant: :huge)
        end

        assert_match(/Invalid variant/, error.message)
      end

      def test_raises_on_non_string_preview_target
        assert_raises(ArgumentError) do
          Component.new(name: "volume", preview_target: 12)
        end
      end

      def test_raises_on_invalid_ticks
        assert_raises(ArgumentError) do
          Component.new(name: "volume", ticks: "yes")
        end
      end

      def test_raises_on_non_positive_step
        assert_raises(ArgumentError) do
          Component.new(name: "volume", step: 0)
        end
      end
    end
  end
end
