# Grid Component

## Purpose
Lay out content in responsive grid columns with configurable gaps, and support interactive card layouts.

## When to use
Use Grid for card collections, dashboards, catalog layouts, and responsive sections that need consistent spacing.

## Class
- Primary: `FlatPack::Grid::Component`

## Props
See the `Props` table below.

## Slots
Pass content via block; each child becomes a grid item.

## Variants
- Auto-responsive layout
- Fixed column count (`cols`)
- Gap sizes (`:sm`, `:md`, `:lg`)
- Movable cards demo (drag reorder)

## Example
Start with `Basic Usage`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`)
- Optional Stimulus controller for drag-and-drop cards (`flat-pack--grid-sortable`)

## Basic Usage

```erb
<%= render FlatPack::Grid::Component.new do %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 1" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 2" } %>
  <%= render FlatPack::Card::Component.new(style: :outlined) { "Item 3" } %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `cols` | Integer | `3` | Grid columns on larger breakpoints |
| `gap` | Symbol | `:md` | Grid gap size (`:sm`, `:md`, `:lg`) |
| `class` | String | `nil` | Additional CSS classes |
| `**system_arguments` | Hash | `{}` | HTML attributes (`id`, `data`, `aria`, etc.) |

## Movable Cards Demo Pattern

Use the grid sortable Stimulus controller with card wrappers as draggable targets:

```erb
<div
  data-controller="flat-pack--grid-sortable"
  data-flat-pack--grid-sortable-reorder-url-value="<%= demo_tables_reorder_path %>"
  data-flat-pack--grid-sortable-scope-value="<%= { list_key: 'grid-movable-cards-demo' }.to_json %>">
  <%= render FlatPack::Grid::Component.new(cols: 3) do %>
    <% @cards.each do |card| %>
      <div data-flat-pack--grid-sortable-target="item" data-id="<%= card.id %>">
        <%= render FlatPack::Card::Component.new(style: :outlined) do |component| %>
          <% component.body { card.name } %>
        <% end %>
      </div>
    <% end %>
  <% end %>
</div>
```

The controller emits `grid:reordered` and sends the same `reorder` payload contract used by table dragging (`resource`, `strategy`, `scope`, `version`, `items`).

## Related Demo Pages

- `/demo/grid`
- `/demo/grid/movable_cards`
