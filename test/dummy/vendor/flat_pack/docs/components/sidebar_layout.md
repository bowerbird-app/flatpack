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
| `floating` | Boolean | `false` | No | Desktop-only detached rail. Insets the top, bottom, and outer edge. Rounded corners follow the rounded palette (no `data-theme`, or `data-theme="rounded"`). Ignored below the `md` breakpoint. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into root container. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `sidebar` | block slot | No | Sidebar column content (typically `FlatPack::Sidebar::Component`). |
| `top_nav` | block slot | No | Optional top-nav area above main content. |
| `main` | block slot | No | Main content area. If omitted, component block content is used. |
| `background` | block slot | No | Decorative page photo (`img` or `picture`) behind the shell. Omit it and the shell matches a layout with no photo. |

## Variants

| variant | description |
|---------|-------------|
| `side: :left` | Grid columns render as `auto 1fr`; sidebar enters from left on mobile. |
| `side: :right` | Grid columns render as `1fr auto`; sidebar enters from right on mobile. |
| `storage_key: "..."` | Enables persisted desktop collapse state in localStorage. |
| `floating: true` | Desktop rail sits inset from the top, bottom, and outer edge, with its own fill, border, and shadow. The rounded palette rounds the panel with `--sidebar-float-radius`. Other named themes stay square. Below `md` the drawer stays full height and square. |
| `background` slot | Full-viewport photo behind the rail, the top nav, and main. Blur and tint come from `--layout-background-*`. |

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

The background layer is decorative. The layout marks it `aria-hidden="true"`. Pass `alt=""` on the image. Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is unavailable, the photo is hidden and the tint becomes solid so text stays on the page colour.

## Collapsed (icon-only) mode

Desktop collapse is one motion: the rail width eases `16rem` → `4rem` on `--duration-slow` / `--easing-standard` while labels fade on `--duration-fast` and shrink to zero width on `--duration-slow`. The icon's leading margin eases on that same curve, by a fixed length, so the closed active pill has the same space on both sides of the icon. Padding and gap ease with the width. The header collapse control keeps its own padding, so the hover fill wraps the chevron. Nothing restyles the row when the width transition ends, so the close does not shudder.

The closed look is the hamburger (`aria-label="Open sidebar"`), hidden brand mark, centered icons, and a 4rem rail. Expanding restores the brand and hamburger first, then eases the rail open. `prefers-reduced-motion: reduce` snaps to the end state (duration tokens are `0ms`).

This is applied to:
- Every element with `data-flat-pack-sidebar-item="true"` (`Sidebar::Item::Component` links and `Sidebar::Group::Component` header buttons).
- Item, group, and header `.fp-sidebar-label` text shrinks with the rail. Section titles fade and keep their block height so item/icon row height does not jump.
- Every element with `data-flat-pack-sidebar-section-title="true"`, and each icon row — a tooltip shows the full label on hover while `data-flat-pack-sidebar-collapsed` is `true`. The tip does not wait for an `sr-only` label.

For static/non-interactive collapsed demos (without the layout controller) pass `collapsed: true` to `Sidebar::Item::Component` and `Sidebar::SectionTitle::Component` to render compact icon-only markup server-side.

## Floating

`floating: true` detaches the desktop rail from the viewport edges. The column keeps the same width transition (`16rem` / `4rem`) and adds `--sidebar-float-inset` (`1rem`) on the top, bottom, and outer edge (`margin-left` when `side: :left`, `margin-right` when `side: :right`). The panel fill is `--sidebar-float-background-color` (`#fff` on the default palette, a lifted surface on dark), with a full border and `--sidebar-float-shadow`. Header fill follows that panel.

Round corners are `--sidebar-float-radius` (`--radius-lg`). They apply on the rounded palette: no `data-theme`, or `data-theme="rounded"`. Any other `data-theme` (dark, ocean, a host theme) keeps square corners. Below the `md` breakpoint the attribute is present and unused: the drawer stays edge-to-edge, including its safe-area padding.

Dummy chrome accepts `?floating=1` (or `true`) on any page. Omit it for the flush rail.

## Background

`layout.background` paints a decorative photo behind the whole shell, including the gaps around a floating rail and the flush main column. The host supplies an `<img>` or `<picture>` (responsive `srcset`, `loading: "lazy"`). The layout fixes that layer to the viewport, blurs it with `--layout-background-blur` (`40px`), and lays `--layout-background-tint-color` over it at `--layout-background-tint-opacity` (`0.55`, `0.78` on dark). The tint colour aliases `--surface-page-background-color`, so a host recolours it by setting the token. Do not point it at `--hero-overlay-*` or `--overlay-backdrop-color`.

While the slot is set, the main column sets `--surface-page-background-color` to `transparent`, so a host page fill that uses that token shows the photo. The rail keeps its own fill. The mobile drawer and its dim are unchanged, and the photo stays behind them. Omit the slot and the markup matches a layout with no photo.

```erb
<% layout.background do %>
  <%= image_tag "/images/hero-packaging.jpg", alt: "", loading: "lazy" %>
<% end %>
```

Dummy chrome accepts `?background=1` (or `true`) on any page. `/demo/sidebar_layout?floating=1&background=1` is the floating photo. `?background=1` alone keeps the flush rail.

## Current item
Clicking a sidebar link marks it current immediately (`aria-current="page"` plus the item active colour tokens) and clears the previous item. Modifier-clicks and `_blank` targets are left alone. Hosts that paint `active:` on the server still win after the next render. Dummy chrome also clears-then-sets on `turbo:load` so command-palette visits and a remounted cached shell stay in sync.

## Scroll
The rail keeps its place. Turbo visits restore the last `scrollTop` (and the clicked item's offset) from `sessionStorage` after sidebar groups have applied their open state, so a long menu does not snap to the top when those groups expand. Refresh does the same on connect. The current item is not pinned to the top. If it is fully in view, the list does not move. If it is clipped or off-screen, the controller nudges just enough to show it. Dummy chrome keeps the rail DOM with `id="dummy-demo-sidebar"` and `data-turbo-permanent`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Responsive drawer/collapse interactions require Stimulus controller `flat-pack--sidebar-layout`.
