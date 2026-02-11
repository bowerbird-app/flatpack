# Layout Component

A modern sidebar-first layout system with collapsible navigation and flexible top bar for Rails applications.

## Overview

The Layout Component provides a complete page layout solution with:
- **Collapsible sidebar** navigation with desktop/mobile responsive behavior
- **Flexible top navigation** bar with three customizable sections
- **Persistent state** using localStorage
- **Smooth animations** and transitions
- **Accessibility compliant** with semantic HTML and ARIA labels

## Demo

Visit `/demo/layout` in the dummy app to see the component in action.

## Components

### 1. Layout::Component

Main wrapper component that coordinates sidebar and top navigation.

```erb
<%= render FlatPack::Layout::Component.new do |layout| %>
  <% layout.with_sidebar do |sidebar| %>
    <!-- Sidebar items -->
  <% end %>
  
  <% layout.with_top_nav do |nav| %>
    <!-- Top nav content -->
  <% end %>
  
  <!-- Main content -->
  <%= yield %>
<% end %>
```

**Options:**
- `class` - Additional CSS classes for the wrapper
- All standard system arguments (data, aria, etc.)

### 2. Sidebar Component

Full-height navigation sidebar with bottom toggle button.

```erb
<% layout.with_sidebar do |sidebar| %>
  <% sidebar.with_item(text: "Dashboard", icon: "home", href: "/") %>
  <% sidebar.with_section(title: "Projects") do |section| %>
    <% section.with_item(text: "Active", href: "/projects") %>
  <% end %>
<% end %>
```

**Options:**
- `collapsed: false` - Initial collapsed state (desktop only)
- `expanded_width: "256px"` - Full width with text visible
- `collapsed_width: "64px"` - Icon-only width

### 3. SidebarItem Component

Individual navigation items with icons, text, and optional badges.

```erb
<% sidebar.with_item(
  text: "Messages",
  icon: "mail",
  href: "/messages",
  active: true,
  badge: "5",
  badge_style: :danger
) %>
```

**Options:**
- `text:` (required) - Display text
- `href: nil` - Link URL (renders as button if omitted)
- `icon: nil` - Lucide icon name
- `active: false` - Highlight as current page
- `badge: nil` - Notification count or text
- `badge_style: :primary` - Badge color (`:primary`, `:secondary`, `:success`, `:warning`, `:danger`)

### 4. SidebarSection Component

Groups related navigation items with optional collapse functionality.

```erb
<% sidebar.with_section(
  title: "Projects",
  collapsible: true,
  collapsed: false
) do |section| %>
  <% section.with_item(text: "Project 1", href: "/projects/1") %>
  <% section.with_item(text: "Project 2", href: "/projects/2") %>
<% end %>
```

**Options:**
- `title: nil` - Section header text
- `collapsible: false` - Allow collapse/expand
- `collapsed: false` - Initial collapsed state

### 5. TopNav Component

Horizontal navigation bar with three customizable sections.

```erb
<% layout.with_top_nav do |nav| %>
  <% nav.with_left do %>
    <span class="text-xl font-bold">MyApp</span>
  <% end %>
  
  <% nav.with_center do %>
    <%= search_field_tag :q, nil, placeholder: "Search..." %>
  <% end %>
  
  <% nav.with_right do %>
    <%= render FlatPack::Button::Component.new(text: "Profile") %>
  <% end %>
<% end %>
```

**Options:**
- `height: "64px"` - Navigation bar height

## Desktop Behavior

### Expanded State (Default)
- Width: 256px
- Shows icon + text for all items
- Shows badges and section titles
- Bottom toggle shows chevron right (►) + "Minimize" text
- Content area adjusts to sidebar width

### Collapsed State
- Width: 64px
- Shows icons only (centered)
- Hides text, badges, and section titles
- Bottom toggle shows chevron left (◄) only (centered)
- Smooth 300ms transition

### Toggle Button
- Located at bottom of sidebar
- Clear visual feedback for each state
- Chevron rotates 180° on state change
- Persists state in localStorage

## Mobile Behavior

### Default State
- Sidebar is hidden (display: none)
- Hamburger menu (☰) visible in top nav left section
- Content uses full width

### Open State
- Sidebar slides in from left as fixed overlay
- Full height (256px width)
- Darkened backdrop (50% black opacity)
- Bottom toggle button visible
- Tap outside or toggle button to close
- No content shift or layout jump

## Responsive Breakpoint

- **Mobile:** < 768px (md breakpoint)
- **Desktop:** ≥ 768px

## Usage Examples

### Basic Layout

```erb
<%= render FlatPack::Layout::Component.new do |layout| %>
  <% layout.with_sidebar do |sidebar| %>
    <% sidebar.with_item(text: "Dashboard", icon: "home", href: "/", active: true) %>
    <% sidebar.with_item(text: "Projects", icon: "folder", href: "/projects") %>
    <% sidebar.with_item(text: "Settings", icon: "settings", href: "/settings") %>
  <% end %>
  
  <% layout.with_top_nav do |nav| %>
    <% nav.with_left do %>
      <span class="text-lg font-bold">MyApp</span>
    <% end %>
    
    <% nav.with_right do %>
      <%= render FlatPack::Button::Component.new(text: "Profile", style: :ghost) %>
    <% end %>
  <% end %>
  
  <%= yield %>
<% end %>
```

### With Badges and Sections

