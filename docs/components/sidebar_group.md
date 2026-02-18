# Sidebar Group Component

The Sidebar Group component provides collapsible accordion-style groups within a sidebar.

## Features

- **Collapsible**: Click to expand/collapse child items
- **Smooth Animation**: Height animation for expand/collapse
- **Icon Support**: Optional icon for the group header
- **Accessible**: Proper ARIA attributes for screen readers
- **Works in Collapsed Mode**: Children render as icons when sidebar is collapsed

## Basic Usage

```erb
<%= render FlatPack::Sidebar::Group::Component.new(
  label: "More",
  icon: :dots
) do |group| %>
  <% group.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Settings",
      href: settings_path,
      icon: :cog
    ) %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Help",
      href: help_path,
      icon: :question
    ) %>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `label` | String | Required | Group header text |
| `icon` | Symbol | `nil` | Icon name for group header |
| `default_open` | Boolean | `false` | Initial expanded state |
| `collapsed` | Boolean | `false` | Whether sidebar is collapsed (hides labels) |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`) |

## Slots

### items

Contains the child navigation items that appear when group is expanded.

```erb
<% group.items do %>
  <%= render FlatPack::Sidebar::Item::Component.new(...) %>
  <%= render FlatPack::Sidebar::Item::Component.new(...) %>
<% end %>
```

## Examples

### Basic Group

```erb
<%= render FlatPack::Sidebar::Group::Component.new(
  label: "Settings",
  icon: :cog
) do |group| %>
  <% group.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Profile",
      href: profile_path,
      icon: :user
    ) %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Security",
      href: security_path,
      icon: :lock
    ) %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Preferences",
      href: preferences_path,
      icon: :sliders
    ) %>
  <% end %>
<% end %>
```

### Initially Expanded

```erb
<%= render FlatPack::Sidebar::Group::Component.new(
  label: "Quick Links",
  icon: :star,
  default_open: true
) do |group| %>
  <% group.items do %>
    <%# Items %>
  <% end %>
<% end %>
```

### In Collapsed Sidebar

When the sidebar is collapsed, pass `collapsed: true`:

```erb
<%= render FlatPack::Sidebar::Group::Component.new(
  label: "More",
  icon: :dots,
  collapsed: true
) do |group| %>
  <% group.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Settings",
      href: settings_path,
      icon: :cog,
      collapsed: true
    ) %>
  <% end %>
<% end %>
```

## Behavior

### Expand/Collapse

Click the group header to toggle between expanded and collapsed states. The panel smoothly animates between states using CSS transitions.

### Chevron Indicator

A chevron icon appears on the right side of the header (hidden when sidebar is collapsed). The chevron rotates to indicate open/closed state:
- Open: Points down (0deg)
- Closed: Points left (-90deg)

### Height Animation

The component uses measured height animation:
1. On open: Sets `max-height` to the panel's `scrollHeight`
2. On close: Sets `max-height` to `0`
3. Transitions smoothly over 200ms

## Accessibility

### ARIA Attributes

- `aria-expanded` - Reflects current expanded/collapsed state
- `aria-controls` - Links button to controlled panel via ID

### Screen Reader Support

- Group label is always readable
- When sidebar is collapsed, label uses `sr-only` class for visual hiding while remaining accessible

### Keyboard Support

- Enter/Space activates the group toggle button
- Focus is managed by standard button semantics

## Stimulus Controller

The component uses the `flat-pack--sidebar-group` Stimulus controller.

### Actions

- `toggle()` - Toggle between expanded and collapsed states
- `open()` - Expand the group
- `close()` - Collapse the group

### Targets

- `button` - The header button element
- `panel` - The collapsible content panel
- `chevron` - The chevron indicator icon

### Values

- `defaultOpen` - Initial expanded state (Boolean)

## Styling

The group header button is styled like a regular Sidebar::Item:
- Same padding, typography, and hover states
- Maintains visual consistency
- Smooth color transitions

## Related Components

- [Sidebar](./sidebar.md) - Parent sidebar container
- [Sidebar::Item](./sidebar.md#sidebaritem) - Navigation items
- [SidebarLayout](./sidebar_layout.md) - Layout wrapper
