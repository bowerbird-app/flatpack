# Cluster

## Purpose
Lay out inline content in a horizontal wrapping flex row with a shared gap, cross-axis alignment, and main-axis justification.

## When to use
Use Cluster when host markup would otherwise be `flex flex-wrap gap-2` — button rows, badges, and chips that should wrap. Use `Stack` for a vertical column. Use `OverflowRow` when a second row is unwanted. Use `Collection` `layout: :wrap` when the children are a list.

## Class
- Primary: `FlatPack::Cluster::Component`
- Related classes: `FlatPack::Stack::Component`, `FlatPack::OverflowRow::Component`, `FlatPack::Collection::Component`, `FlatPack::ChipGroup::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `gap` | Symbol | `:md` | No | Gap preset. Same scale as Grid. Allowed: `:sm`, `:md`, `:lg` (`gap-2`, `gap-4`, `gap-6`). |
| `align` | Symbol | `:center` | No | Cross-axis alignment. Same enum as Grid. Allowed: `:start`, `:center`, `:stretch`. Default `:center` matches a button or chip row. |
| `justify` | Symbol | `:start` | No | Main-axis justification. Allowed: `:start`, `:center`, `:end`, `:between`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the cluster container. |

## Slots
Default block content; each child participates as a wrapping flex item.

## Variants

| variant | description |
|---------|-------------|
| `gap: :sm/:md/:lg` | Applies `gap-2`, `gap-4`, or `gap-6`. |
| `align: :start/:center/:stretch` | Applies `items-start`, `items-center`, or `items-stretch`. |
| `justify: :start/:center/:end/:between` | Applies `justify-start`, `justify-center`, `justify-end`, or `justify-between`. |

## Example

```erb
<%= render FlatPack::Cluster::Component.new(gap: :sm) do %>
  <%= render FlatPack::Button::Component.new(text: "Save", style: :primary) %>
  <%= render FlatPack::Button::Component.new(text: "Cancel", style: :secondary) %>
<% end %>
```

## Accessibility
Cluster is structural layout only. Accessibility is determined by the semantics of content rendered inside.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Rebuild host Tailwind so `flex-wrap` and the gap, align, and justify classes are generated if the host did not already use them.
