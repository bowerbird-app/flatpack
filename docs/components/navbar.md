# Navbar Component

A modern sidebar-first layout system with collapsible navigation and flexible top bar for Rails applications.

## Overview

The Navbar Component provides a complete page layout solution with:
- **Collapsible sidebar** navigation with desktop/mobile responsive behavior
- **Flexible top navigation** bar with three customizable sections (left, center, right)
- **Persistent state** using localStorage
- **Smooth animations** and transitions
- **Badge notifications** for unread counts and alerts
- **Section grouping** with optional collapse functionality
- **Full accessibility** compliance with semantic HTML and ARIA labels

## Demo

Visit `/demo/navbar` in the dummy app to see live examples and interact with all features.

## Basic Usage

```erb
<%= render FlatPack::Navbar::Component.new do |navbar| %>
  <% navbar.sidebar do |sidebar| %>
    <% sidebar.item(text: "Dashboard", icon: "home", href: "/") %>
  <% end %>
  
  <% navbar.top_nav do |nav| %>
    <% nav.left_section do %>
      <span class="text-xl font-bold">MyApp</span>
    <% end %>
  <% end %>
  
  <%= yield %>
<% end %>
```

## Components

The Navbar system consists of five interconnected components that work together to create a complete layout solution:

1. **Navbar::Component** - Main wrapper that coordinates everything
2. **SidebarComponent** - Collapsible navigation sidebar
3. **SidebarItemComponent** - Individual navigation items
4. **SidebarSectionComponent** - Grouped navigation items
5. **TopNavComponent** - Horizontal top bar with three sections

### Navbar::Component

Main wrapper component that provides full-page layout structure.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `**system_arguments` | Hash | `{}` | HTML attributes (`class`, `data`, `aria`, `id`, etc.) |

#### Usage

```erb
<%= render FlatPack::Navbar::Component.new do |navbar| %>
  <% navbar.sidebar do |sidebar| %>
    <!-- Sidebar content -->
  <% end %>
  
  <% navbar.top_nav do |nav| %>
    <!-- Top navigation content -->
  <% end %>
  
  <!-- Main page content -->
  <%= yield %>
<% end %>
```

### SidebarComponent

Full-height navigation sidebar with collapsible behavior and bottom toggle button.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `collapsed` | Boolean | `false` | Initial collapsed state (desktop only) |
| `expanded_width` | String | `"256px"` | Full width with text visible |
| `collapsed_width` | String | `"64px"` | Icon-only width |
| `**system_arguments` | Hash | `{}` | HTML attributes |

#### Usage

```erb
<% navbar.sidebar(collapsed: false, expanded_width: "256px", collapsed_width: "64px") do |sidebar| %>
  <% sidebar.item(text: "Dashboard", icon: "home", href: "/") %>
  <% sidebar.section(title: "Projects") do |section| %>
    <% section.item(text: "Active", href: "/projects") %>
  <% end %>
<% end %>
```

### SidebarItemComponent

Individual navigation items with icons, text, and optional badge notifications.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | String | (required) | Display text for the navigation item |
| `href` | String | `nil` | Link URL (renders as button if omitted) |
| `icon` | String | `nil` | Lucide icon name (e.g., "home", "mail") |
| `active` | Boolean | `false` | Highlight as current page |
| `badge` | String/Integer | `nil` | Notification count or text |
| `badge_style` | Symbol | `:primary` | Badge color (`:primary`, `:secondary`, `:success`, `:warning`, `:danger`) |
| `**system_arguments` | Hash | `{}` | HTML attributes |

#### Badge Styles

```erb
<!-- Primary badge (default) -->
<% sidebar.item(text: "Messages", icon: "mail", badge: "5", badge_style: :primary) %>

<!-- Success badge -->
<% sidebar.item(text: "Completed", icon: "check", badge: "12", badge_style: :success) %>

<!-- Warning badge -->
<% sidebar.item(text: "Pending", icon: "clock", badge: "3", badge_style: :warning) %>

<!-- Danger badge -->
<% sidebar.item(text: "Alerts", icon: "alert-circle", badge: "!", badge_style: :danger) %>

<!-- Secondary badge -->
<% sidebar.item(text: "Archive", icon: "archive", badge: "99+", badge_style: :secondary) %>
```

#### Active State

```erb
<% sidebar.item(
  text: "Dashboard",
  icon: "home",
  href: dashboard_path,
  active: current_page?(dashboard_path)
) %>
```

