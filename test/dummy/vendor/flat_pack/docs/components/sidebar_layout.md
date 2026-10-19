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
| `height` | Symbol | `:full` | No | Height of the floating desktop rail. `:full` is today's rail (viewport minus the float insets). `:content` sizes the rail to its items and caps it at that same viewport height. The items scroll inside the cap. Ignored when `floating` is false. The mobile drawer stays full height. Not the image `height` attribute. |
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
| `height: :content` | Floating desktop rail shrinks to its items and sits at the top inset. A rail taller than the viewport stops at the float cap and scrolls inside. |
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
        <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, round: true, style: :ghost, aria: {label: "Notifications"}) %>
      <% end %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <div class="p-6">Main content</div>
  <% end %>
<% end %>
```

`content_scroll: :below` keeps those cards above the scroll pane. Omit `floating_top_nav` and the bar is the full-width `TopNav` from the first example.

`height: :content` with `floating: true` shortens the desktop rail to its items:

```erb
<%= render FlatPack::SidebarLayout::Component.new(floating: true, height: :content) do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <% sidebar.items do %>
        <%= render FlatPack::Sidebar::Item::Component.new(text: "Featured in", href: "/", icon: :home, active: true) %>
      <% end %>
    <% end %>
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

## Rail height

`height: :full` (the default) keeps the floating desktop rail at `calc(100vh - (var(--sidebar-float-inset) * 2))`. `height: :content` sizes that rail to its items and keeps the same cap as a max-height, so a long list scrolls inside the card. The two heights are separate rules. Content height does not override the full-height declaration.

`height: :content` does nothing when `floating` is false. The flush column stays `md:h-screen`. Below `md`, the drawer stays full height either way. The content-height rules live in the same `min-width: 768px` block as the rest of the floating rail.

A bottom-left avatar card is not part of this layout. Content height leaves the space under the rail empty: the column stays `md:self-start` and only as tall as its items, or the viewport cap. A later corner slot can pin a second card to the same outer inset and the bottom inset without stretching the rail. Keep that card out of the sidebar footer. The footer sits inside the rail and scrolls away once the list hits the cap.

Dummy chrome accepts `?height=content`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1&height=content` is the short rail with the floating cards. `?height=content` without `?floating=1` stays the flush full-height rail.

## Floating top nav

`floating_top_nav: true` takes the full-width bar out of the main column and paints cards on the page, including over a `background` photo. The cards share the rail's fill and shadow: `--sidebar-float-background-color` and `--sidebar-float-shadow`. The vertical gap stays `--sidebar-float-inset`. The horizontal edge is `--layout-content-inset`, the same token as the page padding, plus `--top-nav-float-offset` (`0px`). Put `.fp-layout-content` on the main pane. Its `padding-inline` is `--layout-content-inset`, so the bar's left and right edges meet the content. Override that one token to move both. `--top-nav-float-offset` is the extra horizontal gap when the bar should sit off the content edge. The rail's corner stays `--sidebar-float-radius`. The cards use `--top-nav-float-radius`, which defaults to `var(--sidebar-float-radius)`, so a theme that does not set it matches the rail. `[data-theme="rounded"]` sets `--top-nav-float-radius` to `var(--radius-full)`, so those cards are pills. `--top-nav-float-clearance` is the space the scroll pane keeps clear above the first content. It defaults to the float inset (or the top safe area, whichever is larger) plus `3.25rem`. `--layout-content-inset` is `1rem` (the `p-4` step, default `--space-4`) and `2rem` from `640px` (the `p-8` step, default `--space-6`). A theme that remaps `--space-*` does not move it.

`TopNav` `left` and `center` are each one card, sized to their contents. An empty section is hidden, so a host that only fills `left` and `right` does not get a blank center card. `right` is not one card. Each direct child is its own card, so a bell stays separate from the toolbar. A `Button` with `round: true` keeps `--button-round-border-radius`, so a square icon button stays a circle when the other cards are pills. Other children use `--top-nav-float-radius`. Named themes other than rounded still square every floating card, including a round button. There is no new slot. The existing `top_nav` slot and `TopNav`'s `left`, `center`, and `right` are the API.

The pill cards keep `overflow: visible`, so a focus ring is not clipped. Inline padding grows with the corner, up to `0.75rem`, and stays `0.25rem` while `--top-nav-float-radius` equals `--sidebar-float-radius`. Below `768px` that padding drops to `0.25rem` and the row gap drops to `0.5rem`, so a toolbar and one trailing card share a line at `390px`. Text buttons in `left` and `center` use `0.625rem` of inline padding there. Icon buttons keep their hit target. Any `data-theme` other than rounded keeps square corners.

The cards apply at every width, including `390px`. `left` and `center` use `flex: 1 1 0%` and `max-width: max-content`, so those cards shrink before the row wraps. The row still wraps when the trailing cards are wider than the band. `TopNav`'s mobile menu still collapses `center` and `right` below `mobile_breakpoint` unless the slot passes `always_display: true`. Pass that on `right` when the bell should stay on screen. The mobile drawer is unchanged: it stays edge-to-edge, uses the backdrop, and paints above the cards (`z-50` over `z-20`).

The wrapper does not cover clicks in the gaps between cards. The `<header>` landmark stays. Tab order is still the top nav, then main.

Dummy chrome accepts `?floating_top_nav=1`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1` is the floating photo with the cards. Add `content_scroll=below` to park the cards above the scroll pane.

## Where content scrolls

The shell stays `h-screen overflow-hidden`. Only the main pane scrolls, so the rail and the top nav stay put. That is the default, and hosts that do not opt in keep it.

With `floating_top_nav: true`, `content_scroll: :behind` (the default) lets that pane run under the cards. The pane's `padding-top` and `scroll-padding-top` use `--top-nav-float-clearance`, so the first paint and a focused control are not hidden under the cards. When the cards are more than `8px` taller than that token, the layout sets `--top-nav-float-clearance` on the main column to the bottom of the band. A wrapped row, or a toolbar that has grown a second line, then clears the title. A one-row toolbar leaves the token alone. `content_scroll: :below` puts the cards back in the flow, above the pane, still with the float gap and the card chrome. That mode does not need the measurement.

`content_scroll` does nothing while `floating_top_nav` is false. The full-width bar stays outside the pane.

A whole-page scroll mode is not part of this layout. The scroll pane is still one element (`.fp-layout-scroll` when content runs behind the cards). A later option can move `overflow` to the shell without a new chrome component. The corner slot and an account item are also out of scope.

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
