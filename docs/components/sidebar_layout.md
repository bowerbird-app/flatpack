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
| `floating` | Boolean | `false` | No | Desktop-only detached panels. The column is the card. Insets all four sides with `--sidebar-float-inset`. Rounded corners follow the rounded palette (no `data-theme`, or a list that contains `rounded`, such as `data-theme="rounded harbor"`). Ignored below the `md` breakpoint. |
| `floating_top_nav` | Boolean | `false` | No | Replaces the full-width top bar with floating cards. Uses the same `--sidebar-float-*` gap, fill, shadow, and corner as the rail. `false` leaves the bar unchanged. |
| `content_scroll` | Symbol | `:behind` | No | Where main content sits when `floating_top_nav: true`. `:behind` scrolls the page under the cards and pads the scroll pane with `--top-nav-float-clearance`. `:below` keeps the cards above the scroll pane. Ignored when the top nav is not floating. |
| `scroll` | Symbol | `:pane` | No | `:pane` locks the shell and scrolls the main pane. `:page` scrolls the window. The rail and the aside stick. With floating cards and `:behind`, the cards stick and a fixed `.fp-layout-page-surface` fills the page when there is no photo. `html` gets `scroll-padding-top`. `:page` with `content_scroll: :below` raises `ArgumentError`. |
| `height` | Symbol | `:full` | No | Height of the floating desktop rail. `:full` is today's rail (viewport minus the float insets). `:content` sizes the rail to its items and caps it at that same viewport height. The items scroll inside the cap. Ignored when `floating` is false. The mobile drawer stays full height. Not the image `height` attribute. |
| `width` | Symbol | `:fixed` | No | Width of the open desktop rail. `:fixed` uses `--sidebar-width` (`16rem`). `:content` sizes the rail to its widest item, clamped by `--sidebar-content-min-width` (`12rem`) and `--sidebar-content-max-width` (`20rem`). Collapsed width stays `--sidebar-collapsed-width` (`4rem`). The mobile drawer stays `--sidebar-width`. Unknown values raise `ArgumentError`. |
| `resizable` | Boolean | `false` | No | Desktop separator on the rail. `true` or `false`. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into root container. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `sidebar` | block slot | No | Sidebar column content (typically `FlatPack::Sidebar::Component`). |
| `top_nav` | block slot | No | Optional top-nav area above main content. |
| `main` | block slot | No | Main content area. If omitted, component block content is used. |
| `background` | block slot | No | Decorative page photo (`img` or `picture`) behind the shell. Omit it and the shell matches a layout with no photo. |
| `aside` | block slot | No | Column opposite `side:`. `open:` (`true` or `false`, default `true`) and `resizable:` (`true` or `false`, default `false`). Omit it and the shell matches a layout with no aside. |

## Variants

| variant | description |
|---------|-------------|
| `side: :left` | Grid columns render as `auto 1fr`; sidebar enters from left on mobile. |
| `side: :right` | Grid columns render as `1fr auto`; sidebar enters from right on mobile. |
| `storage_key: "..."` | Enables persisted desktop collapse state in localStorage. |
| `floating: true` | Desktop columns sit inset on every side. The column carries the fill, border, radius, and shadow. Contents fill that column. The rounded palette rounds it with `--sidebar-float-radius`. Other named themes stay square. Below `md` the drawer stays full height and square. |
| `height: :content` | Floating desktop rail shrinks to its items and sits at the top inset. A rail taller than the viewport stops at the float cap and scrolls inside. |
| `width: :fixed` | Open desktop rail is `--sidebar-width`. This is the default. |
| `width: :content` | Open desktop rail hugs its widest item, between `--sidebar-content-min-width` and `--sidebar-content-max-width`. |
| `resizable: true` | Separator on the rail. Drag, arrow keys, and double-click reset are desktop only. |
| `aside` | Second column on the opposite edge. `open: false` starts it closed on desktop. Below `md` it is a drawer from that edge. |
| `floating_top_nav: true` | The full-width bar is gone. `TopNav` `left` and `center` each become one card sized to their contents. `right` lays its children out as separate cards. Content scrolls under the cards. |
| `content_scroll: :below` | Same cards, in flow above the scroll pane. Content does not slide under them. |
| `scroll: :page` | The window scrolls. `:pane` is the default and keeps the locked shell. |
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
Mobile drawer backdrop uses `aria-hidden` and supports Escape to close via controller behavior. Focus is moved to the open panel and returned to the previous control on close. Backdrop fill is `--drawer-backdrop-color` (aliases `--modal-backdrop-color`). One backdrop serves the rail drawer and the aside drawer. Opening one closes the other. `closeMobile` closes whichever shell drawer is open.

