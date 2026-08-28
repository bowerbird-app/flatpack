# Color Swatch

## Purpose
Render a circular colour control that shows a colour, optionally names it in a tooltip, and opens a FlatPack popover colour selector on click.

## When to use
Use Color Swatch in theme editors and brand settings. Compose several swatches in a flex row with kit gap tokens when you need a named palette (for example Background, Text, Accent). Do not wrap swatches in `ChipGroup` — that component is for chips.

## Class
- Primary: `FlatPack::ColorSwatch::Component`
- Related classes: `FlatPack::Tooltip::Component`, `FlatPack::Popover::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `color` | String | none | yes | Current colour (American spelling). Prefer `#rrggbb` hex for the native picker; CSS colours and `var(--token)` are accepted for display. Invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Circle size: `:xs`, `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | When true and `text` is present, shows a selected ring and renders `text` under the circle (touch-friendly; does not rely on hover). |
| `name` | String | `nil` | no | Optional form field name for the colour input inside the picker panel. |
| `value` | String | `nil` | no | Optional native input value override. Defaults to `color` when it is a hex colour; otherwise falls back to `#000000` for the picker. |
| `text` | String | `nil` | no | Human label used as tooltip copy, accessible name, picker heading, and the visible caption when `selected` is true. |
| `disabled` | Boolean | `false` | no | Disables the trigger and omits the picker popover. |
| `show_tooltip` | Boolean | `true` | no | Wraps the circle trigger in `FlatPack::Tooltip::Component` when `text` is present. |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `picker_placement` | Symbol | `:bottom` | no | Popover placement for the colour selector: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. `id` seeds the trigger and input ids. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`.
- Selected vs idle: selected shows ring + caption when `text` is present.
- Click the circle to open the FlatPack popover picker; the native `<input type="color">` lives inside that panel.

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
- The circle is a `button` with `aria-label` from `text` (or `"Color"`), `aria-haspopup="dialog"`, and `aria-expanded` managed by `flat-pack--popover`.
- Selected state keeps the name visible without hover so touch users can see which swatch is live.
- Tooltip content uses `role="tooltip"` via `FlatPack::Tooltip::Component` when `text` is present.
- The picker panel is a FlatPack popover; Escape and outside click close it.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--color-swatch`, `flat-pack--popover`, and `flat-pack--tooltip` when tooltips are enabled.
- Composes `FlatPack::Popover::Component` for the colour selector panel and `FlatPack::Tooltip::Component` for the name on hover/focus.
