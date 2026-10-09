# Masonry

## Purpose
Stack mixed-ratio items so each one keeps its natural shape and sits tight under the item above, with even gutters and no empty holes.

## When to use
Use Masonry for photo walls, media libraries, and mixed portrait/landscape tiles. Use `Grid` when items should share a row height. Do not change `Grid` to get this layout.

## Class
- Primary: `FlatPack::Masonry::Component`
- Related classes: `FlatPack::Masonry::Item`, `FlatPack::Masonry::Image`, `FlatPack::Grid::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `columns` | Integer or Hash | `{base: 2, md: 3, lg: 4}` | No | Column count. An integer (1–6) applies at every breakpoint. A hash accepts `base`, `sm`, `md`, `lg`, `xl`. |
| `gap` | Symbol | `:md` | No | Gutter preset, same scale as Grid. Allowed: `:sm` (`gap-2` / 0.5rem), `:md` (`gap-4` / 1rem), `:lg` (`gap-6` / 1.5rem). |
| `order` | Symbol | `:columns` | No | Packing direction. Allowed: `:columns`, `:rows`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the masonry container. |

## Slots
- `with_item` — arbitrary content. The slot wrapper is the masonry cell.
- `with_image` — convenience image cell. Required: `src`, `alt`, `width`, `height`. Optional: `href`, `caption`.
Default block content is also accepted: each direct child is a cell.

## Variants

| variant | description |
|---------|-------------|
| `order: :columns` | Pure CSS multi-column layout. No JavaScript. Eyes read down a column, then the next. |
| `order: :rows` | Left-to-right reading order. Uses native CSS masonry when the browser has it. Otherwise CSS columns first, then a Stimulus controller measures heights and sets grid-row spans. |

## Example

```erb
<%= render FlatPack::Masonry::Component.new(columns: {base: 2, md: 3, lg: 4}, gap: :md) do |masonry| %>
  <% masonry.with_image(src: "/photos/harbour.jpg", alt: "Harbour at dusk", width: 400, height: 600) %>
  <% masonry.with_image(src: "/photos/cliff.jpg", alt: "Sea cliff", width: 600, height: 400, href: "/photos/cliff", caption: "Sea cliff") %>
  <% masonry.with_item do %>
    <%= render FlatPack::Card::Component.new(style: :outlined) { "Notes from the jetty" } %>
  <% end %>
<% end %>
```

Rows order, left to right:

```erb
<%= render FlatPack::Masonry::Component.new(order: :rows, columns: 3) do |masonry| %>
  <% masonry.with_image(src: "/photos/studio.jpg", alt: "Studio window", width: 500, height: 500) %>
<% end %>
```

`width` and `height` set `aspect-ratio` on the image so the cell reserves space before the file loads. Images also ship `loading="lazy"` and `decoding="async"`.

## Accessibility
DOM order is reading order. In `order: :columns`, the visual stack goes down each column, so what you see may not match left-to-right reading. Prefer `order: :rows` when source order should match the visual row. Image `alt` is required (use `""` only when the image is decorative). Linked images get their name from `alt`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Tailwind must see the `columns-*`, `grid-cols-*`, and `gap-*` class literals in the component.
- `order: :rows` uses Stimulus controller `flat-pack--masonry` (`app/javascript/flat_pack/controllers/masonry_controller.js`). Without JavaScript it still packs with CSS columns (or native masonry where supported).