#### As Button

Omit the `href` prop to render as a button instead of a link:

```erb
<% sidebar.item(
  text: "Sign Out",
  icon: "log-out",
  data: { turbo_method: :delete }
) %>
```

### SidebarSectionComponent

Groups related navigation items with optional collapse functionality.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | String | `nil` | Section header text |
| `collapsible` | Boolean | `false` | Enable collapse/expand functionality |
| `collapsed` | Boolean | `false` | Initial collapsed state |
| `**system_arguments` | Hash | `{}` | HTML attributes |

#### Usage

```erb
<!-- Basic section -->
<% sidebar.section(title: "Main") do |section| %>
  <% section.item(text: "Dashboard", icon: "home", href: "/") %>
  <% section.item(text: "Settings", icon: "settings", href: "/settings") %>
<% end %>

<!-- Collapsible section -->
<% sidebar.section(title: "Projects", collapsible: true, collapsed: false) do |section| %>
  <% @projects.each do |project| %>
    <% section.item(text: project.name, icon: "folder", href: project_path(project)) %>
  <% end %>
<% end %>
```

### TopNavComponent

Horizontal navigation bar with three customizable sections and built-in hamburger menu for mobile.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `height` | String | `"64px"` | Navigation bar height |
| `**system_arguments` | Hash | `{}` | HTML attributes |

#### Sections

The top navigation provides three slots for custom content:

- **Left** - Typically for logo/branding (hamburger menu automatically added on mobile)
- **Center** - For search bars or page titles
- **Right** - For user menu, notifications, or action buttons

#### Usage

```erb
<% navbar.top_nav(height: "64px") do |nav| %>
  <% nav.left_section do %>
    <span class="text-xl font-bold">MyApp</span>
  <% end %>
  
  <% nav.center_section do %>
    <%= search_field_tag :q, nil, placeholder: "Search...", class: "px-4 py-2 rounded-md border" %>
  <% end %>
  
  <% nav.right_section do %>
    <%= render FlatPack::Button::Component.new(text: "Profile", style: :ghost) %>
  <% end %>
<% end %>
```

## Responsive Behavior

### Desktop (≥ 768px)

The sidebar operates in two states on desktop:

#### Expanded State (Default)
- Width: 256px (configurable via `expanded_width`)
- Shows icons and text for all items
- Displays badges and section titles
- Toggle button shows chevron (►) + "Minimize" text
- State persists in localStorage

#### Collapsed State
- Width: 64px (configurable via `collapsed_width`)
- Shows only icons (centered)
- Hides text, badges, and section titles
- Toggle button shows chevron (◄) only (centered)
- Smooth 300ms transition animation
- State persists in localStorage

### Mobile (< 768px)

The sidebar operates as a slide-out overlay on mobile:

#### Default State
- Sidebar is hidden (`display: none`)
- Hamburger menu (☰) automatically appears in top nav
- Content uses full viewport width

#### Open State
- Sidebar slides in from left as fixed overlay
- Full sidebar width (256px)
- Darkened backdrop overlay (50% opacity)
- Toggle button visible at bottom
- Tap outside or toggle button to close
- No content reflow or layout shift

## Examples

### Basic Setup

```erb
<%= render FlatPack::Navbar::Component.new do |navbar| %>
  <% navbar.sidebar do |sidebar| %>
    <% sidebar.item(text: "Dashboard", icon: "home", href: "/", active: true) %>
    <% sidebar.item(text: "Projects", icon: "folder", href: "/projects") %>
    <% sidebar.item(text: "Settings", icon: "settings", href: "/settings") %>
  <% end %>
  
  <% navbar.top_nav do |nav| %>
    <% nav.left_section do %>
      <span class="text-lg font-bold">MyApp</span>
    <% end %>
    
    <% nav.right_section do %>
      <%= render FlatPack::Button::Component.new(text: "Profile", style: :ghost) %>
    <% end %>
  <% end %>
  
  <%= yield %>
<% end %>
```

### With Badges and Sections

```erb
<% navbar.sidebar do |sidebar| %>
  <% sidebar.section(title: "Main") do |section| %>
    <% section.item(
      text: "Dashboard",
      icon: "layout-dashboard",
      href: dashboard_path,
      active: current_page?(dashboard_path)
    ) %>
    
    <% section.item(
      text: "Inbox",
      icon: "inbox",
      href: inbox_path,
      badge: @unread_count.to_s,
      badge_style: :danger
    ) %>
  <% end %>
  
  <% sidebar.section(title: "Projects", collapsible: true) do |section| %>
    <% @projects.each do |project| %>
      <% section.item(
        text: project.name,
        icon: "folder",
        href: project_path(project)
      ) %>
    <% end %>
  <% end %>
<% end %>
```