```erb
<% layout.with_sidebar do |sidebar| %>
  <% sidebar.with_section(title: "Main") do |section| %>
    <% section.with_item(
      text: "Dashboard",
      icon: "layout-dashboard",
      href: dashboard_path,
      active: current_page?(dashboard_path)
    ) %>
    
    <% section.with_item(
      text: "Inbox",
      icon: "inbox",
      href: inbox_path,
      badge: @unread_count.to_s,
      badge_style: :danger
    ) %>
  <% end %>
  
  <% sidebar.with_section(title: "Projects", collapsible: true) do |section| %>
    <% @projects.each do |project| %>
      <% section.with_item(
        text: project.name,
        icon: "folder",
        href: project_path(project)
      ) %>
    <% end %>
  <% end %>
<% end %>
```

### Application Layout

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html class="h-full">
  <head>
    <title>MyApp</title>
    <%= csrf_meta_tags %>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="h-full bg-[var(--color-background)]">
    <%= render FlatPack::Layout::Component.new do |layout| %>
      <%= render "shared/sidebar", layout: layout %>
      <%= render "shared/top_nav", layout: layout %>
      
      <main class="flex-1 overflow-auto">
        <div class="container mx-auto p-6">
          <%= yield %>
        </div>
      </main>
    <% end %>
  </body>
</html>
```

## JavaScript Controllers

### layout_controller.js

Manages sidebar toggle, desktop/mobile behavior, and state persistence.

**Targets:**
- `sidebar` - Sidebar element
- `toggleButton` - Bottom toggle button
- `toggleIcon` - Chevron icon
- `toggleText` - "Minimize" text
- `itemText` - All item text elements
- `itemIcon` - All item icon containers
- `itemBadge` - All badge containers
- `sectionTitle` - All section titles

**Values:**
- `expandedWidth` - Full width (default: "256px")
- `collapsedWidth` - Icon-only width (default: "64px")
- `collapsed` - Current state (default: false)

**Methods:**
- `toggle()` - Unified toggle for desktop/mobile
- `toggleDesktop()` - Desktop collapse/expand
- `toggleMobile()` - Mobile show/hide with overlay
- `applyDesktopState()` - Apply visual changes
- `saveState()` / `loadState()` - LocalStorage persistence

### sidebar_controller.js

Handles collapsible sections within the sidebar.

**Method:**
- `toggleSection(event)` - Toggle section visibility and chevron rotation

## Accessibility

### Semantic HTML
- `<aside>` for sidebar
- `<nav>` for navigation elements
- `<button>` with proper `type` attributes
- `<ul>` and `<li>` for item lists

### ARIA Labels
- Hamburger menu: `aria-label="Toggle navigation"`
- All buttons have appropriate text or icons

### Keyboard Navigation
- All interactive elements are keyboard accessible
- Focus indicators on all focusable elements
- Tab order follows logical structure

### Screen Readers
- Semantic structure aids navigation
- Text alternatives provided
- State changes announced

## Styling

The component uses Tailwind CSS with CSS variable theming for:
- Colors (background, foreground, borders, primary, etc.)
- Shadows
- Border radius
- Transitions

All styling is responsive and adapts to:
- Light/dark mode (via CSS variables)
- Different viewport sizes
- User preferences

## Testing

The component includes 55 comprehensive tests covering:
- Layout rendering and structure
- Sidebar desktop/mobile behavior
- Toggle button functionality
- Item rendering with icons, badges, active states
- Section collapsible behavior
- Top nav sections and hamburger menu
- Stimulus controller integration
- Accessibility compliance
- Edge cases and validation

Run tests:
```bash
bundle exec rails test test/components/flat_pack/layout/component_test.rb
```

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Android)
- Requires JavaScript enabled for interactive features
- Graceful degradation for non-JS environments

## Performance

- Minimal JavaScript (< 6KB minified)
- CSS transitions for smooth animations
- LocalStorage for state persistence (no server calls)
- Efficient event listeners (delegated where possible)

## Customization

### Custom Widths

```erb
<% layout.with_sidebar(
  expanded_width: "320px",
  collapsed_width: "80px"
) do |sidebar| %>
  <!-- Items -->
<% end %>
```

### Custom Top Nav Height

```erb
<% layout.with_top_nav(height: "72px") do |nav| %>
  <!-- Content -->
<% end %>
```

### Custom Icons

Use any Lucide icon name:
```erb
<% sidebar.with_item(text: "Custom", icon: "zap", href: "#") %>
```

### Custom Badge Styles

```erb
<% sidebar.with_item(
  text: "Alerts",
  badge: "!",
  badge_style: :warning
) %>
```

## Tips & Best Practices

1. **Always include both sidebar and top nav** for consistent layout
2. **Use semantic icon names** that match your content
3. **Keep sidebar items focused** - limit to 7-10 main items
4. **Use sections to group** related navigation items
5. **Leverage badges** for important notifications
6. **Test mobile behavior** by resizing your browser
7. **Use active state** to highlight current page
8. **Consider collapsible sections** for long navigation lists

## Known Limitations

- Requires JavaScript for toggle functionality
- State persistence limited to same browser/device
- Overlay backdrop requires transparency support
- Animations require CSS transitions support

## Related Components

- [Button Component](button.md) - Use in top nav
- [Badge Component](badge.md) - Notification indicators
- [Card Component](card.md) - Structure main content
- [Alert Component](alert.md) - User notifications

## Support

For issues, questions, or contributions, visit the [GitHub repository](https://github.com/bowerbird-app/flatpack).
