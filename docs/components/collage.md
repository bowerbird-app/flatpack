# Collage

## Purpose
Scatter any host content in a grid, with a slight tilt and offset, and stack it straight on a small screen.

## When to use
Use Collage for a loose cluster of cards, photos, or notes. The kit supplies the layout only. A photo card is `FlatPack::Card::Component` and `FlatPack::Badge::Component` inside `item`. Use `Grid` when every cell should line up. Use `Masonry` when mixed ratios should pack without a shared row.

## Class
- Primary: `FlatPack::Collage::Component`
- Related classes: `FlatPack::Collage::Item`, `FlatPack::Card::Component`, `FlatPack::Grid::Component`, `FlatPack::EmptyState::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `columns` | Integer | `3` | No | Column count at and above `stack_below`. An integer from 1 to 6. Invalid values raise `ArgumentError`. |
| `scatter` | Symbol | `:subtle` | No | Tilt and offset. Allowed: `:subtle`, `:loose`, `:none`. `:none` sits square. Invalid values raise `ArgumentError`. |
| `stack_below` | Symbol | `:md` | No | Below this breakpoint the items are one column and the tilt is off. Allowed: `:sm`, `:md`, `:lg`, `:xl`. Not List `stack_below`. Invalid values raise `ArgumentError`. |
| `motion` | Boolean | `true` | No | `true` staggers the enter rise and lifts on hover. `false` leaves the scatter still. `prefers-reduced-motion: reduce` skips both. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the collage container. |

## Slots
- `item` — arbitrary content. Optional `rotate` (degrees, or a CSS angle), `offset` (`[x, y]` lengths), and `z` (integer). Omit `rotate` and `offset` to use the index scatter. Pass one of them to pin that card.

## Variants

| variant | description |
|---------|-------------|
| `scatter: :subtle` | Default. Each item tilts within `--collage-rotate` and shifts within `--collage-offset-x` / `--collage-offset-y`. |
| `scatter: :loose` | Same pattern, multiplied by `--collage-loose` (default `2`). |
| `scatter: :none` | No tilt and no offset, unless an item passes `rotate` or `offset`. |
| `motion: false` | No enter stagger and no hover lift. The scatter stays. |

The tilt for an index is a deterministic mix in the range -1 to 1. The same index renders the same lean. Per-item `rotate` and `offset` replace that lean. `z` sets the paint order. The default is the index plus one, so a later card paints over an earlier one where they overlap.

## Example

```erb
<%= render FlatPack::Collage::Component.new(columns: 3, scatter: :subtle, stack_below: :md) do |collage| %>
  <% collage.item do %>
    <%= render FlatPack::Card::Component.new(shadow: :sm, padding: :none) do |card| %>
      <% card.media(aspect_ratio: "4/3", padding: :none) do %>
        <%= image_tag "/photos/harbour.jpg", alt: "Harbour at dusk", class: "h-full w-full object-cover" %>
      <% end %>
      <% card.body(padding: :sm) do %>
        <%= render FlatPack::Badge::Component.new(text: "Harbour", size: :xs) %>
      <% end %>
    <% end %>
  <% end %>
  <% collage.item(rotate: -4, offset: ["0.5rem", "-8px"], z: 4) do %>
    <%= render FlatPack::Card::Component.new(shadow: :sm) { "Pinned" } %>
  <% end %>
<% end %>
```

Square, and still:

```erb
<%= render FlatPack::Collage::Component.new(scatter: :none, motion: false, columns: 3) do |collage| %>
  <% collage.item { "Notes" } %>
<% end %>
```

## Accessibility
The grid does not change source order. What you tab and what a screen reader reads is the order of the `item` calls. Below `stack_below` the visual order matches that, with no tilt. Image `alt` belongs on the host image. Hover lift also runs for `:focus-within`, and it does not run under `prefers-reduced-motion: reduce` or `motion: false`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Entrance uses `.fp-content-enter`: opacity and a 4px rise on `--duration-slow` / `--easing-enter`. Stagger delay is `min(index, 8) * --collage-stagger` (default `40ms`). Hover lift uses the same duration and easing, by `--collage-lift`.
- `--collage-rotate`, `--collage-offset-x`, `--collage-offset-y`, `--collage-lift`, `--collage-stagger`, `--collage-loose`, `--collage-gap`, and `--collage-pad` are theme tokens. Offsets, lift, gap, and pad follow `--space-*` and `--density`.
- No Stimulus controller. No absolute positioning.
