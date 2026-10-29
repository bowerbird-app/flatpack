# Collection

## Purpose
Lay out a list of items in a grid, a wrapping row, or a vertical stack, without painting them.

## When to use
Use Collection when the items are already FlatPack components — a press-kit menu of buttons, or a wrap of badges and chips. Use `Stack` or `Cluster` for block or inline content that is not a list. Use `Grid` for block content in columns. Use `List` for rows with icons, keys, or selection.

## Class
- Primary: `FlatPack::Collection::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `as` | Symbol | `:list` | no | `:list` renders the `<ul>` alone. `:nav` wraps it in `<nav aria-label="…">` and requires `label:`. |
| `label` | String, nil | `nil` | with `as: :nav` | Accessible name for the nav. Required when `as` is `:nav`. Not allowed otherwise. |
| `layout` | Symbol | `:stack` | no | `:grid` (auto-fill, items stretch to equal height), `:wrap` (inline flex-wrap), or `:stack` (vertical). |
| `gap` | Symbol | `:md` | no | `:sm`, `:md`, or `:lg`, emitted as `gap-2`, `gap-4`, and `gap-6`. Grid, Stack, and Cluster use `--stack-gap-*` instead. |
| `min_item_width` | String | `"14rem"` | no | CSS length for `:grid` only. Sets `--fp-collection-min-item-width`. The column class stays the literal `grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer element (`nav` when `as: :nav`, otherwise the `ul`). No colour prop and no item class. |

## Slots
| name | description |
| --- | --- |
| `items` | One `<li>` per `with_item`. The block is the item. Repeat it. |

## Variants
- `layout: :grid` — auto-fill grid. Items stretch to the same height. Default floor is `14rem`.
- `layout: :wrap` — one wrapping row for badges and chips.
- `layout: :stack` — one item under the next.
- `as: :nav` — the list sits in a named `<nav>`.

## Example
```erb
<%= render FlatPack::Collection::Component.new(
  as: :nav,
  label: "Press kit",
  layout: :grid
) do |collection| %>
  <% collection.with_item do %>
    <%= render FlatPack::Button::Component.new(
      text: "Logos and lockups for print, screen, and social",
      title: "Logos and lockups for print, screen, and social",
      href: "/press/logos",
      icon: "swatch",
      align: :start,
      lines: 2,
      current: true
    ) do |button| %>
      <% button.with_trailing do %>
        <%= render FlatPack::Badge::Component.new(text: "12", size: :sm) %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

Badges and chips use `:wrap`.

```erb
<%= render FlatPack::Collection::Component.new(layout: :wrap, gap: :sm) do |collection| %>
  <% collection.with_item do %>
    <%= render FlatPack::Badge::Component.new(text: "Print", size: :sm) %>
  <% end %>
  <% collection.with_item do %>
    <%= render FlatPack::Chip::Component.new(text: "Northlight") %>
  <% end %>
<% end %>
```

## Accessibility
`as: :nav` renders `<nav aria-label="…">` around the list. `label:` is required and is the accessible name, not a visible heading. Each `with_item` is an `<li>`. A current page link is the button's job: `current: true` sets `aria-current="page"` on the link. Leading icons stay `aria-hidden`.

## Dependencies
- Hosts compose `FlatPack::Button::Component`, `FlatPack::Badge::Component`, and `FlatPack::Chip::Component`. Collection does not style them.
- Rebuild host Tailwind so the grid class `grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]` and the item classes `[&>*]:w-full`, `[&>*]:flex-1`, `[&>*]:min-w-0`, and `[&>*]:self-stretch` are generated.
