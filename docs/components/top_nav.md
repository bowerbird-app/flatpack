# Top Nav

## Purpose
Render a top row with a left slot, a center slot, and a right slot. The row has no fill, border, shadow, or scroll frost. [Sidebar Layout](sidebar_layout.md) and [Page Layout](page_layout.md) paint that bar on the `top_nav` slot.

## When to use
Use TopNav in app shells for a title, search, or a short set of controls. Pair it with `SidebarLayout` and `Sidebar`. Dummy `/demo/navbar` is this component. `/demo/navbar?example=header` is the header row: page nav on the left, a collapsing button group on the right.

## Class
- Primary: `FlatPack::TopNav::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the `<header>` element (`class`, `id`, `data`, `aria`, `style`). |

TopNav does not fold. It has no phone menu, no breakpoint, and no flag that pins a child in the bar. A group of actions that should become one menu on a phone is `FlatPack::ButtonGroup::Component` with `collapse: :menu`, usually in `right`. A notification bell, an avatar, and the sidebar's mobile toggle stay plain children beside that group.

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `left` | block slot | No | Left-aligned content (`h-full min-w-0 flex items-center gap-2`). |
| `center` | block slot | No | Center wrapper (`h-full min-w-0 flex-1 flex items-center justify-center`). It grows, then shrinks. |
| `right` | block slot | No | Right-aligned content (`h-full min-w-0 flex items-center justify-end gap-2`). |

TopNav always renders all three wrappers, even when a slot is blank. `left` and `right` use `min-w-0`, so a long title can shrink instead of pushing the row sideways. A field in a slot uses `min-width: 0` and stays inside that column. The slots do not hide their children. A child that should disappear into a menu owns that collapse.

The sections are `.fp-top-nav__left`, `.fp-top-nav__center`, and `.fp-top-nav__right`. They carry no `data-flat-pack-top-nav-section` hook. A parent does not style a slot's children. The `<header>` landmark stays on this component.

The row is `.fp-top-nav`: `--top-nav-height` (`72px`) of content height plus `env(safe-area-inset-top)`, with left/right padding at least `--top-nav-padding-inline` and never less than the side insets. `min-width: 0` and `max-width: 100%` keep the row inside its column. That rule is unlayered. Host Tailwind preflight (`* { padding: 0 }` in `@layer base`) loads after Flatpack and would otherwise wipe the inset. Hosts need `viewport-fit=cover` for those insets to apply. See [Installation](../installation.md).

TopNav is not sticky and does not frost. The shell's `.fp-layout-top-nav` wrapper is the bar: `--top-nav-background-color`, a hairline from `--top-nav-border-color`, and `--top-nav-backdrop-blur` after scroll. See [Sidebar Layout](sidebar_layout.md).

A floating cluster is a surface the host places in a slot. `FlatPack::Card::Component.new(padding: :sm, radius: :xxxl, shadow: :sm, class: "!h-auto")` is that surface. `radius: :xxxl` is the roundest card corner (`--radius-xxxl`, 40px). `class: "!h-auto"` overrides the card's `h-full`. Card rejects `style:` because that name was a theme. There is no separate pill component.

## Header row

Put the back and close controls on the left with `flat_pack_page_nav_tag`. Put the page actions on the right with `page_nav_button_group(styles:, collapse: :menu, visible: 2)`. On a wide screen the first two actions stay in the row and the rest sit under More. On a phone the group is one menu. The bar does not add a second one.

```erb
<% flat_pack_page_nav(anchor_href: demo_path, anchor_tooltip: "Close") %>
<% register_page_nav "Edit", edit_press_kit_path, role: :primary, icon: :pencil %>
<% register_page_nav "Share", share_press_kit_path, role: :secondary, icon: :share %>
<% register_page_nav "Duplicate", duplicate_press_kit_path, role: :secondary, icon: :"document-duplicate" %>
<% register_page_nav "Delete", press_kit_path, role: :destructive, icon: :trash, overflow: true %>

<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <%= flat_pack_page_nav_tag %>
  <% end %>

  <% nav.right do %>
    <%= page_nav_button_group(styles: FlatPack::PageNavRoleStyles::QUIET, collapse: :menu, visible: 2) %>
  <% end %>
<% end %>
```

A bell or an avatar sits next to that group, as its own child. See [Button group](button-group.md) and [Page nav registry](page-nav-registry.md).

## Variants
None.

## Example

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="min-w-0 truncate text-lg font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      items: [{title: "Buttons", description: "Button styles", url: "/demo/buttons"}],
      placeholder: "Search...",
      class: "min-w-0 max-w-xl"
    ) %>
  <% end %>

  <% nav.right do %>
    <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, style: :ghost, aria: { label: "Notifications" }) %>
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
TopNav itself is structural (`<header>`). Accessibility depends on the controls inside the slots. The row does not move focus and does not add a menu.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional companion components commonly used inside slots: `FlatPack::Search::Component`, `FlatPack::ButtonGroup::Component`, `FlatPack::Card::Component`, `FlatPack::SidebarLayout::Component`.
- Scroll frost lives on the shell wrapper (`flat-pack--top-nav`), not on this row.
