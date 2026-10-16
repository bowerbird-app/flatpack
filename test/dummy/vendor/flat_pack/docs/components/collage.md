# Collage

## Purpose
Scatter any host content. `rows:` is a brick, such as five cards over four. Omit it for an even grid. Either way the items tilt a little, and they stack straight on a small screen.

## When to use
Use Collage when several pieces of host content should sit in a loose cluster. The kit owns the layout: the brick or the grid, the tilt, the corner overlap, the inset, the stack, and the motion. It does not style what goes in an item. Put a card, a note, or anything else in the slot. Use `Grid` when every cell should line up. Use `Masonry` when mixed ratios should pack without a shared row.

## Class
- Primary: `FlatPack::Collage::Component`
- Related classes: `FlatPack::Collage::Item`, `FlatPack::Card::Component`, `FlatPack::Grid::Component`, `FlatPack::EmptyState::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `columns` | Integer | `3` | No | Column count for the even grid, at and above `stack_below`. An integer from 1 to 6. Ignored when `rows` is set. Invalid values raise `ArgumentError`. |
| `rows` | Array | `nil` | No | Brick pattern. Each entry is how many items are in that row, then the list repeats. `[5, 4]` is five across and four centered underneath. Counts are 1–8, and the list is at most 6 rows. A shorter row sits between the cards above it. Invalid values raise `ArgumentError`. |
| `scatter` | Symbol | `:subtle` | No | Tilt and offset. Allowed: `:subtle`, `:loose`, `:none`. `:none` sits square. Invalid values raise `ArgumentError`. |
| `stack_below` | Symbol | `:md` | No | Below this breakpoint the items are one column and the tilt is off. Allowed: `:sm`, `:md`, `:lg`, `:xl`. Not List `stack_below`. Invalid values raise `ArgumentError`. |
| `motion` | Boolean | `true` | No | `true` staggers the enter rise and lifts on hover. `false` leaves the scatter still. `prefers-reduced-motion: reduce` skips both. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the collage container. |

## Slots
- `item` — arbitrary content. Optional `rotate` (degrees, or a CSS angle), `offset` (`[x, y]` lengths), and `z` (integer). Omit `rotate` and `offset` to use the index scatter. Pass one of them to pin that card.

## Variants

| variant | description |
|---------|-------------|
| `rows: [5, 4]` | Brick. Five on the first row, four centered on the next, then it repeats. The next row is pulled up by `--collage-overlap`. Slot proportion is `--collage-card-ratio`, swayed by `--collage-card-sway`. The frame inset is `--collage-margin`. |
| `scatter: :subtle` | Default. Each item tilts within `--collage-rotate` and shifts within `--collage-offset-x` / `--collage-offset-y`. |
| `scatter: :loose` | Same pattern, multiplied by `--collage-loose` (default `2`). |
| `scatter: :none` | No tilt and no offset, unless an item passes `rotate` or `offset`. |
| `motion: false` | No enter stagger and no hover lift. The scatter stays. |

The tilt for an index is a deterministic mix in the range -1 to 1. The same index renders the same lean. Per-item `rotate` and `offset` replace that lean. `z` sets the paint order. The default is the index plus one, so a later card paints over an earlier one where they overlap.

## Example

```erb
<%= render FlatPack::Collage::Component.new(rows: [5, 4], scatter: :subtle, stack_below: :md) do |collage| %>
  <% collage.item do %>
    <%= render FlatPack::Card::Component.new(shadow: :sm) do %>
      One
    <% end %>
  <% end %>
  <% collage.item(rotate: -4, offset: ["0.5rem", "-8px"], z: 4) do %>
    <%= render FlatPack::Card::Component.new(shadow: :sm) do %>
      Pinned
    <% end %>
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
- `--collage-rotate` (`5deg`), `--collage-offset-x`, `--collage-offset-y`, `--collage-lift`, `--collage-stagger`, `--collage-loose`, `--collage-gap`, `--collage-pad`, `--collage-bleed`, `--collage-margin`, `--collage-overlap`, `--collage-card-ratio`, and `--collage-card-sway` are theme tokens. Lengths follow `--space-*` and `--density`, except the ratio (`0.928`, about 260 by 280) and the sway (`0.1`).
- An even grid pads by `--collage-pad` plus one offset and one bleed per scatter unit. A brick uses `--collage-margin` (about 32px) and pulls the next row up by `--collage-overlap`. Below `stack_below` the overlap and the tilt drop, and the padding is `--collage-pad`.
- No Stimulus controller. No absolute positioning.
