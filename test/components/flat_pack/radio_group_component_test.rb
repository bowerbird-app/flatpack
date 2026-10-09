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

      def test_renders_help_text
        render_inline(Component.new(name: "color", options: ["Red", "Blue"], help_text: "Choose one option."))

        assert_selector "p#color_help_text", text: "Choose one option."
        assert_selector "input[aria-describedby='color_help_text']", count: 2
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
        assert_includes html, "border-[var(--color-error)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "color", options: ["Red"], class: "custom-radio"))

        assert_selector "input.custom-radio"
      end

      def test_has_base_flat_pack_radio_class
        render_inline(Component.new(name: "color", options: ["Red"]))

        assert_selector "input.flat-pack-radio"
      end

      def test_uses_theme_primary_css_var_classes
        render_inline(Component.new(name: "color", options: ["Red"]))

        html = page.native.to_html
        assert_includes html, "accent-[var(--color-primary)]"
        assert_includes html, "checked:bg-[var(--color-primary)]"
        assert_includes html, "checked:border-[var(--color-primary)]"
        assert_includes html, "checked:text-[var(--color-primary-text)]"
        refute_includes html, "accent-primary"
        refute_includes html, "checked:bg-primary"
        refute_includes html, "checked:border-primary"
        refute_match(/(?:^|[\s"'])text-primary(?:[\s"']|$)/, html)
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

      def test_uses_shared_checkbox_size_css_var
        render_inline(Component.new(name: "color", options: ["Red", "Blue"]))

        html = page.native.to_html
        assert_includes html, "h-[var(--checkbox-size)]"
        assert_includes html, "w-[var(--checkbox-size)]"
        assert_includes html, "--checkbox-size: 1.25rem"
        refute_includes html, "h-4 w-4"
      end

      def test_renders_small_size
        render_inline(Component.new(name: "color", options: ["Red"], size: :sm))

        assert_includes page.native.to_html, "--checkbox-size: 1rem"
      end

      def test_renders_large_size
        render_inline(Component.new(name: "color", options: ["Red"], size: :lg))

        assert_includes page.native.to_html, "--checkbox-size: 1.5rem"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(name: "color", options: ["Red"], size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_default_variant_keeps_plain_radio_markup
        options = [{label: "Red", value: "red", icon: "heart", description: "Warm"}]
        render_inline(Component.new(name: "color", options: options, value: "red"))

        assert_selector "fieldset.space-y-2"
        assert_selector "div.flex.items-center"
        assert_selector "input.flat-pack-radio[type='radio'][name='color'][checked]"
        assert_selector "label.ml-2", text: "Red"
        refute_selector "input.sr-only"
        refute_selector "svg"
        refute_text "Warm"
        refute_includes page.native.to_html, "flex-wrap"
        refute_includes page.native.to_html, "min-h-[7rem]"
        refute_includes page.native.to_html, "fp-button"
        refute_includes page.native.to_html, "mt-4"
      end

      def test_raises_error_for_invalid_variant
        error = assert_raises(ArgumentError) do
          Component.new(name: "color", options: ["Red"], variant: :pills)
        end

        assert_includes error.message, "Invalid variant"
        assert_includes error.message, "default"
        assert_includes error.message, "inline"
        assert_includes error.message, "cards"
        assert_includes error.message, "swatches"
      end

      def test_inline_variant_renders_pills_with_icons
        options = [
          {label: "Daily", value: "daily", icon: "sun"},
          {label: "Weekly", value: "weekly"}
        ]
        render_inline(Component.new(
          name: "cadence",
          options: options,
          variant: :inline,
          value: "daily",
          label: "How often?"
        ))

        assert_selector "legend", text: "How often?"
        assert_selector "input[type='radio'][name='cadence']", count: 2
        assert_selector "input.sr-only.peer[value='daily'][checked]"
        refute_selector "input.flat-pack-radio"
        assert_selector "fieldset.flex.flex-wrap"
        assert_selector "label.fp-button[for='cadence_daily'][data-fp-style='secondary']"
        assert_selector "svg[data-flat-pack--icon-name-value='sun']"
        assert_selector "label", text: "Weekly"
        refute_selector "svg[data-flat-pack--icon-name-value='calendar-days']"
        html = page.native.to_html
        assert_includes html, "rounded-[var(--button-border-radius)]"
        assert_includes html, "px-[var(--button-padding-x-md)]"
        assert_includes html, "has-[:checked]:bg-[var(--button-primary-background-color)]"
        assert_includes html, "has-[:checked]:text-[var(--button-primary-text-color)]"
      end

      def test_inline_variant_hides_descriptions
        options = [{label: "Daily", value: "daily", description: "Every morning"}]
        render_inline(Component.new(name: "cadence", options: options, variant: :inline))

        refute_text "Every morning"
      end

      def test_cards_variant_renders_icons_and_descriptions
        options = [
          {label: "Email", value: "email", icon: "envelope", description: "A note in your inbox"},
          {label: "Text", value: "sms", description: "A short message"}
        ]
        render_inline(Component.new(
          name: "channel",
          options: options,
          variant: :cards,
          value: "email"
        ))

        assert_selector "input[type='radio'][name='channel']", count: 2
        assert_selector "input.sr-only.peer[value='email'][checked]"
        refute_selector "input.flat-pack-radio"
        assert_selector "fieldset.grid"
        assert_selector "svg[data-flat-pack--icon-name-value='envelope']"
        assert_text "A note in your inbox"
        assert_text "A short message"
        refute_selector "svg[data-flat-pack--icon-name-value='chat-bubble-left']"
        html = page.native.to_html
        assert_includes html, "items-center"
        assert_includes html, "text-center"
        assert_includes html, "w-6 h-6"
        refute_includes html, "h-10 w-10"
        refute_includes html, "group-has-[:checked]:bg-[color-mix(in_oklab,var(--color-primary)_18%"
      end

      def test_visual_variants_keep_string_and_array_options
        render_inline(Component.new(name: "size", options: ["Small", "Large"], variant: :inline))
        assert_selector "input[value='Small']"
        assert_selector "input[value='Large']"

        render_inline(Component.new(
          name: "plan",
          options: [["Starter", "s"], ["Pro", "p"]],
          variant: :cards
        ))
        assert_selector "label", text: "Starter"
        assert_selector "input[value='s']"
      end

      def test_visual_variant_checked_disabled_error_and_required
        options = [
          {label: "Air", value: "air"},
          {label: "Ground", value: "ground", disabled: true}
        ]
        render_inline(Component.new(
          name: "ship",
          options: options,
          variant: :cards,
          value: "air",
          required: true,
          error: "Pick a speed",
          help_text: "Choose how this should arrive.",
          disabled: false
        ))

        assert_selector "input[value='air'][checked][required]"
        assert_selector "input[value='ground'][disabled]"
        refute_selector "input[value='air'][disabled]"
        assert_selector "p", text: "Pick a speed"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby*='ship_help_text']", count: 2
        assert_selector "input[aria-describedby*='ship_error']", count: 2
        html = page.native.to_html
        assert_includes html, "border-[var(--color-error)]"
        assert_includes html, "has-[:checked]:border-[var(--color-primary)]"
        assert_includes html, "mt-4 text-sm text-[var(--color-error)]"
        assert_includes html, "mt-4 text-xs text-[var(--surface-muted-content-color)]"
      end

      def test_default_variant_keeps_tight_help_and_error_spacing
        render_inline(Component.new(
          name: "color",
          options: ["Red"],
          help_text: "Pick one.",
          error: "Need a colour."
        ))

        html = page.native.to_html
        assert_includes html, "mt-1 text-xs text-[var(--surface-muted-content-color)]"
        assert_includes html, "mt-2 text-sm text-[var(--color-error)]"
        refute_includes html, "mt-4"
      end

      def test_inline_variant_uses_looser_help_spacing
        render_inline(Component.new(
          name: "cadence",
          options: ["Daily"],
          variant: :inline,
          help_text: "Pick the cadence that fits this project."
        ))

        assert_includes page.native.to_html, "mt-4 text-xs text-[var(--surface-muted-content-color)]"
        refute_includes page.native.to_html, "mt-1 text-xs"
      end

      def test_inline_variant_respects_group_disabled
        render_inline(Component.new(
          name: "color",
          options: ["Red", "Blue"],
          variant: :inline,
          disabled: true
        ))

        assert_selector "input[disabled]", count: 2
      end

      def test_visual_variant_applies_custom_class_to_input
        render_inline(Component.new(
          name: "color",
          options: ["Red"],
          variant: :inline,
          class: "custom-radio"
        ))

        assert_selector "input.custom-radio.sr-only"
      end

      def test_swatches_variant_renders_colour_circles_with_real_radios
        options = [
          {label: "Ocean", value: "#1d4ed8"},
          {label: "Snow", value: "#ffffff", color: "#ffffff"},
          {label: "Ink", value: "ink", color: "#0a0a0a"}
        ]
        render_inline(Component.new(
          name: "cover_color",
          options: options,
          variant: :swatches,
          value: "#1d4ed8",
          label: "Cover colour"
        ))

        assert_selector "legend", text: "Cover colour"
        assert_selector "input[type='radio'][name='cover_color']", count: 3
        assert_selector "input.sr-only.peer[value='#1d4ed8'][checked]"
        assert_selector "input[value='ink']"
        refute_selector "input.flat-pack-radio"
        refute_selector "input[type='color']"
        refute_selector "[data-controller='flat-pack--color-swatch']"
        assert_selector "fieldset.flex.flex-wrap"
        assert_selector "label.flat-pack-radio-swatch[for='cover_color__1d4ed8']"
        assert_selector "span.sr-only", text: "Ocean"
        assert_selector "[data-controller='flat-pack--tooltip']", count: 3
        assert_selector "[role='tooltip']", text: "Ocean"
        html = page.native.to_html
        assert_includes html, "background-color: #1d4ed8"
        assert_includes html, "background-color: #ffffff"
        assert_includes html, "background-color: #0a0a0a"
        assert_includes html, "group-has-[:checked]:ring-[var(--color-swatch-selected-ring-color)]"
        assert_includes html, "group-has-[:checked]:ring-offset-[var(--color-swatch-ring-offset-color)]"
        assert_includes html, "h-10 w-10"
        refute_includes html, "fp-button"
        refute_includes html, "min-h-[7rem]"
      end

      def test_swatches_variant_defaults_color_from_hex_value
        render_inline(Component.new(
          name: "accent",
          options: ["#38bdf8", "#0a0a0a"],
          variant: :swatches
        ))

        html = page.native.to_html
        assert_selector "input[value='#38bdf8']"
        assert_includes html, "background-color: #38bdf8"
        assert_includes html, "background-color: #0a0a0a"
      end

      def test_swatches_variant_expands_short_hex
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Red", value: "red", color: "#f00"}],
          variant: :swatches
        ))

        assert_includes page.native.to_html, "background-color: #ff0000"
      end

      def test_swatches_variant_uses_dark_check_on_light_fill
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Snow", value: "#ffffff"}],
          variant: :swatches,
          value: "#ffffff"
        ))

        html = page.native.to_html
        assert_includes html, "text-[var(--color-swatch-check-on-light)]"
        assert_selector "svg[aria-hidden='true']"
      end

      def test_swatches_variant_uses_light_check_on_dark_fill
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Ink", value: "#0a0a0a"}],
          variant: :swatches,
          value: "#0a0a0a"
        ))

        assert_includes page.native.to_html, "text-[var(--color-swatch-check-on-dark)]"
      end

      def test_swatches_variant_can_hide_tooltips
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Ocean", value: "#1d4ed8"}],
          variant: :swatches,
          show_tooltip: false
        ))

        refute_selector "[data-controller='flat-pack--tooltip']"
        assert_selector "span.sr-only", text: "Ocean"
        refute_includes page.native.to_html, "show_tooltip"
      end

      def test_swatches_variant_respects_tooltip_placement
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Ocean", value: "#1d4ed8"}],
          variant: :swatches,
          tooltip_placement: :bottom
        ))

        assert_selector "[data-flat-pack--tooltip-placement-value='bottom']"
      end

      def test_swatches_variant_sizes_match_color_swatch
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Ocean", value: "#1d4ed8"}],
          variant: :swatches,
          size: :sm
        ))
        assert_includes page.native.to_html, "h-8 w-8"
        assert_includes page.native.to_html, "width: 2rem; height: 2rem"

        render_inline(Component.new(
          name: "accent_lg",
          options: [{label: "Ocean", value: "#1d4ed8"}],
          variant: :swatches,
          size: :lg
        ))
        assert_includes page.native.to_html, "h-12 w-12"
        assert_includes page.native.to_html, "width: 3rem; height: 3rem"
      end

      def test_swatches_variant_keeps_disabled_error_required_and_help
        options = [
          {label: "Ocean", value: "#1d4ed8"},
          {label: "Coral", value: "#f97316", disabled: true}
        ]
        render_inline(Component.new(
          name: "cover",
          options: options,
          variant: :swatches,
          value: "#1d4ed8",
          required: true,
          error: "Pick a cover colour.",
          help_text: "Used on the share card."
        ))

        assert_selector "input[value='#1d4ed8'][checked][required]"
        assert_selector "input[value='#f97316'][disabled]"
        refute_selector "input[value='#1d4ed8'][disabled]"
        assert_selector "p", text: "Pick a cover colour."
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby*='cover_help_text']", count: 2
        html = page.native.to_html
        assert_includes html, "border-[var(--color-error)]"
        assert_includes html, "mt-4 text-sm text-[var(--color-error)]"
        assert_includes html, "mt-4 text-xs text-[var(--surface-muted-content-color)]"
        assert_includes html, "opacity-50"
      end

      def test_swatches_variant_respects_group_disabled
        render_inline(Component.new(
          name: "accent",
          options: [{label: "Ocean", value: "#1d4ed8"}, {label: "Ink", value: "#0a0a0a"}],
          variant: :swatches,
          disabled: true
        ))

        assert_selector "input[disabled]", count: 2
      end

      def test_swatches_variant_requires_a_colour
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "accent",
            options: [{label: "Ocean", value: "ocean"}],
            variant: :swatches
          )
        end

        assert_includes error.message, "needs a color"
      end

      def test_swatches_variant_rejects_unsafe_color
        assert_raises(ArgumentError) do
          Component.new(
            name: "accent",
            options: [{label: "Bad", value: "bad", color: "not-a-color"}],
            variant: :swatches
          )
        end
      end

      def test_raises_error_for_invalid_tooltip_placement
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "accent",
            options: [{label: "Ocean", value: "#1d4ed8"}],
            variant: :swatches,
            tooltip_placement: :diagonal
          )
        end

        assert_includes error.message, "Invalid tooltip_placement"
      end

      def test_default_inline_and_cards_do_not_render_swatch_chrome
        render_inline(Component.new(name: "color", options: ["Red"], show_tooltip: true))
        html = page.native.to_html
        refute_includes html, "flat-pack-radio-swatch"
        refute_includes html, "--color-swatch-selected-ring-color"
        refute_selector "[data-controller='flat-pack--tooltip']"
        refute_includes html, "show_tooltip"

        render_inline(Component.new(name: "cadence", options: ["Daily"], variant: :inline))
        html = page.native.to_html
        refute_includes html, "flat-pack-radio-swatch"
        refute_includes html, "--color-swatch-selected-ring-color"

        render_inline(Component.new(name: "plan", options: ["Starter"], variant: :cards))
        html = page.native.to_html
        refute_includes html, "flat-pack-radio-swatch"
        refute_includes html, "--color-swatch-selected-ring-color"
      end
    end
  end
end