The resize handle is a vertical `separator` with `aria-valuenow`, `aria-valuemin`, and `aria-valuemax`. Arrow keys move it. Double-click resets it. The name is "Resize sidebar" or "Resize aside". An `asideToggle` control gets `aria-expanded`.

The background layer is decorative. The layout marks it `aria-hidden="true"`. Pass `alt=""` on the image. Under `prefers-reduced-transparency: reduce`, or when `filter: blur()` is unavailable, the photo is hidden and the tint becomes solid so text stays on the page colour.

## Collapsed (icon-only) mode

Desktop collapse is one motion: the rail width eases `--sidebar-width` → `--sidebar-collapsed-width` (`16rem` → `4rem` unless a theme changes the tokens) on `--duration-slow` / `--easing-standard` while labels fade on `--duration-fast` and shrink to zero width on `--duration-slow`. The icon's leading margin eases on that same curve, by a fixed length, so the closed active pill has the same space on both sides of the icon. Padding and gap ease with the width. The header collapse control keeps its own padding, so the hover fill wraps the chevron. Nothing restyles the row when the width transition ends, so the close does not shudder.

The column owns the width and the stored flag. It writes `data-flat-pack-sidebar-collapsed` (`"true"` or `"false"`) on the column only. The storage key stores collapsed, so `"true"` collapses the rail. Each desktop apply dispatches `flat-pack--sidebar-layout:collapse` with `{ collapsed }` from that column. The menu paints the collapsed look from the ancestor attribute, or from its own attribute when you pass `collapsed: true` on a menu used alone. A menu inside the layout does not set the attribute when `collapsed:` is false.

The closed look is the menu icon (`aria-label="Open sidebar"`), a hidden `.fp-sidebar-brand`, centered icons, and a `--sidebar-collapsed-width` rail (`4rem` by default). The length uses `--sidebar-collapsed-width`, `--sidebar-item-inset`, `--sidebar-item-padding-collapsed`, and `--sidebar-collapsed-frame` (the column sets `2px` while floating, and the menu falls back to `1px`). The brand and the header buttons change with the same attribute as the width. `prefers-reduced-motion: reduce` snaps to the end state (duration tokens are `0ms`).

This is applied to:
- Every element with `data-flat-pack-sidebar-item="true"` (`Sidebar::Item::Component` links and `Sidebar::Group::Component` header buttons).
- Item, group, header, and collapse-toggle `.fp-sidebar-label` text uses the screen-reader clip and fades. Section titles fade and keep their block height so item/icon row height does not jump. `.fp-sidebar-footer` fades and ignores pointer events.
- Every element with `data-flat-pack-sidebar-section-title="true"`, and each icon row — a tooltip shows the full label on hover while `data-flat-pack-sidebar-collapsed` is `true`. The tip does not wait for an `sr-only` label.

For static/non-interactive collapsed demos (without the layout controller) pass `collapsed: true` to `Sidebar::Item::Component` and `Sidebar::SectionTitle::Component` to render compact icon-only markup server-side.

## Floating

`floating: true` detaches the desktop columns from the viewport edges. Each column keeps the same width transition (`--sidebar-width` / `--sidebar-collapsed-width`) and adds `--sidebar-float-inset` (`1rem`) on the top, bottom, and both sides. The column is the card. Its fill is `--sidebar-float-background-color` (`#fff` on the default palette, a lifted surface on dark), with a full border and `--sidebar-float-shadow`. The column sets `--sidebar-background-color` and `--sidebar-header-background-color` to that fill, and `--sidebar-collapsed-frame` to `2px`. Contents fill the column. They do not select `data-flat-pack-sidebar-floating`. Header fill follows the inherited panel colour.

Round corners are `--sidebar-float-radius`. The unset theme is `--radius-lg`. Rounded is `--radius-xxxl` (2.5rem, 40px). They apply when `html` has no `data-theme`, or when the list contains `rounded` (`data-theme="rounded"` or `data-theme="rounded harbor"`). A list without `rounded` (dark, ocean, a host theme alone) keeps square corners. The rounded item highlight is the float radius minus `--sidebar-item-inset`, so it shares the rail's center. The top-nav clamp still holds because the pill is `--radius-full`. Below the `md` breakpoint the attribute is present and unused: the drawer stays edge-to-edge, including its safe-area padding.

