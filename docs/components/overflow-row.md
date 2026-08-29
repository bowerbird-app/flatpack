# Overflow Row

## Purpose
Lay out same-size items in a single horizontal row that scrolls sideways only when they do not fit, with a soft trailing fade while more content remains to the right.

## When to use
Use Overflow Row for compact same-size controls that should stay on one line — for example a row of `ColorSwatch` and `FontSwatch` circles in a theme editor. Prefer this over `flex-wrap` when a second row is unwanted. Do not use `ChipGroup` for swatches (`ChipGroup` is for chips and wraps by default). Do not use `Grid` for this job.

## Class
- Primary: `FlatPack::OverflowRow::Component`
- Related classes: `FlatPack::ColorSwatch::Component`, `FlatPack::FontSwatch::Component`, `FlatPack::ChipGroup::Component`, `FlatPack::Grid::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `gap` | Symbol | `:md` | no | Row gap preset mapped to stack tokens: `:sm` → `--stack-gap-sm`, `:md` → `--stack-gap-md`, `:lg` → `--stack-gap-lg`. Invalid values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. |

## Slots
Default block content; each child participates as a row item. Hosts compose children — Overflow Row does not own swatch internals.

## Variants
None. Overflow and fade are automatic from content width vs container width.

## Example
```erb
<%= render FlatPack::OverflowRow::Component.new(gap: :md) do %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#f8f9fa",
    text: "Background",
    selected: true,
    size: :lg
  ) %>
  <%= render FlatPack::ColorSwatch::Component.new(
    color: "#333333",
    text: "Text",
    size: :lg
  ) %>
  <%= render FlatPack::FontSwatch::Component.new(
    font: "Georgia, serif",
    options: [["Sans", "ui-sans-serif"], ["Georgia", "Georgia, serif"]],
    text: "Georgia",
    size: :lg
  ) %>
<% end %>
```

## Accessibility
Overflow Row is structural layout only. Accessibility comes from the children (for example swatch tooltips and form controls). Scrolling uses native overflow so trackpad and touch work without custom chrome; the native scrollbar is hidden.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--overflow-row` (toggles trailing fade via `data-can-scroll-end`).
- Theme tokens: `--overflow-row-gap`, `--overflow-row-fade-size`.
