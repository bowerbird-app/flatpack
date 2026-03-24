# Sidebar Layout

## Purpose
Compose sidebar, top navigation, and main content into a full-height application shell.

## When to use
Use Sidebar Layout for pages that need persistent sidebar navigation with responsive desktop/mobile behavior.

## Class
- Primary: `FlatPack::SidebarLayout::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `side` | Symbol | `:left` | No | Sidebar side. Allowed: `:left`, `:right`. |
| `default_open` | Boolean | `true` | No | Initial desktop sidebar state (expanded when true, collapsed when false). |
| `storage_key` | String or nil | `nil` | No | localStorage key used by controller for desktop collapsed-state persistence. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into root container. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `sidebar` | block slot | No | Sidebar column content (typically `FlatPack::Sidebar::Component`). |
| `top_nav` | block slot | No | Optional top-nav area above main content. |
| `main` | block slot | No | Main content area. If omitted, component block content is used. |

## Variants

| variant | description |
|---------|-------------|
| `side: :left` | Grid columns render as `auto 1fr`; sidebar enters from left on mobile. |
| `side: :right` | Grid columns render as `1fr auto`; sidebar enters from right on mobile. |
| `storage_key: "..."` | Enables persisted desktop collapse state in localStorage. |

## Example

```erb
<%= render FlatPack::SidebarLayout::Component.new(side: :left, storage_key: "demo-sidebar") do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <% sidebar.items do %>
        <%= render FlatPack::Sidebar::Item::Component.new(label: "Dashboard", href: "/", icon: :home, active: true) %>
      <% end %>
    <% end %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <% nav.left { "Dashboard" } %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <div class="p-6">Main content</div>
  <% end %>
<% end %>
```

## Accessibility
Mobile drawer backdrop uses `aria-hidden` and supports Escape to close via controller behavior. Focus is moved to sidebar on open and returned to the previous control on close.

## Collapsed (icon-only) mode

When the sidebar is collapsed the `flat-pack--sidebar-layout` controller applies compact, centered styles to all sidebar items and group buttons:

- `px-4` → `px-1` (reduces horizontal padding to `0.25rem`)
- `justify-center` added (centers the icon within the row)
- Labels and group chevrons are visually hidden (`sr-only` / `hidden`)

This is applied to every element with `data-flat-pack-sidebar-item="true"`, which includes both `Sidebar::Item::Component` links and `Sidebar::Group::Component` header buttons.

For static/non-interactive collapsed demos (without the layout controller) pass `collapsed: true` to `Sidebar::Item::Component` to render the same compact styles server-side.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Responsive drawer/collapse interactions require Stimulus controller `flat-pack--sidebar-layout`.