Dummy chrome accepts `?floating=1` (or `true`) on any page. Omit it for the flush rail. `/demo/sidebar_layout?floating=1&background=1&height=content&aside=1&resizable=1` is the short rail and the open aside, both cards, on the photo. Add `notes=1` for a rail that is not a menu. Add `collapsed=1` to start the rail closed.

## Rail height

`height: :full` (the default) keeps the floating desktop rail at `calc(100vh - (var(--sidebar-float-inset) * 2))`. `height: :content` sizes that rail to its items and keeps the same cap as a max-height, so a long list scrolls inside the card. The two heights are separate rules. Content height does not override the full-height declaration.

`height: :content` does nothing when `floating` is false. The flush column stays `md:h-screen`. Below `md`, the drawer stays full height either way. The content-height rules live in the same `min-width: 768px` block as the rest of the floating rail.

A bottom-left avatar card is not part of this layout. Content height leaves the space under the rail empty: the column stays `md:self-start` and only as tall as its items, or the viewport cap. A later corner slot can pin a second card to the same outer inset and the bottom inset without stretching the rail. Keep that card out of the sidebar footer. The footer sits inside the rail and scrolls away once the list hits the cap.

Dummy chrome accepts `?height=content`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1&height=content` is the short rail with the floating cards. `?height=content` without `?floating=1` stays the flush full-height rail.

## Rail width

`width: :fixed` (the default) keeps the open desktop rail at `--sidebar-width` and the collapsed rail at `--sidebar-collapsed-width`. `width: :content` sizes the open desktop rail to its widest item: the label, the icon, and the insets. `--sidebar-content-min-width` (`12rem`) keeps a short label from collapsing into the icon rail. `--sidebar-content-max-width` (`20rem`) is the same ceiling the label already uses, so a long label can grow past `16rem` without running across the page. A host that wants content mode to stay inside the fixed rail sets `--sidebar-content-max-width: var(--sidebar-width)`.

Closed groups stay in the width. A closed panel uses `max-height: 0`, not `display: none`, so its labels still count. Opening a group does not jump the rail.

The width rules reach the `aside` even when the host wraps it, which the dummy shell does. The first paint uses `max-content` clamped by those tokens, so the inline collapse script can still set `data-flat-pack-sidebar-collapsed` before the aside is parsed. After layout, the controller stores that used width as `--sidebar-measured-width` on the column. It pauses the width transition while it measures, so the stored length is the content size and not a frame from the previous `16rem` rail. The next collapse eases between two lengths. `interpolate-size: allow-keywords` covers the first expand, before that length exists. `prefers-reduced-motion: reduce` still snaps, because the duration tokens are `0ms`.

Collapsed width does not change with `width:`. Below `md`, the drawer stays `--sidebar-width` for both values. `width: :content` works with `floating: true`, `height: :content`, and `floating_top_nav: true`. The floating cards still align to `.fp-layout-content` through `--layout-content-inset`. The rail width does not move that inset.

```erb
<%= render FlatPack::SidebarLayout::Component.new(width: :content, floating: true, height: :content) do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <% sidebar.items do %>
        <%= render FlatPack::Sidebar::Item::Component.new(text: "Home", href: "/", icon: :home, active: true) %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

Dummy chrome accepts `?width=content`. `/demo/sidebar_layout?width=content` hugs the labels. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1&height=content&width=content` is the short floating rail with the cards.

## Aside

`layout.aside` is a column on the opposite edge from `side:`. Leave the slot out and the shell matches a layout with no aside. Same grid, same rail column, one backdrop.

`open:` defaults to `true`. Desktop state is `data-flat-pack-aside-open`. A closed aside has no width and is `inert`. Below `768px` the aside starts off-canvas either way. Desktop `open:` does not open the phone drawer.

The column owns the width and, when floating, the card. The scrollport is `<aside class="fp-aside">`, so the landmark fills the column instead of taking `--sidebar-width`. The main pane still scrolls on its own. `floating:` and `height: :content` reuse the rail attributes. Content height keeps this landmark as a scrollport (`display: block`, `overflow-y: auto`). A floating aside column uses `--sidebar-float-radius`. On the rounded theme that token is `--radius-xxxl` (2.5rem), the same corner as the rail. The landmark inside does not draw a second border.

The tracks are kit CSS on `data-flat-pack-layout-columns` (`three`, `main-aside`, or `aside-main`). The main track is `minmax(0, 1fr)`, so a wide page shrinks instead of pushing the aside out of the shell. There is no new Tailwind class.

With a `storage_key`, the aside key is `storage_key:aside`. `"true"` means open. A missing key keeps the server `open:` value. The rail key is unchanged: `"true"` still means collapsed. A missing rail key keeps the server `open:` value, so `open: false` stays collapsed. The phone drawer is not stored.

```erb
<% layout.aside(open: true) do %>
  <h2>Details</h2>
