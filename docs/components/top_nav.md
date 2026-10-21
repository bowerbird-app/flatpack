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
| `mobile_menu` | Boolean | `true` | No | On a phone viewport, fold the row into one hamburger menu. |
| `mobile_menu_label` | String | `"Menu"` | No | Accessible label for the hamburger toggle and the menu panel. |
| `mobile_breakpoint` | Integer | `768` | No | Viewport width (px). Below this, the row folds into the menu. A wide window keeps the row. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<header>` element (`class`, `id`, `data`, `aria`, `style`). |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `left` | block slot | No | Left-aligned content wrapper (`h-full flex items-center gap-2`). Accepts `always_display:` (default `false`). |
| `center` | block slot | No | Center wrapper (`h-full min-w-0 flex-1 flex items-center justify-center`). The search field inside it can shrink. Accepts `always_display:` (default `false`). |
| `right` | block slot | No | Right-aligned content wrapper (`h-full flex items-center justify-end gap-2`). Accepts `always_display:` (default `false`). |

TopNav always renders all three wrappers (`left`, `center`, `right`) even if one slot is blank or uninitialized. The center wrapper shrinks. Left and right keep their content width.

Each section carries `data-flat-pack-top-nav-section` (`left`, `center`, or `right`) even when `mobile_menu: false`. [Sidebar Layout](sidebar_layout.md) `floating_top_nav: true` uses that hook to turn the bar into cards. Card padding and the row gap then come from `--top-nav-float-padding-block` (`0.25rem`), `--top-nav-float-padding-inline` (the radius difference, clamped between `0.25rem` and `0.75rem`), and `--top-nav-float-gap` (`0.75rem`). The `<header>` landmark stays on this component.

The bar is `.fp-top-nav`: `--top-nav-height` (`72px`) of content height plus `env(safe-area-inset-top)`, with left/right padding at least `1rem` and never less than the side insets. That rule is unlayered. Host Tailwind preflight (`* { padding: 0 }` in `@layer base`) loads after Flatpack and would otherwise wipe the inset. Hosts need `viewport-fit=cover` for those insets to apply. See [Installation](../installation.md).

At rest the bar does not frost the page (`backdrop-filter: blur(0)`). After the page has scrolled, it uses `--top-nav-backdrop-blur` (default `16px`, same pattern as `--modal-backdrop-blur`). `--top-nav-background-color` stays the fill; do not add a second TopNav variant. The `flat-pack--top-nav` Stimulus controller sets `data-scrolled` and listens to the window plus the nearest overflow pane (including SidebarLayout’s main column). Hosts do not attach a window scroll listener. The controller stays on when `mobile_menu: false`.

## Mobile menu

A wide viewport keeps the horizontal row, even when the bar itself is a narrow column between a rail and an aside. Below a phone viewport (`max-width: mobile_breakpoint - 1`), that row moves into one menu opened by a hamburger button (`icon: "menu"`, `aria-label` "Menu"). The open menu is one column: each action is a full-width row. A nested button dropdown does not stay a menu inside that list. Its trigger is omitted and its items are rows in the same column, in source order. The sidebar's mobile toggle (`data-flat-pack--sidebar-layout-target="mobileToggle"`) is not part of the row, so it stays in the bar and opens the sidebar drawer. A notification bell is not part of the row either: put it in a section with `always_display: true` so it stays beside the hamburger. The open panel is `position: fixed` under the toggle, so a short overflow-hidden column does not clip it. It sits at `z-index: 30`, above the page and below a drawer scrim. Content is relocated rather than duplicated, so ids, event listeners, and Stimulus controllers keep working.

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

  <%# Stays in the bar. Not part of the row that folds. %>
  <% nav.right(always_display: true) do %>
    <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, style: :ghost, aria: { label: "Notifications" }) %>
  <% end %>
<% end %>
```

Set `mobile_menu: false` to keep the row at every width.

The hamburger is rendered hidden and revealed by the `flat-pack--top-nav` Stimulus controller only when the menu has rows, so no toggle appears without JavaScript or when every section stays inline.

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

The hamburger is a labelled button with `aria-expanded` and `aria-controls` pointing at the menu panel. The menu closes on `Escape` (returning focus to the toggle), on outside click, and when a link inside it is followed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `flat-pack--top-nav` Stimulus controller (shipped with the engine importmap) for the hamburger menu and scroll frost.
- Optional companion components commonly used inside slots: `FlatPack::Search::Component`, `FlatPack::SidebarLayout::Component`.