### Application Layout

Complete application layout example using the navbar in a Rails application:

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html class="h-full">
  <head>
    <title>MyApp</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="h-full bg-[var(--color-background)]">
    <%= render FlatPack::Navbar::Component.new do |navbar| %>
      <%= render "shared/sidebar", navbar: navbar %>
      <%= render "shared/top_nav", navbar: navbar %>
      
      <main class="flex-1 overflow-auto">
        <div class="container mx-auto p-6">
          <%= yield %>
        </div>
      </main>
    <% end %>
  </body>
</html>
```

```erb
<!-- app/views/shared/_sidebar.html.erb -->
<% navbar.sidebar do |sidebar| %>
  <% sidebar.section(title: "Main") do |section| %>
    <% section.item(
      text: "Dashboard",
      icon: "layout-dashboard",
      href: dashboard_path,
      active: current_page?(dashboard_path)
    ) %>
    
    <% section.item(
      text: "Inbox",
      icon: "inbox",
      href: inbox_path,
      badge: @unread_count.to_s,
      badge_style: :danger
    ) %>
  <% end %>
<% end %>
```

```erb
<!-- app/views/shared/_top_nav.html.erb -->
<% navbar.top_nav do |nav| %>
  <% nav.left_section do %>
    <span class="text-lg font-bold">MyApp</span>
  <% end %>
  
  <% nav.right_section do %>
    <%= render FlatPack::Button::Component.new(text: "Profile", style: :ghost) %>
  <% end %>
<% end %>
```

### Custom Dimensions

```erb
<%= render FlatPack::Navbar::Component.new do |navbar| %>
  <% navbar.sidebar(
    expanded_width: "320px",
    collapsed_width: "80px"
  ) do |sidebar| %>
    <!-- Wider sidebar -->
  <% end %>
  
  <% navbar.top_nav(height: "72px") do |nav| %>
    <!-- Taller top nav -->
  <% end %>
  
  <%= yield %>
<% end %>
```

## System Arguments

All navbar components accept system arguments for additional customization.

### Custom Classes

```erb
<%= render FlatPack::Navbar::Component.new(class: "custom-wrapper") do |navbar| %>
  <!-- Content -->
