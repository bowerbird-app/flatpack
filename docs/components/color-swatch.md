# Color Swatch

## Purpose
Render a circular colour control that shows a colour, optionally names it in a tooltip, and lets the user pick a new colour with the native colour input.

## When to use
Use Color Swatch in theme editors, brand settings, and compact colour rows where hosts compose several named swatches (for example Background, Text, Accent) with `ChipGroup` or `Grid`.

## Class
- Primary: `FlatPack::ColorSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`, `FlatPack::ChipGroup::Component`, `FlatPack::Grid::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `color` | String | none | yes | Current colour (American spelling). Prefer `#rrggbb` hex for the native picker; CSS colours and `var(--token)` are accepted for display. Invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | When true and `text` is present, shows a selected ring and renders `text` under the circle (touch-friendly; does not rely on hover). |
| `name` | String | `nil` | no | Optional form field name for the native `<input type="color">`. Omit for display-only composition. |
| `value` | String | `nil` | no | Optional native input value override. Defaults to `color` when it is a hex colour; otherwise falls back to `#000000` for the picker. |
| `text` | String | `nil` | no | Human label used as tooltip copy, `aria-label`, and the visible caption when `selected` is true. |
| `disabled` | Boolean | `false` | no | Disables the colour input and dims the control. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle in `FlatPack::Tooltip::Component` when `text` is present. Boolean-like values such as `"false"` are cast. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` is applied to the colour input. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`.
- Selected vs idle: selected shows ring + caption when `text` is present; idle relies on tooltip for the name.

## Example
```erb
<%= render FlatPack::ChipGroup::Component.new do %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#f8f9fa",
    text: "Background",
    name: "theme[background]",
    selected: true,
    size: :lg
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#333333",
    text: "Text",
    name: "theme[text]",
    size: :lg
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#321100",
    text: "Accent",
    name: "theme[accent]",
    size: :lg
  ) %>
<% end %>
```

## Accessibility
- The colour input uses `aria-label` from `text`, or `"Color"` when `text` is omitted.
- Selected state keeps the name visible without hover so touch users can see which swatch is live.
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component` when `text` is present.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--color-swatch` (keeps the circle in sync when the native picker changes).
- Composes `FlatPack::Tooltip::Component` (`flat-pack--tooltip`) when `show_tooltip` is true and `text` is present.
