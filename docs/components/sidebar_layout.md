# Sidebar Layout Component

The Sidebar Layout component provides a modern, flexible layout system with a sidebar, top navigation, and main content area. It supports both left and right sidebar placement, desktop collapse functionality, and mobile drawer behavior.

## Features

- **Flexible Positioning**: Support for left or right sidebar placement
- **Desktop Collapse**: Sidebar collapses to icon-only mode on desktop
- **Mobile Drawer**: Off-canvas drawer on mobile with backdrop overlay
- **Persistent State**: Optional localStorage persistence for collapsed state
- **Focus Management**: Proper focus handling for accessibility
- **Smooth Animations**: CSS transitions for all state changes

## Basic Usage

```erb
<%= render FlatPack::SidebarLayout::Component.new do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <%# Sidebar content %>
    <% end %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <%# Top nav content %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <%# Main content %>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `side` | Symbol | `:left` | Sidebar position (`:left` or `:right`) |
| `default_open` | Boolean | `true` | Initial desktop state (expanded or collapsed) |
| `storage_key` | String | `nil` | localStorage key for persisting collapsed state |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`) |

## Slots

### sidebar

Contains the sidebar content. Typically renders a `FlatPack::Sidebar::Component`.

```erb
<% layout.sidebar do %>
  <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
    <%# Sidebar items %>
  <% end %>
<% end %>
```

### top_nav

Contains the top navigation bar. Typically renders a `FlatPack::TopNav::Component`.

```erb
<% layout.top_nav do %>
  <%= render FlatPack::TopNav::Component.new do |nav| %>
    <%# Navigation items %>
  <% end %>
<% end %>
```

### main

Contains the main page content. If not provided, block content is used.

```erb
<% layout.main do %>
  <div class="p-8">
    <%# Page content %>
  </div>
<% end %>
```

## Examples

### Left Sidebar (Default)

```erb
<%= render FlatPack::SidebarLayout::Component.new do |layout| %>
  <% layout.sidebar do %>
    <%= render FlatPack::Sidebar::Component.new do |sidebar| %>
      <% sidebar.items do %>
        <%= render FlatPack::Sidebar::Item::Component.new(
          label: "Dashboard",
          href: dashboard_path,
          icon: :home,
          active: true
        ) %>
      <% end %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <h1>Dashboard</h1>
  <% end %>
<% end %>
```

### Right Sidebar

```erb
<%= render FlatPack::SidebarLayout::Component.new(side: :right) do |layout| %>
  <% layout.sidebar do %>
    <%# Sidebar content %>
  <% end %>

  <% layout.main do %>
    <%# Main content %>
  <% end %>
<% end %>
```

### With LocalStorage Persistence

```erb
<%= render FlatPack::SidebarLayout::Component.new(
  storage_key: "my-app-sidebar-state"
) do |layout| %>
  <%# Layout content %>
<% end %>
```

### With Mobile Hamburger Toggle

```erb
<%= render FlatPack::SidebarLayout::Component.new do |layout| %>
  <% layout.sidebar do %>
    <%# Sidebar content %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <% nav.left do %>
        <button
          type="button"
          class="md:hidden p-2 rounded-lg hover:bg-[var(--color-muted)]"
          data-flat-pack--sidebar-layout-target="mobileToggle"
          data-action="click->flat-pack--sidebar-layout#toggleMobile"
          aria-label="Toggle sidebar"
        >
          <%= render FlatPack::Shared::IconComponent.new(name: :menu, size: :md) %>
        </button>
      <% end %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <%# Main content %>
  <% end %>
<% end %>
```

## Layout Structure

The component uses CSS Grid for stable layout:

- **Left sidebar layout**: `grid-cols-[auto,1fr]` - sidebar first, then main
- **Right sidebar layout**: `grid-cols-[1fr,auto]` - main first, then sidebar

The main column contains:
1. Top navigation (sticky at top)
2. Main content area (scrollable)

## Mobile Behavior

On mobile (< 768px):
- Sidebar becomes a fixed off-canvas drawer
- Backdrop overlay appears when drawer is open
- Drawer slides from the correct side based on `side` prop
- Clicking backdrop or pressing Escape closes the drawer
- Focus moves to first focusable element when opened
- Focus returns to toggle button when closed

## Desktop Behavior

On desktop (≥ 768px):
- Sidebar is always visible
- Sidebar can be collapsed to icon-only mode
- Width transitions smoothly between expanded (16rem) and collapsed (4rem)
- State persists in localStorage if `storage_key` is provided
- Labels fade in/out during transition

## Accessibility

- Proper ARIA attributes for expanded/collapsed states
- Focus management for drawer open/close
- Keyboard support (Escape to close drawer)
- Screen reader friendly with appropriate labels

## Stimulus Controller

The component uses the `flat-pack--sidebar-layout` Stimulus controller for behavior.

### Actions

- `toggleDesktop()` - Toggle collapsed state on desktop
- `toggleMobile()` - Toggle drawer open/close on mobile
- `openMobile()` - Open mobile drawer
- `closeMobile()` - Close mobile drawer

### Targets

- `sidebar` - The sidebar element
- `backdrop` - The backdrop overlay (mobile only)
- `desktopToggle` - Desktop collapse toggle button
- `mobileToggle` - Mobile hamburger toggle button

### Values

- `side` - Sidebar position ("left" or "right")
- `defaultOpen` - Initial desktop state
- `storageKey` - LocalStorage key for persistence

## Related Components

- [Sidebar](./sidebar.md) - Sidebar content wrapper
- [Sidebar::Group](./sidebar_group.md) - Collapsible sidebar groups
- [TopNav](./top_nav.md) - Top navigation bar
