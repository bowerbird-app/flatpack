# Top Nav

## Purpose
Render a sticky top navigation bar with composable left, center, and right content regions.

## When to use
Use TopNav in app shells for page context, global actions, and optional search or controls.

## Class
- Primary: `FlatPack::TopNav::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `mobile_menu` | Boolean | `true` | No | Collapse narrow-viewport content into a right-aligned chevron menu. |
| `mobile_menu_label` | String | `"More navigation items"` | No | Accessible label for the chevron toggle and menu panel. |
| `mobile_breakpoint` | Integer | `768` | No | Viewport width (px) at and above which content returns to the bar. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<header>` element (`class`, `id`, `data`, `aria`, `style`). |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `left` | block slot | No | Left-aligned content wrapper (`h-full flex items-center gap-2`). Accepts `always_display:` (default `true`). |
| `center` | block slot | No | Center wrapper (`h-full flex-1 flex items-center justify-center`). Accepts `always_display:` (default `false`). |
| `right` | block slot | No | Right-aligned content wrapper (`h-full flex items-center gap-2`). Accepts `always_display:` (default `false`). |

TopNav always renders all three wrappers (`left`, `center`, `right`) even if one slot is blank or uninitialized. This keeps horizontal alignment stable across pages and states.

## Mobile chevron menu

Below `mobile_breakpoint`, collapsible slot content moves into a menu at the right end of the bar, opened by a chevron-down toggle. Content is relocated rather than duplicated, so ids, event listeners, and Stimulus controllers inside slot content keep working. Above the breakpoint the content returns to its original position.

Defaults keep branding and the sidebar toggle visible: `left` is `always_display: true`, while `center` and `right` collapse.

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <%# Collapses into the chevron menu on mobile %>
  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(placeholder: "Search...") %>
  <% end %>

  <%# Stays in the bar at every viewport width %>
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

The chevron toggle is rendered hidden and revealed by the `flat-pack--top-nav` Stimulus controller only when collapsible content exists, so no toggle appears without JavaScript or when every section is `always_display: true`.

While the menu is open the chevron rotates 180° to point up. The controller applies the class named by `data-flat-pack--top-nav-toggle-open-class` on the `<header>` (`[&>svg]:rotate-180` by default) and removes it on close; the transition classes are rendered on the toggle itself.

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

The chevron toggle is a labelled button with `aria-expanded` and `aria-controls` pointing at the menu panel, and its icon rotation is a visual echo of that state rather than the only cue. The menu closes on `Escape` (returning focus to the toggle), on outside click, and when a link inside it is followed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `flat-pack--top-nav` Stimulus controller (shipped with the engine importmap) for the mobile chevron menu.
- Optional companion components commonly used inside slots: `FlatPack::Search::Component`, `FlatPack::SidebarLayout::Component`.
