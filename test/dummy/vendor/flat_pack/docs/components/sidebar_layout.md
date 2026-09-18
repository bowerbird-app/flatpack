# Sidebar Layout

## Purpose
Compose sidebar, top navigation, and main content into a full-height application shell.

## When to use
Use Sidebar Layout as the application chrome: persistent sidebar, optional top bar, and main content. Dummy and `bin/rails generate flat_pack:layout` use this family. There is no second Navbar shell.

## Class
- Primary: `FlatPack::SidebarLayout::Component`
- Compose with: `FlatPack::Sidebar::Component`, `FlatPack::TopNav::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `side` | Symbol | `:left` | No | Sidebar side. Allowed: `:left`, `:right`. |
| `open` | Boolean | `true` | No | Initial desktop sidebar state (expanded when true, collapsed when false). |
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
        <%= render FlatPack::Sidebar::Item::Component.new(text: "Dashboard", href: "/", icon: :home, active: true) %>
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

`FlatPack::Navbar::Component` (and `Navbar::Sidebar`, `Navbar::TopNav`) is removed. Hosts that still render it should switch to the composition above. Stimulus is `flat-pack--sidebar-layout` plus `flat-pack--sidebar` / `flat-pack--top-nav` as needed. Dummy `/demo/navbar` remains the Top Nav slot demo.

The mobile drawer (below the `md` breakpoint) is `.fp-sidebar-drawer` with `data-mobile-drawer-side`. It pads `env(safe-area-inset-*)` on the top, bottom, and opening edge so the panel clears the notch. Desktop sidebar is in the grid and does not add that pad. TopNav lives in the main column, so drawer padding does not double-pad the bar. Hosts need `viewport-fit=cover` for insets to apply. See [Installation](../installation.md).

## Accessibility
Mobile drawer backdrop uses `aria-hidden` and supports Escape to close via controller behavior. Focus is moved to sidebar on open and returned to the previous control on close. Backdrop fill is `--drawer-backdrop-color` (aliases `--modal-backdrop-color`).

## Collapsed (icon-only) mode

Desktop collapse is one motion: the rail width eases `16rem` → `4rem` on `--duration-slow` / `--easing-standard` while labels fade on `--duration-fast`. Item padding eases to `px-1` with the width so the active pill shrinks with the rail. Labels stay in layout during the motion and are clipped on the item (`overflow-x: clip`), not on the rail (that extra `overflow-x: hidden` put a scrollbar on the column).

The closed rest state is unchanged from before this motion work: hamburger (`aria-label="Open sidebar"`), brand mark hidden, icons compact-centered, 4rem rail. The controller waits until the width transition ends before `sr-only` and `justify-center`. Expanding restores that chrome first, then eases the rail open. `prefers-reduced-motion: reduce` snaps to the end state (duration tokens are `0ms`).

This is applied to:
- Every element with `data-flat-pack-sidebar-item="true"` (`Sidebar::Item::Component` links and `Sidebar::Group::Component` header buttons).
- Every `.fp-sidebar-label` (item text, group titles, header title, section titles).
- Every element with `data-flat-pack-sidebar-section-title="true"` — a tooltip shows the full label on hover once the rail is at rest.

For static/non-interactive collapsed demos (without the layout controller) pass `collapsed: true` to `Sidebar::Item::Component` and `Sidebar::SectionTitle::Component` to render compact icon-only markup server-side.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Responsive drawer/collapse interactions require Stimulus controller `flat-pack--sidebar-layout`.