<% end %>
```

### Data Attributes

```erb
<% sidebar.item(
  text: "Track Click",
  icon: "mouse-pointer",
  href: "/analytics",
  data: {
    controller: "tracking",
    action: "click->tracking#logClick"
  }
) %>
```

### ARIA Attributes

```erb
<% sidebar.item(
  text: "Settings",
  icon: "settings",
  href: "/settings",
  aria: {
    label: "Application settings",
    describedby: "settings-help"
  }
) %>
```

## JavaScript Controllers

The Navbar component uses Stimulus controllers for interactive behavior.

### navbar_controller.js

Main controller that manages sidebar state, responsive behavior, and state persistence.

**Targets:**
- `sidebar` - The sidebar element
- `toggleButton` - Bottom toggle button
- `toggleIcon` - Chevron icon in toggle
- `toggleText` - "Minimize" text in toggle
- `itemText` - All navigation item text elements
- `itemIcon` - All icon containers
- `itemBadge` - All badge elements
- `sectionTitle` - All section title elements

**Values:**
- `expandedWidth: String` - Full width (default: "256px")
- `collapsedWidth: String` - Icon-only width (default: "64px")
- `collapsed: Boolean` - Current collapsed state (default: false)

**Methods:**
- `connect()` - Initialize controller and load saved state
- `disconnect()` - Cleanup event listeners and overlay
- `toggle()` - Unified toggle that delegates to desktop/mobile
- `toggleDesktop()` - Handle desktop collapse/expand
- `toggleMobile()` - Handle mobile show/hide
- `openMobile()` - Open sidebar as overlay on mobile
- `closeMobile()` - Close mobile sidebar overlay
- `applyDesktopState()` - Apply visual changes for desktop state
- `handleResize()` - Handle window resize events
- `createOverlay()` - Create darkened backdrop for mobile
- `removeOverlay()` - Remove mobile backdrop
- `saveState()` - Persist state to localStorage
- `loadState()` - Retrieve state from localStorage

### sidebar_controller.js

Secondary controller for collapsible section functionality.

**Methods:**
- `toggleSection(event)` - Toggle section visibility and rotate chevron icon

## Styling

The Navbar component uses Tailwind CSS with CSS variable theming for full customization.

### CSS Variables

Customize colors by overriding theme variables:

```css
@theme {
  /* Background and foreground */
  --color-background: oklch(1.0 0 0);
  --color-foreground: oklch(0.2 0.01 250);
  
  /* Borders and dividers */
  --color-border: oklch(0.9 0.01 250);
  
  /* Interactive states */
  --color-muted: oklch(0.96 0.01 250);
  --color-muted-foreground: oklch(0.55 0.015 250);
  
  /* Active/primary state */
  --color-primary: oklch(0.55 0.25 270);
  --color-primary-text: oklch(1.0 0 0);
  
  /* Badge colors */
  --color-secondary: oklch(0.85 0.02 250);
  --color-success: oklch(0.65 0.17 145);
  --color-warning: oklch(0.75 0.15 85);
  --color-danger: oklch(0.60 0.22 25);
}
```

### Transitions

All animations use 300ms duration for consistent feel:
- Sidebar width changes: `transition-all duration-300`
- Slide animations: `transition-transform duration-300`
- Backdrop fade: `opacity 300ms`
- Icon rotations: `transition-transform duration-200`

## Accessibility

The Navbar component follows accessibility best practices.

### Semantic HTML
- `<aside>` element for sidebar landmark
- `<nav>` elements for navigation regions
- `<button>` elements with proper `type` attributes
- `<ul>` and `<li>` for navigation item lists
- Proper heading hierarchy with section titles

### ARIA Labels
- Hamburger menu includes `aria-label="Toggle navigation"`
- All interactive elements have accessible text or labels
- Icon-only states maintain accessibility through proper ARIA attributes

### Keyboard Navigation
- All interactive elements are keyboard accessible
- Tab order follows logical visual flow
- Focus indicators visible on all focusable elements
- Enter/Space activate buttons and links
- No keyboard traps

### Screen Readers
- Semantic structure aids screen reader navigation
- State changes announced appropriately
- Text alternatives provided for icons
- Collapsible sections indicate expanded/collapsed state

## Testing

The Navbar component suite includes 55 comprehensive tests covering all functionality.

### Test Coverage

- Navbar wrapper rendering and structure
- Sidebar desktop state management
- Sidebar mobile overlay behavior
- Toggle button functionality
- Item rendering with all props (icons, badges, active states)
- Section collapsible behavior
- Top nav sections and hamburger menu
- Stimulus controller integration
- Responsive breakpoint behavior
- State persistence (localStorage)
- Accessibility compliance
- Edge cases and validation

### Running Tests

```bash
# Run all navbar component tests
bundle exec rails test test/components/flat_pack/navbar/component_test.rb

# Run tests for specific components
bundle exec rails test test/components/flat_pack/navbar/sidebar_component_test.rb
bundle exec rails test test/components/flat_pack/navbar/sidebar_item_component_test.rb
bundle exec rails test test/components/flat_pack/navbar/sidebar_section_component_test.rb
bundle exec rails test test/components/flat_pack/navbar/top_nav_component_test.rb
```

### Example Test

```ruby
def test_renders_sidebar_item_with_badge
  render_inline FlatPack::Navbar::SidebarItemComponent.new(
    text: "Messages",
    icon: "mail",
    href: "/messages",
    badge: "5",
    badge_style: :danger
  )
  
  assert_selector "a[href='/messages']"
  assert_selector "span", text: "Messages"
  assert_selector "span", text: "5"
end
```

## API Reference

### FlatPack::Navbar::Component

```ruby
FlatPack::Navbar::Component.new(
  **system_arguments  # Optional: class, data, aria, id, etc.
)

# Renders:
navbar.sidebar(collapsed:, expanded_width:, collapsed_width:)
navbar.top_nav(height:)
```

### FlatPack::Navbar::SidebarComponent

```ruby
sidebar = SidebarComponent.new(
  collapsed: Boolean,         # Optional, default: false
  expanded_width: String,     # Optional, default: "256px"
  collapsed_width: String,    # Optional, default: "64px"
  **system_arguments         # Optional
)

