# Range Input

## Purpose
Provide a slider control for selecting numeric values within a bounded range, with an opt-in size-slider presentation for smaller ↔ bigger adjustments.

## When to use
Use `RangeInput` for numeric adjustments such as volume, opacity, thresholds, or scoring where dragging is faster than typing. Pass `variant: :size` (or `:text_size`) when the control should read like a phone text-size slider. Pass `variant: :zoom` or `start_icon:` / `end_icon:` when the ends should be kit icons.

## Class
- Primary: `FlatPack::RangeInput::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String | none | yes | Form field name for submission. |
| `id` | String | `name` | no | Input id and label `for` binding. |
| `value` | Numeric | `min` | no | Initial slider value. |
| `min` | Numeric | `0` | no | Minimum slider value. Must be less than `max`. |
| `max` | Numeric | `100` | no | Maximum slider value. Must be greater than `min`. |
| `step` | Numeric | `1` | no | Slider increment. Native range snapping and arrow keys move one step. Size and zoom demos use a step that yields 5–7 values. |
| `label` | String | `nil` | no | Optional visible label. Also used as the input's accessible name. |
| `help_text` | String | `nil` | no | Optional plain-text guidance rendered below the slider in muted `text-xs` styling. Only plain `String` values are accepted; HTML-like content is escaped as text. |
| `show_value` | Boolean | `true` | no | Shows current value beside the label. |
| `disabled` | Boolean | `false` | no | Disables interaction. End glyphs and icons dim with the input. |
| `variant` | Symbol | `:default` | no | Presentation. `:default` is today's slider. `:size` and `:text_size` put a small and large `A` (theme font, not an image) at the track ends. `:zoom` puts `magnifying-glass-minus` and `magnifying-glass-plus` at the ends. Invalid values raise `ArgumentError`. |
| `start_icon` | Symbol/String | `nil` | no | Kit icon name for the left (start) end. Any `FlatPack::Shared::IconComponent` name. Overrides the start `A` on `:size` / `:text_size`, and the default minus glass on `:zoom`. On `:default`, passing this (or `end_icon:`) opts into the end-icon layout. |
| `end_icon` | Symbol/String | `nil` | no | Kit icon name for the right (end) end. Same rules as `start_icon:`. |
| `preview_target` | String | `nil` | no | CSS selector or element id. While dragging, Stimulus writes `--fp-range-value` (current number) and `--fp-range-scale` (0–1 from `min`/`max`) on matching elements. A bare id becomes `#id`. Omit when you do not need live preview. Must be a `String`. |
| `ticks` | Boolean | `nil` | no | Visible notches under the track, one per `step`. Omit to show ticks on `:size` / `:text_size` / `:zoom` and hide them on `:default`. Pass `true` or `false` to override. Ticks render only when the step count is between 2 and 24. |
| `**system_arguments` | Hash | `{}` | no | Standard HTML attributes merged into the container. |

## Slots
- `with_preview` — optional sample **below** the track. The wrapper is `.fp-range-input-preview` (no fill or border) and a Stimulus `preview` target. Server-rendered `--fp-range-value`, `--fp-range-scale`, and `--fp-range-max` stay in sync as you drag. For a size slider, put a single `A` in `.fp-range-input-sample`. Use this or `preview_target:`, or both.

## Variants
- Default slider: omit `variant:` (or `variant: :default`). Markup and behaviour match previous releases.
- Size slider: `variant: :size` or `variant: :text_size`. Ticks on by default.
- Zoom slider: `variant: :zoom`. Ticks on by default.
- Custom ends: `start_icon:` / `end_icon:`
- Ticks: omit for the variant default, or pass `ticks: true` / `ticks: false`
- Value display: `show_value: true` (default) or `show_value: false`
- State: enabled or disabled (`disabled: true`)

## Example
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "volume",
  label: "Volume",
  min: 0,
  max: 100,
  step: 1,
  help_text: "Drag to set the preferred volume.",
  value: 50
) %>
```

Text size with a live letter below the track:

```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "text_size",
  label: "Text size",
  variant: :size,
  min: 14,
  max: 32,
  step: 3,
  value: 23,
  show_value: false
) do |range| %>
  <% range.with_preview do %>
    <span class="fp-range-input-sample" aria-hidden="true">A</span>
  <% end %>
<% end %>
```

Zoom with a slot:

```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "icon_size",
  label: "Icon size",
  variant: :zoom,
  min: 1,
  max: 3,
  step: 0.5,
  value: 2
) do |range| %>
  <% range.with_preview do %>
    <span style="display: inline-flex; width: calc(var(--fp-range-value) * 1.5rem); height: calc(var(--fp-range-value) * 1.5rem);">
      <%= render FlatPack::Shared::IconComponent.new(name: :photo, size: :xl, class: "w-full h-full") %>
    </span>
  <% end %>
<% end %>
```

## Accessibility
- Uses native `<input type="range">` semantics.
- Sets `aria-label`, `aria-valuenow`, `aria-valuemin`, and `aria-valuemax`.
- Links `help_text` with `aria-describedby` when present.
- Supports keyboard slider behavior provided by the browser. Arrow keys move one `step`. Focus-visible ring is on the native input.
- End glyphs and icons are decorative (`aria-hidden`). The input keeps the accessible label.
- Disabled: native `disabled` plus muted end glyphs/icons. Thumb stays the primary colour at reduced opacity.
- Reduced motion: thumb colour/shadow transitions are skipped. Preview size follows the value with no extra motion.

## Styling
- Kit class: `.fp-range-input` (unlayered so `appearance: none` beats the browser chrome).
- Size-slider classes (opt-in only): `.fp-range-input-ends`, `.fp-range-input-track`, `.fp-range-input-ticks`, `.fp-range-input-tick`, `.fp-range-input-glyph`, `.fp-range-input-glyph--start`, `.fp-range-input-glyph--end`, `.fp-range-input-end-icon`, `.fp-range-input-preview`, `.fp-range-input-sample`.
- Tokens: `--range-track-color`, `--range-fill-color`, `--range-thumb-color`, `--range-thumb-border-color`, `--range-thumb-shadow`, `--range-thumb-size`, `--range-track-height`.
- Thumb fill (`--range-thumb-color`) aliases `--color-primary`. The ring (`--range-thumb-border-color`) aliases `--surface-background-color`, with `--range-thumb-shadow` for depth. Hosts that set those names keep their overrides.
- Fill percent is the runtime custom property `--range-progress` on the input (server-rendered from `value` / `min` / `max`, then kept in sync by Stimulus). Not a theme token.
- Preview runtime properties (only when a slot or `preview_target:` is used): `--fp-range-value` (current number, unitless), `--fp-range-scale` (0–1), and `--fp-range-max` (`max`, for reserving sample height). Not theme tokens. `.fp-range-input-sample` sizes a single `A` with `font-size: calc(var(--fp-range-value) * 1px)`. The sample sits below the track with no fill or border.
- Size glyphs use `--font-sans` and `--surface-muted-content-color`. They follow light and dark themes.
- The control stays a native range. Dual-handle filters are a separate pattern, not this component. Ticks are one notch per `step` under the track.

## Dependencies
- Core install: `rails generate flat_pack:install`
- Stimulus: `flat-pack--range-input` for live value display, `--range-progress` fill, and `range-input:change` custom events. Preview custom properties are written only when a preview slot or `preview_target:` is present; default sliders do not pay that cost.
- Size and zoom ends compose `FlatPack::Shared::IconComponent` when icons are used.
