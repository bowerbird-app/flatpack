# Top Nav

## Purpose
Render a sticky top navigation bar with composable left, center, and right content regions.

## When to use
Use TopNav in app shells for page context, global actions, and optional search or controls. Pair it with `SidebarLayout` and `Sidebar`. Dummy `/demo/navbar` is this component.

## Class
- Primary: `FlatPack::TopNav::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `mobile_menu` | Boolean | `true` | No | Collapse a narrow bar into one ellipsis menu at the right end. |
| `mobile_menu_label` | String | `"More actions"` | No | Accessible label for the ellipsis toggle and the menu panel. |
| `mobile_breakpoint` | Integer | `768` | No | Bar width (px) at and above which content returns to the bar. A narrow viewport is included. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<header>` element (`class`, `id`, `data`, `aria`, `style`). |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `left` | block slot | No | Left-aligned content wrapper (`h-full flex items-center gap-2`). Accepts `always_display:` (default `true`). |
| `center` | block slot | No | Center wrapper (`h-full min-w-0 flex-1 flex items-center justify-center`). The search field inside it can shrink. Accepts `always_display:` (default `false`). |
| `right` | block slot | No | Right-aligned content wrapper (`h-full flex items-center justify-end gap-2`). Accepts `always_display:` (default `false`). |

TopNav always renders all three wrappers (`left`, `center`, `right`) even if one slot is blank or uninitialized. The center wrapper shrinks. Left and right keep their content width.

Each section carries `data-flat-pack-top-nav-section` (`left`, `center`, or `right`) even when `mobile_menu: false`. [Sidebar Layout](sidebar_layout.md) `floating_top_nav: true` uses that hook to turn the bar into cards. Card padding and the row gap then come from `--top-nav-float-padding-block` (`0.25rem`), `--top-nav-float-padding-inline` (the radius difference, clamped between `0.25rem` and `0.75rem`), and `--top-nav-float-gap` (`0.75rem`). The `<header>` landmark stays on this component.

The bar is `.fp-top-nav`: `--top-nav-height` (`72px`) of content height plus `env(safe-area-inset-top)`, with left/right padding at least `1rem` and never less than the side insets. That rule is unlayered. Host Tailwind preflight (`* { padding: 0 }` in `@layer base`) loads after Flatpack and would otherwise wipe the inset. Hosts need `viewport-fit=cover` for those insets to apply. See [Installation](../installation.md).

At rest the bar does not frost the page (`backdrop-filter: blur(0)`). After the page has scrolled, it uses `--top-nav-backdrop-blur` (default `16px`, same pattern as `--modal-backdrop-blur`). `--top-nav-background-color` stays the fill; do not add a second TopNav variant. The `flat-pack--top-nav` Stimulus controller sets `data-scrolled` and listens to the window plus the nearest overflow pane (including SidebarLayout’s main column). Hosts do not attach a window scroll listener. The controller stays on when `mobile_menu: false`.

## Mobile ellipsis menu

Below a phone viewport (`max-width: mobile_breakpoint - 1`), the bar stays one row at the same height as the desktop bar. The sidebar toggle, the aside trigger, and a page-nav back or close control stay in `left`. Every other action in `left`, `center`, and `right` moves into one menu opened by an ellipsis button (`aria-label` "More actions"). A page-nav More menu is unpacked into that same menu, so there is no nested More. Primary actions (`data-fp-style="primary"`) are listed first, then the rest in source order (left, then center, then right). Rows are full width and use the surface text color, so a primary button does not keep its pill fill. An icon-only bell shows its accessible name, usually "Notifications". If that bell carries `.fp-red-dot` or `data-flat-pack-unread="true"`, the ellipsis shows a small dot. The open panel is `position: fixed` under the toggle, so a short overflow-hidden column does not clip it. It sits at `z-index: 30`, above the page and below a drawer scrim. Content is relocated rather than duplicated, so ids, event listeners, and Stimulus controllers keep working.

A wide window keeps that desktop row. `center` and `right` still fold when the bar itself is narrower than `mobile_breakpoint`, which is how a floating column between a rail and an aside behaves. Pass `always_display: true` on those slots to keep them inline there. Left-slot actions do not fold on a wide window.

`data-flat-pack-top-nav-always-display="true"` on one control keeps that control inline on the phone, next to the ellipsis. The default is the single icon.

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <%# Collapses into the ellipsis menu on a narrow bar %>
  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      items: [{title: "Buttons", description: "Button styles", url: "/demo/buttons"}],
      placeholder: "Search..."
    ) %>
  <% end %>

  <%# Stays inline on a wide window, including a narrow floating column.
      On a phone the button still folds unless the control itself is marked. %>
  <% nav.right(always_display: true) do %>
    <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, style: :ghost, aria: { label: "Notifications" }) %>
  <% end %>
<% end %>
```

To keep one element inline while the rest of its section collapses, add `data-flat-pack-top-nav-always-display="true"` to that element:

```erb
<% nav.right do %>
  <%= render FlatPack::Button::Component.new(
    icon: "bell",
    icon_only: true,
    style: :ghost,
    aria: { label: "Notifications" },
    data: { flat_pack_top_nav_always_display: true }
  ) %>
  <%= render FlatPack::Button::Component.new(text: "Settings", style: :ghost) %>
<% end %>
```

Set `mobile_menu: false` to opt out entirely and keep the previous always-inline behavior.

The ellipsis toggle is rendered hidden and revealed by the `flat-pack--top-nav` Stimulus controller only when the menu has rows, so no toggle appears without JavaScript or when every action stays inline.

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
      items: [{title: "Buttons", description: "Button styles", url: "/demo/buttons"}],
      placeholder: "Search..."
    ) %>
  <% end %>

  <% nav.right do %>
    <button type="button" class="p-2 rounded-lg">Alerts</button>
  <% end %>
<% end %>
```

## Blank Slot Examples

### 1) Left is uninitialized/blank

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(placeholder: "Search...") %>
  <% end %>

  <% nav.right do %>
    <button type="button" class="p-2 rounded-lg">Alerts</button>
  <% end %>
<% end %>
```

### 2) Center is uninitialized/blank

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <% nav.right do %>
    <button type="button" class="p-2 rounded-lg">Alerts</button>
  <% end %>
<% end %>
```

### 3) Right is uninitialized/blank

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(placeholder: "Search...") %>
  <% end %>
<% end %>
```

## Accessibility
TopNav itself is structural (`<header>`). Accessibility depends on controls rendered inside slots (buttons/links/search inputs) and their labels.

The ellipsis toggle is a labelled button with `aria-expanded` and `aria-controls` pointing at the menu panel. The menu closes on `Escape` (returning focus to the toggle), on outside click, and when a link inside it is followed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `flat-pack--top-nav` Stimulus controller (shipped with the engine importmap) for the ellipsis menu and scroll frost.
- Optional companion components commonly used inside slots: `FlatPack::Search::Component`, `FlatPack::SidebarLayout::Component`.