# Renders many:
sidebar.item(...)        # SidebarItemComponent
sidebar.section(...)     # SidebarSectionComponent
```

### FlatPack::Navbar::SidebarItemComponent

```ruby
SidebarItemComponent.new(
  text: String,              # Required
  href: String,              # Optional, default: nil (renders as button if omitted)
  icon: String,              # Optional, default: nil (Lucide icon name)
  active: Boolean,           # Optional, default: false
  badge: String/Integer,     # Optional, default: nil
  badge_style: Symbol,       # Optional, default: :primary
  **system_arguments        # Optional
)

# badge_style options:
# :primary, :secondary, :success, :warning, :danger
```

### FlatPack::Navbar::SidebarSectionComponent

```ruby
section = SidebarSectionComponent.new(
  title: String,             # Optional, default: nil
  collapsible: Boolean,      # Optional, default: false
  collapsed: Boolean,        # Optional, default: false
  **system_arguments        # Optional
)

# Renders many:
section.item(...)       # SidebarItemComponent
```

### FlatPack::Navbar::TopNavComponent

```ruby
top_nav = TopNavComponent.new(
  height: String,            # Optional, default: "64px"
  **system_arguments        # Optional
)

# Renders one:
top_nav.left_section { content }    # Left section (+ hamburger menu on mobile)
top_nav.center_section { content }  # Center section
top_nav.right_section { content }   # Right section
```

## Performance

- **Minimal JavaScript**: < 6KB minified for both controllers
- **CSS Transitions**: Hardware-accelerated animations
- **LocalStorage**: Efficient state persistence (no server calls)
- **Event Delegation**: Optimized event listeners
- **Lazy Rendering**: Only visible content is interactive
- **No Layout Thrashing**: Batch DOM reads/writes

## Browser Support

- Modern browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- Mobile browsers (iOS Safari 14+, Chrome Android 90+)
- Requires JavaScript enabled for interactive features
- Graceful degradation for non-JS environments
- CSS transitions required for animations

## Best Practices

1. **Always include both sidebar and top nav** for consistent layout structure
2. **Use semantic icon names** that clearly represent the navigation destination
3. **Limit primary navigation** to 7-10 items for optimal usability
4. **Group related items** using sections for better organization
5. **Leverage badge notifications** for important updates (unread counts, alerts)
6. **Test responsive behavior** at the 768px breakpoint
7. **Use active state consistently** to highlight current page/section
8. **Consider collapsible sections** for lengthy navigation lists
9. **Provide meaningful ARIA labels** for icon-only states
10. **Keep top nav height consistent** with your design system

## Features

- ✅ **Collapsible sidebar** with persistent state
- ✅ **Responsive design** with mobile overlay
- ✅ **Icon support** via Lucide icons
- ✅ **Badge notifications** with 5 color variants
- ✅ **Section grouping** with optional collapse
- ✅ **Active state** highlighting
- ✅ **Three-section top nav** (left, center, right)
- ✅ **Automatic hamburger menu** on mobile
- ✅ **LocalStorage persistence** for user preferences
- ✅ **Smooth animations** on all interactions
- ✅ **Full accessibility** support
- ✅ **Dark mode** ready via CSS variables

## Known Limitations

- Requires JavaScript for toggle and collapse functionality
- State persistence limited to same browser/device (localStorage)
- Overlay backdrop requires CSS transparency support
- Animations require CSS transition support
- Mobile overlay requires viewport units (vh) support

## Related Components

- [Button Component](button.md) - For actions in top nav and sidebar
- [Badge Component](badge.md) - Notification indicators (used in sidebar items)
- [Card Component](card.md) - Structure main content areas
- [Alert Component](alert.md) - Display user notifications and messages
- [Table Component](table.md) - Data tables for main content

## Live Examples

The dummy app includes comprehensive examples at `/demo/navbar`:
- Complete application layout setup
- Sidebar with badges and sections
- Collapsible navigation groups
- Active state management
- Mobile responsive behavior
- Custom dimensions and styling

## Next Steps

- [Installation Guide](../installation.md) - Setup instructions
- [Theming Guide](../theming.md) - Customize colors and styles
- [Dark Mode](../dark_mode.md) - Dark mode implementation
- [Architecture Overview](../architecture/engine.md) - Component architecture

## Support

For issues, questions, or contributions:
- **GitHub**: [bowerbird-app/flatpack](https://github.com/bowerbird-app/flatpack)
- **Issues**: [Report a bug](https://github.com/bowerbird-app/flatpack/issues)
- **Discussions**: [Ask questions](https://github.com/bowerbird-app/flatpack/discussions)
