# Color Swatch

## Purpose
Render a circular colour control that shows a colour, optionally names it in a tooltip, and opens the native browser colour picker on click.

## When to use
Use Color Swatch in theme editors and brand settings. Compose several swatches in a flex row with kit gap tokens when you need a named palette (for example Background, Text, Accent). Do not wrap swatches in `ChipGroup` — that component is for chips.

## Class
- Primary: `FlatPack::ColorSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `color` | String | none | yes | Current colour (American spelling). Prefer `#rrggbb` hex for the native picker; CSS colours and `var(--token)` are accepted for display. Invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | When true, shows a selected ring on the circle. |
| `name` | String | `nil` | no | Optional form field name for the native colour input. |
| `value` | String | `nil` | no | Optional native input value override. Defaults to `color` when it is a hex colour; otherwise falls back to `#000000` for the picker. |
| `text` | String | `nil` | no | Human label used as tooltip copy and accessible name. |
| `disabled` | Boolean | `false` | no | Disables the native colour input. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle in `FlatPack::Tooltip::Component` when `text` is present. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` is applied to the colour input. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`.
- Selected vs idle: selected shows a ring on the circle.
- Click the circle to open the native `<input type="color">` dialog directly — no intermediate panel.

## Example
```erb
<div class="flex flex-wrap items-start gap-[var(--stack-gap-md)]">
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
</div>
```

## Accessibility
- The control is a native `input[type="color"]` covering the circle, with `aria-label` from `text` (or `"Color"`).
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component` when `text` is present.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--color-swatch`, and `flat-pack--tooltip` when tooltips are enabled.
- Composes `FlatPack::Tooltip::Component` for the name on hover/focus.
