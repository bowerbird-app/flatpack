# Sidebar Component

## Purpose
Provide a composable sidebar container with optional header, items area, and footer regions.

## When to use
Use Sidebar in application shells that need persistent navigation and grouped links.

## Class
- Primary: `FlatPack::Sidebar::Component`
- Related classes: `FlatPack::Sidebar::Item::Component`, `FlatPack::Sidebar::Header::Component`, `FlatPack::Sidebar::Footer::Component`, `FlatPack::Sidebar::Divider::Component`, `FlatPack::Sidebar::Group::Component`, `FlatPack::Sidebar::Badge::Component`, `FlatPack::Sidebar::CollapseToggle::Component`

## Props

Primary component (`FlatPack::Sidebar::Component`):

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `collapsed` | Boolean | `false` | No | Sidebar collapsed state flag (used by composition patterns; parent layout/controller decides behavior). |
| `collapsible` | Boolean | `true` | No | Signals whether collapse controls should be shown by composed header/toggle components. |
| `side` | Symbol | `:left` | No | Border side for the shell. Allowed: `:left`, `:right`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<aside>` wrapper. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `header` | block slot | No | Top area for brand, title, and controls. |
| `items` | block slot | No | Scrollable middle area for nav items and groups. |
| `footer` | block slot | No | Bottom area for profile/actions/meta content. |

## Variants

| variant | description |
|---------|-------------|
| `side: :left` | Renders right border (`border-r`). |
| `side: :right` | Renders left border (`border-l`). |

## Example

```erb
<%= render FlatPack::Sidebar::Component.new(side: :left) do |sidebar| %>
  <% sidebar.header do %>
    <%= render FlatPack::Sidebar::Header::Component.new(
      brand_abbr: "AC",
      title: "Acme"
    ) %>
  <% end %>

  <% sidebar.items do %>
    <nav class="py-4 space-y-1">
      <%= render FlatPack::Sidebar::Item::Component.new(
        label: "Dashboard",
        href: "/dashboard",
        icon: :home,
        active: true
      ) %>
    </nav>
  <% end %>

  <% sidebar.footer do %>
    <%= render FlatPack::Sidebar::Footer::Component.new do %>
      Signed in as you@example.com
    <% end %>
  <% end %>
<% end %>
```

## Accessibility
`FlatPack::Sidebar::Item::Component` sets `aria-current="page"` for active links and sets `aria-label` when rendered in collapsed mode.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `FlatPack::Sidebar::Group::Component` interactive expand/collapse requires Stimulus controller `flat-pack--sidebar-group`.
- `FlatPack::Sidebar::Item::Component` collapsed tooltip behavior requires Stimulus controller `flat-pack--tooltip`.
