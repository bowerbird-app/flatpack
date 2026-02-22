# TopNav Component

The TopNav component provides a sticky header bar with left, center, and right sections for navigation and actions.

## Features

- **Sticky Positioning**: Stays at top of content area when scrolling
- **Backdrop Blur**: Semi-transparent background with blur effect
- **Three Sections**: Left, center, and right slots for flexible content
- **Responsive**: Works with both left and right sidebar layouts

## Basic Usage

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-xl font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      placeholder: "Search..."
    ) %>
  <% end %>

  <% nav.right do %>
    <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]">
      <%= render FlatPack::Shared::IconComponent.new(name: :bell, size: :md) %>
    </button>
  <% end %>
<% end %>
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`) |

## Slots

### left

Left section of the navigation bar. Typically contains:
- Mobile hamburger menu button
- Page title or breadcrumbs
- Back button

```erb
<% nav.left do %>
  <button
    type="button"
    class="md:hidden p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]"
    data-flat-pack--sidebar-layout-target="mobileToggle"
    data-action="click->flat-pack--sidebar-layout#toggleMobile"
  >
    <%= render FlatPack::Shared::IconComponent.new(name: :menu, size: :md) %>
  </button>
  
  <h1 class="text-xl font-semibold">Dashboard</h1>
<% end %>
```

### center

Center section of the navigation bar. Typically contains:
- Search input
- Tab navigation
- Breadcrumbs

```erb
<% nav.center do %>
  <%= render FlatPack::Search::Component.new(
    placeholder: "Search..."
  ) %>
<% end %>
```

### right

Right section of the navigation bar. Typically contains:
- User profile menu
- Notifications button
- Settings button
- Theme toggle

```erb
<% nav.right do %>
  <div class="flex items-center gap-2">
    <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]">
      <%= render FlatPack::Shared::IconComponent.new(name: :bell, size: :md) %>
    </button>
    
    <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]">
      <%= render FlatPack::Shared::IconComponent.new(name: :user, size: :md) %>
    </button>
  </div>
<% end %>
```

## Slot Alignment (Justification)

TopNav uses a single horizontal flex row with three slot wrappers:

- **left**: `flex items-center gap-2` (content stays on the left)
- **center**: `flex-1 flex items-center justify-center` (takes remaining space and centers content)
- **right**: `flex items-center gap-2` (content sits on the right edge when center is present)

### How the layout behaves

- If you render **left + center + right**, center stays visually centered and right appears at the far right.
- If you render **left + right** (no center), right appears directly after left with a small gap.
- If you need right content pinned to the edge without center, add your own spacer in `left` (for example `mr-auto`) or place the main title in `center`.

### Example: Balanced (left + center + right)

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(placeholder: "Search...") %>
  <% end %>

  <% nav.right do %>
    <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]">Alerts</button>
  <% end %>
<% end %>
```

### Example: Left + Right only (no center)

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-lg font-semibold">Settings</h1>
  <% end %>

  <% nav.right do %>
    <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)]">Save</button>
  <% end %>
<% end %>
```

## Examples

### Full TopNav

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <button
      type="button"
      class="md:hidden p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)] transition-colors"
      data-flat-pack--sidebar-layout-target="mobileToggle"
      data-action="click->flat-pack--sidebar-layout#toggleMobile"
      aria-label="Toggle sidebar"
    >
      <%= render FlatPack::Shared::IconComponent.new(name: :menu, size: :md) %>
    </button>

    <h1 class="text-xl font-semibold">Dashboard</h1>
  <% end %>

  <% nav.center do %>
    <%= render FlatPack::Search::Component.new(
      placeholder: "Search projects, files, or people..."
    ) %>
  <% end %>

  <% nav.right do %>
    <div class="flex items-center gap-2">
      <%= link_to new_project_path, class: "px-3 py-1.5 text-sm font-medium rounded-lg bg-[var(--color-primary)] text-white hover:opacity-90 transition-opacity" do %>
        New Project
      <% end %>
      
      <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)] transition-colors relative">
        <%= render FlatPack::Shared::IconComponent.new(name: :bell, size: :md) %>
        <span class="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
      </button>
      
      <button class="p-2 rounded-lg hover:bg-[var(--surface-muted-bg-color)] transition-colors">
        <%= render FlatPack::Shared::IconComponent.new(name: :user, size: :md) %>
      </button>
    </div>
  <% end %>
<% end %>
```

### With Tabs

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-xl font-semibold">Projects</h1>
  <% end %>

  <% nav.center do %>
    <nav class="flex gap-1 p-1 bg-[var(--surface-muted-bg-color)] rounded-lg">
      <%= link_to "All", projects_path, class: "px-4 py-1.5 text-sm font-medium rounded-md #{'bg-[var(--surface-bg-color)] shadow-sm' if current_page?(projects_path)}" %>
      <%= link_to "Active", active_projects_path, class: "px-4 py-1.5 text-sm font-medium rounded-md #{'bg-[var(--surface-bg-color)] shadow-sm' if current_page?(active_projects_path)}" %>
      <%= link_to "Archived", archived_projects_path, class: "px-4 py-1.5 text-sm font-medium rounded-md #{'bg-[var(--surface-bg-color)] shadow-sm' if current_page?(archived_projects_path)}" %>
    </nav>
  <% end %>

  <% nav.right do %>
    <%= link_to "New Project", new_project_path, class: "btn-primary" %>
  <% end %>
<% end %>
```

### Minimal

```erb
<%= render FlatPack::TopNav::Component.new do |nav| %>
  <% nav.left do %>
    <h1 class="text-xl font-semibold">Settings</h1>
  <% end %>
<% end %>
```

## Styling

### Sticky Positioning

The TopNav is positioned with `sticky top-0`, so it stays at the top of the main content area as the user scrolls.

### Backdrop Blur

Uses `backdrop-blur-lg` with semi-transparent background (`bg-[var(--surface-bg-color)]/80`) for a modern, elevated appearance.

### Border

A subtle border on the bottom separates the TopNav from content below.

### Spacing

- Horizontal padding: `px-4`
- Vertical padding: `py-3`
- Gap between sections: `gap-4`

## Subcomponents

### Search

A reusable search input component that can be used in TopNav, sidebars, and page content areas.

Props:
- `placeholder` - Placeholder text (default: "Search...")
- `name` - Input name attribute (default: "q")
- `value` - Initial value

## Layout Integration

The TopNav is typically used within a `FlatPack::SidebarLayout::Component`:

```erb
<%= render FlatPack::SidebarLayout::Component.new do |layout| %>
  <% layout.sidebar do %>
    <%# Sidebar content %>
  <% end %>

  <% layout.top_nav do %>
    <%= render FlatPack::TopNav::Component.new do |nav| %>
      <%# TopNav content %>
    <% end %>
  <% end %>

  <% layout.main do %>
    <%# Main content %>
  <% end %>
<% end %>
```

## Related Components

- [SidebarLayout](./sidebar_layout.md) - Layout wrapper
- [Sidebar](./sidebar.md) - Sidebar component
- [Search](./search.md) - Reusable search input
