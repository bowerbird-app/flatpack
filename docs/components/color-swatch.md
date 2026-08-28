# Color Swatch

## Purpose
Render a circular colour control that shows a colour, names it in a tooltip, and lets the user pick a new colour with the native colour input.

## When to use
Use Color Swatch in theme editors, brand settings, and compact colour rows where hosts compose several named swatches (for example Background, Text, Accent).

## Class
- Primary: `FlatPack::ColorSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | none | yes | Human label used as tooltip copy and as the visible caption when `selected` is true. |
| `value` | String | `"#000000"` | no | Current colour. Prefer `#rrggbb` hex for the native picker; CSS colours and `var(--token)` are accepted for display. Invalid values fall back to `#000000`. |
| `name` | String | `nil` | no | Optional form field name for the native `<input type="color">`. Omit for display-only composition. |
| `selected` | Boolean | `false` | no | When true, shows a selected ring and renders `text` under the circle (touch-friendly; does not rely on hover). |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`, `:xl`; invalid values raise `ArgumentError`. |
| `disabled` | Boolean | `false` | no | Disables the colour input and dims the control. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle in `FlatPack::Tooltip::Component` with `text`. Boolean-like values such as `"false"` are cast. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` is applied to the colour input. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`, `:xl`.
- Selected vs idle: selected shows ring + caption; idle relies on tooltip for the name.

## Example
```erb
<div class="flex items-start gap-[var(--stack-gap-md)]">
  <%= render FlatPack::ColorSwatch::Component.new(
    text: "Background",
    value: "#f8f9fa",
    name: "theme[background]",
    selected: true
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    text: "Text",
    value: "#333333",
    name: "theme[text]"
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    text: "Accent",
    value: "#321100",
    name: "theme[accent]"
  ) %>
</div>
```

## Accessibility
- The colour input uses `aria-label` from `text`.
- Selected state keeps the name visible without hover so touch users can see which swatch is live.
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--color-swatch` (keeps the circle in sync when the native picker changes).
- Composes `FlatPack::Tooltip::Component` (`flat-pack--tooltip`) when `show_tooltip` is true.