<% end %>
```

`flat-pack--sidebar-layout` actions are `toggleAside`, `openAside`, and `closeAside`. `openAside` and `closeAside` do nothing when the panel is already in that state. A control with `data-flat-pack--sidebar-layout-target="asideToggle"` gets `aria-expanded`. On a small screen those actions open and close the drawer and do not write the aside key.

The drawer reuses `.fp-sidebar-drawer` and the one backdrop, and it enters from its own edge. Opening the rail drawer closes the aside, and the reverse. Focus moves into the panel and back to the opener. Escape closes the open drawer. The shell joins `document.body.dataset.flatPackModalLockCount`, the same count `Drawer` uses. One shell holds that count once.

Dummy chrome accepts `?aside=1` (open) and `?aside=closed`.

## Resize

`resizable: true` on the layout adds a separator to the rail. The same argument on `aside` adds one to that column. The default is `false`. A non-boolean raises `ArgumentError`.

Arrow keys step 16px. Right grows a left panel and shrinks a right panel. Double-click clears the saved width. Below `768px` the handle is hidden, and pointer and key actions do nothing.

A committed width sets `--fp-panel-width` on the column and `data-flat-pack-panel-resized="true"`. The controller does not set `style.width`. The rail stays between `--sidebar-content-min-width` and `--sidebar-content-max-width`. `width: :content` starts from `--sidebar-measured-width`. A rail drag or arrow below the minimum collapses the rail and does not write a width. The aside stays between `--aside-min-width` (`16rem`) and `--aside-max-width` (`32rem`). It starts at `--aside-width` (`20rem`) and does not collapse.

On a flush column the 1px line is `--resize-handle-color` at rest. That token aliases `--surface-border-color`. Hover and a pressed button use `--resize-handle-active-color`. That token aliases `--surface-muted-content-color`. Keyboard focus widens that line to 3px in `--color-ring` and draws a soft ring of the same colour on the line. A pointer drag does not leave that ring. There is no grip.

On a floating column the card border is the line. The handle does not draw `::after`. The hit strip is `0.5rem` wide and straddles the inner border. The strip is positioned from the padding edge, so the offset is `calc(-0.25rem - 1px)` (`right` on a left column, `left` on a right column) and the strip is centered on the 1px border, at the column's own height. Hover, and `data-flat-pack-panel-dragging="true"` for the whole drag, set the column border to `--resize-handle-active-color`. Keyboard focus paints that border in `--color-ring` with the same soft ring. `data-pointer-focus` still suppresses the ring after a pointer drag. The cursor stays `col-resize`.

Saved widths are `storage_key:rail:width` and `storage_key:aside:width`, integer pixels. No key when `storage_key` is nil.

The controller is `flat-pack--panel-resize` on the column. A drag sets `transition-property: none` and clears it on release. `prefers-reduced-motion: reduce` still snaps, because `--duration-slow` is `0ms`.

```erb
<%= render FlatPack::SidebarLayout::Component.new(resizable: true, storage_key: "app-shell") do |layout| %>
  <% layout.aside(open: true, resizable: true) do %>
    <h2>Details</h2>
  <% end %>
