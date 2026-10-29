# Grid

## Purpose
Lay out block content in responsive CSS grid columns with configurable gaps and alignment.

## When to use
Use Grid for card collections, dashboards, and responsive sections that need predictable spacing and a shared row height. Use `Masonry` when portraits and landscapes should keep their own shape and stack without empty holes.

## Class
- Primary: `FlatPack::Grid::Component`
- Related classes: `FlatPack::Grid::Item`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `cols` | Symbol or Integer | `:auto` | No | Column preset. Allowed: `:auto`, `1`, `2`, `3`, `4`, `6`, `12`. `4` is `grid-cols-1 md:grid-cols-2 lg:grid-cols-4`. |
| `gap` | Symbol | `:md` | No | Gap preset. Allowed: `:sm`, `:md`, `:lg`. |
| `align` | Symbol | `:stretch` | No | Item alignment preset. Allowed: `:start`, `:center`, `:stretch`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into grid container. |

`with_item` / `FlatPack::Grid::Item` props:

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `span` | Integer, `:full`, or Hash | omit | No | How many columns this cell covers. An integer `1`–`12` applies from `sm` up (`sm:col-span-2` and the wider prefixes). It does not set `base`. Pass `base:` to span on a phone. `:full` is `col-span-full`, including at `base`. A hash accepts `base`, `sm`, `md`, `lg`, `xl`. Omit `span:` and the cell is one track wide. A host `col-span-*` class on the item wins over `span:`. |

## Slots
- `with_item` — optional. The slot wrapper is the grid cell and has the class `fp-grid__item`. Pass `span:` to cover more than one column.
Default block content is also accepted: each direct child is a grid item and is not wrapped. You can render `FlatPack::Grid::Item` inside that block. Existing grids that pass children with no `with_item` keep the same markup.

## Variants

| variant | description |
|---------|-------------|
| `cols: :auto` | Responsive preset `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`. |
| `cols: 2/3/6/12` | Fixed preset mappings defined in component constants. |
| `cols: 4` | `grid-cols-1 md:grid-cols-2 lg:grid-cols-4`. One column below `md`. |
| `gap: :sm/:md/:lg` | Applies `gap-2`, `gap-4`, or `gap-6`. |
| `align: :start/:center/:stretch` | Applies `items-start`, `items-center`, or `items-stretch`. |
| `span: 2` | `sm:col-span-2 md:col-span-2 lg:col-span-2 xl:col-span-2`. No base class. |
| `span: {base: 2}` | `col-span-2` on phones as well. |
| `span: {base: 1, md: 2, lg: 8}` | Item classes `col-span-1 md:col-span-2 lg:col-span-8`. |

A span wider than the explicit columns at that breakpoint adds an implicit track sized `auto` (the cell's minimum content, not `1fr`). Later cells flow into that track, so the columns are unequal. `span: :full` is `grid-column: 1 / -1`. Those lines count only the explicit tracks, so the full cell does not cover the implicit one. To span 2 on a phone, pass `base: 2`, and only when the preset already has two base columns (`cols: 6` and `cols: 12` are `grid-cols-2` at base). A non-integer such as `2.5` raises `ArgumentError`.

## Example

```erb
<%= render FlatPack::Grid::Component.new(cols: 3, gap: :md, align: :stretch) do %>
  <%= render FlatPack::Card::Component.new(border: :strong) { "Item 1" } %>
  <%= render FlatPack::Card::Component.new(border: :strong) { "Item 2" } %>
  <%= render FlatPack::Card::Component.new(border: :strong) { "Item 3" } %>
<% end %>
```

One cell spanning two columns, then two ordinary cells:

```erb
<%= render FlatPack::Grid::Component.new(cols: 4) do |grid| %>
  <% grid.with_item(span: {base: 1, md: 2, lg: 2}) do %>
    <%= render FlatPack::Card::Component.new(border: :strong) { "Wide" } %>
  <% end %>
  <% grid.with_item do %>
    <%= render FlatPack::Card::Component.new(border: :strong) { "Item 2" } %>
  <% end %>
  <% grid.with_item do %>
    <%= render FlatPack::Card::Component.new(border: :strong) { "Item 3" } %>
  <% end %>
<% end %>
```

Optional drag-reorder pattern in demos can be composed with Stimulus `flat-pack--grid-sortable` by wrapping grid items with `data-flat-pack--grid-sortable-target="item"` and `data-id`. An item added after the controller connects is draggable too.

## Accessibility
Grid is structural layout only. Accessibility is determined by the semantics of content rendered inside each grid item.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Tailwind must see the `col-span-*` class literals on `FlatPack::Grid::Item`.
- Optional drag-reorder integration uses Stimulus controller `flat-pack--grid-sortable`.
