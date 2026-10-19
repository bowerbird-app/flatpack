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
| `floating_top_nav` | Boolean | `false` | No | Replaces the full-width top bar with floating cards. Uses the same `--sidebar-float-*` gap, fill, shadow, and corner as the rail. `false` leaves the bar unchanged. |
| `content_scroll` | Symbol | `:behind` | No | Where main content sits when `floating_top_nav: true`. `:behind` scrolls the page under the cards and pads the scroll pane with `--top-nav-float-clearance`. `:below` keeps the cards above the scroll pane. Ignored when the top nav is not floating. |
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
| `floating_top_nav: true` | The full-width bar is gone. `TopNav` `left` and `center` each become one card sized to their contents. `right` lays its children out as separate cards. Content scrolls under the cards. |
| `content_scroll: :below` | Same cards, in flow above the scroll pane. Content does not slide under them. |
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

Float the top nav on its own, or with the rail. Put a toolbar in `left` and separate actions in `right`. `TopNav` still owns the `<header>` landmark and the mobile menu.

```erb
<%= render FlatPack::SidebarLayout::Component.new(floating: true, floating_top_nav: true) do |layout| %>
  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <% nav.left do %>
        <%= render FlatPack::Button::Component.new(text: "Preview", style: :ghost, size: :sm) %>
        <%= render FlatPack::Button::Component.new(text: "Publish", style: :primary, size: :sm) %>
      <% end %>
      <% nav.right(always_display: true) do %>
        <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, style: :ghost, aria: {label: "Notifications"}) %>
      <% end %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <div class="p-6">Main content</div>
  <% end %>
<% end %>
```

`content_scroll: :below` keeps those cards above the scroll pane. Omit `floating_top_nav` and the bar is the full-width `TopNav` from the first example.

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

## Floating top nav

`floating_top_nav: true` takes the full-width bar out of the main column and paints cards on the page, including over a `background` photo. The cards share the rail's float tokens: `--sidebar-float-inset`, `--sidebar-float-background-color`, `--sidebar-float-shadow`, and `--sidebar-float-radius`. A second token set would drift from the rail, and renaming `--sidebar-float-*` would break hosts that already set it. One new token, `--top-nav-float-clearance`, is the space the scroll pane keeps clear above the first content. It defaults to the inset (or the top safe area, whichever is larger) plus `3.25rem`.

`TopNav` `left` and `center` are each one card, sized to their contents. An empty section is hidden, so a host that only fills `left` and `right` does not get a blank center card. `right` is not one card. Each direct child is its own card, so a bell stays separate from the toolbar. There is no new slot. The existing `top_nav` slot and `TopNav`'s `left`, `center`, and `right` are the API.

Corners follow the rail. `--sidebar-float-radius` applies when there is no `data-theme`, or `data-theme="rounded"`. Any other `data-theme` keeps square corners.

The cards apply at every width, including `390px`. The row wraps, and the left card can shrink. `TopNav`'s mobile menu still collapses `center` and `right` below `mobile_breakpoint` unless the slot passes `always_display: true`. Pass that on `right` when the bell should stay on screen. The mobile drawer is unchanged: it stays edge-to-edge, uses the backdrop, and paints above the cards (`z-50` over `z-20`).

The wrapper does not cover clicks in the gaps between cards. The `<header>` landmark stays. Tab order is still the top nav, then main.

Dummy chrome accepts `?floating_top_nav=1`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1` is the floating photo with the cards. Add `content_scroll=below` to park the cards above the scroll pane.

## Where content scrolls

The shell stays `h-screen overflow-hidden`. Only the main pane scrolls, so the rail and the top nav stay put. That is the default, and hosts that do not opt in keep it.

With `floating_top_nav: true`, `content_scroll: :behind` (the default) lets that pane run under the cards. The pane's `padding-top` and `scroll-padding-top` use `--top-nav-float-clearance`, so the first paint and a focused control are not hidden under the cards. `content_scroll: :below` puts the cards back in the flow, above the pane, still with the float gap and the card chrome.

`content_scroll` does nothing while `floating_top_nav` is false. The full-width bar stays outside the pane.

A whole-page scroll mode is not part of this layout. The scroll pane is still one element (`.fp-layout-scroll` when content runs behind the cards). A later option can move `overflow` to the shell without a new chrome component. The corner slot, a content-height rail, and an account item are also out of scope.

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
