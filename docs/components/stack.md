# Stack

## Purpose
Lay out block content in a vertical flex column with a shared gap and cross-axis alignment.

## When to use
Use Stack when host markup would otherwise be `flex flex-col gap-4` — forms, page bodies, and stacked cards. Use `Cluster` for a wrapping horizontal row. Use `Collection` when the children are a list (`ul` / `li`). Use `Grid` when you need columns.

## Class
- Primary: `FlatPack::Stack::Component`
- Related classes: `FlatPack::Cluster::Component`, `FlatPack::Grid::Component`, `FlatPack::Collection::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `gap` | Symbol | `:md` | No | Gap preset shared with Grid and Cluster. `:sm`, `:md`, `:lg` map to `gap-[var(--stack-gap-sm)]`, `gap-[var(--stack-gap-md)]`, and `gap-[var(--stack-gap-lg)]`. |
| `align` | Symbol | `:stretch` | No | Cross-axis alignment. Same enum as Grid. Allowed: `:start`, `:center`, `:stretch`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the stack container. |

## Slots
Default block content; each child participates as a flex item.

## Variants

| variant | description |
|---------|-------------|
| `gap: :sm/:md/:lg` | Applies `gap-[var(--stack-gap-sm)]`, `gap-[var(--stack-gap-md)]`, or `gap-[var(--stack-gap-lg)]`. |
| `align: :start/:center/:stretch` | Applies `items-start`, `items-center`, or `items-stretch`. |

## Example

```erb
<%= render FlatPack::Stack::Component.new(gap: :md, align: :start) do %>
  <%= render FlatPack::PageTitle::Component.new(title: "Lists") %>
  <%= render FlatPack::Button::Component.new(text: "New list", href: "/lists/new", style: :primary) %>
<% end %>
```

## Accessibility
Stack is structural layout only. Accessibility is determined by the semantics of content rendered inside.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Rebuild host Tailwind so `flex-col` and the gap/align classes are generated if the host did not already use them.
