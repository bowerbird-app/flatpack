# Sidebar Component

The Sidebar component provides a container for sidebar content with header, scrollable items area, and footer sections.

## Features

- **Flexible Layout**: Header at top, scrollable items in middle, footer at bottom
- **Collapsible**: Support for collapsed (icon-only) mode
- **Composable**: Works with Sidebar::Item, Sidebar::Group, and other subcomponents

## Basic Usage

```erb
<%= render FlatPack::Sidebar::Component.new do |sidebar| %>
  <% sidebar.header do %>
    <div class="font-semibold">My App</div>
  <% end %>

  <% sidebar.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Dashboard",
      href: dashboard_path,
      icon: :home
    ) %>
  <% end %>

  <% sidebar.footer do %>
    <%= render FlatPack::Sidebar::CollapseToggle::Component.new %>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `collapsed` | Boolean | `false` | Whether sidebar is in collapsed mode |
| `collapsible` | Boolean | `true` | Whether sidebar can be collapsed |
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`) |

## Slots

### header

Top area of the sidebar. Use for logo, workspace switcher, or title.

```erb
<% sidebar.header do %>
  <div class="flex items-center gap-2">
    <img src="/logo.png" class="w-8 h-8" />
    <span class="font-semibold">My App</span>
  </div>
<% end %>
```

### items

Scrollable middle section. Contains navigation items and groups.

```erb
<% sidebar.items do %>
  <nav class="space-y-1">
    <%= render FlatPack::Sidebar::Item::Component.new(...) %>
    <%= render FlatPack::Sidebar::Item::Component.new(...) %>
    <%= render FlatPack::Sidebar::Divider::Component.new %>
    <%= render FlatPack::Sidebar::Group::Component.new(...) %>
  </nav>
<% end %>
```

### footer

Bottom area of the sidebar, pinned in place. Use for collapse toggle or user profile.

```erb
<% sidebar.footer do %>
  <div class="p-4 border-t border-[var(--color-border)]">
    <%= render FlatPack::Sidebar::CollapseToggle::Component.new(
      collapsed: false
    ) %>
  </div>
<% end %>
```

## Layout Behavior

The sidebar uses flexbox column layout:
- Header: Fixed height at top
- Items: Flexible middle section with `overflow-y-auto`
- Footer: Fixed height at bottom

This ensures the header and footer stay visible while items scroll.

## Styling

- Full height container
- Background color from CSS variables
- Border on the right edge (placement handled by SidebarLayout)
- Width transitions smoothly between expanded (16rem) and collapsed (4rem)

## Examples

### Full Sidebar

```erb
<%= render FlatPack::Sidebar::Component.new do |sidebar| %>
  <% sidebar.header do %>
    <div class="flex items-center gap-3 p-4">
      <div class="w-8 h-8 bg-[var(--color-primary)] rounded-lg flex items-center justify-center text-white font-bold">
        FP
      </div>
      <div>
        <div class="font-semibold text-sm">FlatPack</div>
        <div class="text-xs text-[var(--color-text-muted)]">Workspace</div>
      </div>
    </div>
  <% end %>

  <% sidebar.items do %>
    <nav class="py-4 space-y-1">
      <%= render FlatPack::Sidebar::Item::Component.new(
        label: "Dashboard",
        href: dashboard_path,
        icon: :home,
        active: true
      ) %>
      <%= render FlatPack::Sidebar::Item::Component.new(
        label: "Messages",
        href: messages_path,
        icon: :mail,
        badge: "3"
      ) %>
      <%= render FlatPack::Sidebar::Item::Component.new(
        label: "Projects",
        href: projects_path,
        icon: :folder
      ) %>
      
      <%= render FlatPack::Sidebar::Divider::Component.new %>
      
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
    </nav>
  <% end %>

  <% sidebar.footer do %>
    <div class="p-4 border-t border-[var(--color-border)]">
      <%= render FlatPack::Sidebar::CollapseToggle::Component.new(
        collapsed: false
      ) %>
    </div>
  <% end %>
<% end %>
```

### Minimal Sidebar

```erb
<%= render FlatPack::Sidebar::Component.new do |sidebar| %>
  <% sidebar.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Home",
      href: root_path,
      icon: :home
    ) %>
    <%= render FlatPack::Sidebar::Item::Component.new(
      label: "Settings",
      href: settings_path,
      icon: :cog
    ) %>
  <% end %>
<% end %>
```

## Subcomponents

- **Sidebar::Header** - Header area
- **Sidebar::Item** - Navigation link with icon and optional badge
- **Sidebar::Badge** - Notification badge for items
- **Sidebar::Divider** - Horizontal divider line
- **Sidebar::CollapseToggle** - Toggle button for collapsing sidebar
- **Sidebar::Group** - Collapsible group of items

See [Sidebar::Group documentation](./sidebar_group.md) for accordion groups.

## Related Components

- [SidebarLayout](./sidebar_layout.md) - Layout wrapper that positions sidebar
- [TopNav](./top_nav.md) - Top navigation component