<% end %>
```

Dummy chrome accepts `?resizable=1`. `/demo/sidebar_layout?aside=1&resizable=1` shows both handles.

## Floating top nav

`floating_top_nav: true` takes the full-width bar out of the main column and paints cards on the page, including over a `background` photo. The cards share the rail's fill and shadow: `--sidebar-float-background-color` and `--sidebar-float-shadow`. The vertical gap stays `--sidebar-float-inset`. The horizontal edge is `--layout-content-inset`, the same token as the page padding, plus `--top-nav-float-offset` (`0px`). Put `.fp-layout-content` on the main pane. Its `padding-inline` is `--layout-content-inset`. Put `.fp-layout-column` around the page. That column's `max-width` is `--layout-content-max-width` (`100%` by default, so it fills the pane). A length centers that measure, and the bar uses the same centering, so the title and the cards share the bar's left and right edges. A nested `max-width` with auto margins is a second column and sits in from the bar. Override `--layout-content-inset` to move the page and the bar together. `--top-nav-float-offset` is the extra horizontal gap when the bar should sit off the content edge. The rail's corner stays `--sidebar-float-radius`. The cards use `--top-nav-float-radius`, which defaults to `var(--sidebar-float-radius)`, so a theme that does not set it matches the rail. `[data-theme~="rounded"]` sets `--top-nav-float-radius` to `var(--radius-full)`, so those cards are pills. `--top-nav-float-clearance` is the space the scroll pane keeps clear above the first content. It defaults to the float inset (or the top safe area, whichever is larger) plus `3.25rem`. `--layout-content-inset` is `1rem` (the `p-4` step, default `--space-4`) and `2rem` from `640px` (the `p-8` step, default `--space-6`). A theme that remaps `--space-*` does not move it.

`TopNav` `left` and `center` are each one card, sized to their contents. An empty section is hidden, so a host that only fills `left` and `right` does not get a blank center card. `right` is not one card. Each direct child is its own card, so a bell stays separate from the toolbar. A `Button` with `round: true` keeps `--button-round-border-radius`, so a square icon button stays a circle when the other cards are pills. Other children use `--top-nav-float-radius`. Named themes other than rounded still square every floating card, including a round button. There is no new slot. The existing `top_nav` slot and `TopNav`'s `left`, `center`, and `right` are the API.

The pill cards keep `overflow: visible`, so a focus ring is not clipped. Inline padding grows with the corner, up to `0.75rem`, and stays `0.25rem` while `--top-nav-float-radius` equals `--sidebar-float-radius`. Below `768px` that padding drops to `0.25rem` and the row gap drops to `0.5rem`, so a toolbar and one trailing card share a line at `390px`. Text buttons in `left` and `center` use `0.625rem` of inline padding there. Icon buttons keep their hit target. Any `data-theme` other than rounded keeps square corners.

The cards apply at every width, including `390px`. `left` and `center` use `flex: 1 1 0%` and `max-width: max-content`, so those cards shrink before the row wraps. The row still wraps when the trailing cards are wider than the band. `TopNav`'s mobile menu still collapses `center` and `right` below `mobile_breakpoint` unless the slot passes `always_display: true`. Pass that on `right` when the bell should stay on screen. The mobile drawer is unchanged: it stays edge-to-edge, uses the backdrop, and paints above the cards (`z-50` over `z-20`).

The wrapper does not cover clicks in the gaps between cards. The `<header>` landmark stays. Tab order is still the top nav, then main.

Dummy chrome accepts `?floating_top_nav=1`. `/demo/sidebar_layout?floating=1&background=1&floating_top_nav=1` is the floating photo with the cards. Add `content_scroll=below` to park the cards above the scroll pane.

## Where content scrolls

`scroll: :pane` is the default. The shell stays `h-screen overflow-hidden`, and only the main pane scrolls, so the rail and the top nav stay put. Hosts that omit `scroll:` keep that markup.

With `floating_top_nav: true`, `content_scroll: :behind` (the default) lets that pane run under the cards. The pane's `padding-top` and `scroll-padding-top` use `--top-nav-float-clearance`, so the first paint and a focused control are not hidden under the cards. When the cards are more than `8px` taller than that token, the layout sets `--top-nav-float-clearance` on the main column to the bottom of the band. A wrapped row, or a toolbar that has grown a second line, then clears the title. A one-row toolbar leaves the token alone. `content_scroll: :below` puts the cards back in the flow, above the pane, still with the float gap and the card chrome. That mode does not need the measurement.

`content_scroll` does nothing while `floating_top_nav` is false. The full-width bar stays outside the pane.

`scroll: :page` lets the window scroll. The shell drops `h-screen` and `overflow-hidden`, and the main pane drops `overflow-y-auto` and `overscroll-y-contain`. From `768px`, the rail and the aside use `position: sticky`. With `floating_top_nav: true` and `content_scroll: :behind`, the cards are sticky too. `.fp-layout-scroll` still sets `padding-top` from `--top-nav-float-clearance`. `html` sets `scroll-padding-top` from that same token. When the cards wrap, page mode writes the measured token on `document.documentElement`, so the anchor offset follows the band. When that mode has no `background` photo, the shell renders a fixed `.fp-layout-page-surface` in the page color. The layout generator writes `class="h-full"` on `html` and `body`. It does not write `overflow-hidden`. Leave `h-full`. It does not lock the window. Remove `overflow-hidden` from `html` and `body` when the host added that class. The generator does not. `scroll: :page` with `content_scroll: :below` raises `ArgumentError`. The corner slot and an account item are out of scope.

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
- A resizable rail or aside also requires `flat-pack--panel-resize`. Importmap loads it with the other controllers. esbuild and Vite hosts register it.
