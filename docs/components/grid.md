# Grid

## Purpose
Lay out block content in responsive CSS grid columns with configurable gaps and alignment.

## When to use
Use Grid for card collections, dashboards, and responsive sections that need predictable spacing and column behavior.

## Class
- Primary: `FlatPack::Grid::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `cols` | Symbol or Integer | `:auto` | No | Column preset. Allowed: `:auto`, `1`, `2`, `3`, `4`, `6`, `12`. |
| `gap` | Symbol | `:md` | No | Gap preset. Allowed: `:sm`, `:md`, `:lg`. |
| `align` | Symbol | `:stretch` | No | Item alignment preset. Allowed: `:start`, `:center`, `:stretch`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into grid container. |

## Slots
Default block content; each child element participates as a grid item.

## Variants

| variant | description |
|---------|-------------|
| `cols: :auto` | Responsive preset `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`. |
| `cols: 2/3/4/6/12` | Fixed preset mappings defined in component constants. |
| `gap: :sm/:md/:lg` | Applies `gap-2`, `gap-4`, or `gap-6`. |
| `align: :start/:center/:stretch` | Applies `items-start`, `items-center`, or `items-stretch`. |

## Example

```erb
<%= render FlatPack::Grid::Component.new(cols: 3, gap: :md, align: :stretch) do %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 1" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 2" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 3" } %>
<% end %>
```

Optional drag-reorder pattern in demos can be composed with Stimulus `flat-pack--grid-sortable` by wrapping grid items with `data-flat-pack--grid-sortable-target="item"` and `data-id`.

## Accessibility
Grid is structural layout only. Accessibility is determined by the semantics of content rendered inside each grid item.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional drag-reorder integration uses Stimulus controller `flat-pack--grid-sortable`.
