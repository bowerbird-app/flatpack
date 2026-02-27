# TopNav Component

## Purpose
Render a sticky top navigation bar with composable left, center, and right content regions.

## When to use
Use TopNav in app shells for page context, global actions, and optional search or controls.

## Class
- Primary: `FlatPack::TopNav::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<header>` element (`class`, `id`, `data`, `aria`, `style`). |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `left` | block slot | No | Left-aligned content wrapper (`h-full flex items-center gap-2`). |
| `center` | block slot | No | Center wrapper (`h-full flex-1 flex items-center justify-center`). |
| `right` | block slot | No | Right-aligned content wrapper (`h-full flex items-center gap-2`). |

## Variants
None.

## Example

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      placeholder: "Search..."
    ) %>
  <% end %>

  <% nav.right do %>
    <button type="button" class="p-2 rounded-lg">Alerts</button>
  <% end %>
<% end %>
```

## Accessibility
TopNav itself is structural (`<header>`). Accessibility depends on controls rendered inside slots (buttons/links/search inputs) and their labels.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional companion components commonly used inside slots: `FlatPack::Search::Component`, `FlatPack::SidebarLayout::Component`.
