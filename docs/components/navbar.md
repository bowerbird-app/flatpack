# Navbar Component

A comprehensive navigation system implementing a ChatGPT-style layout with collapsible sidebar, transparent top navigation, and full dark mode support.

## Overview

The Navbar Component provides a production-ready navigation system with:
- **Responsive Design**: Adapts seamlessly between desktop and mobile viewports
- **Collapsible Sidebar**: Desktop sidebar toggles between 256px (expanded) and 64px (collapsed)
- **Mobile Overlay**: Sidebar slides from right as fixed overlay on mobile
- **Dark Mode**: Auto/light/dark modes with system preference detection
- **Nested Sections**: Organize navigation items into collapsible groups
- **Icon Support**: Lucide icons on all navigation items
- **Badge Support**: Notification counts with multiple color variants
- **Active States**: Highlight current page automatically
- **Accessibility**: Full ARIA support and keyboard navigation

## Component Architecture

```ruby
FlatPack::Navbar::Component
├── TopNavComponent           # Fixed top navigation bar
│   ├── actions (many)       # Buttons, links in top right
│   ├── theme_toggle (one)   # Dark mode toggle
│   └── center_content (one) # Custom center content
└── LeftNavComponent          # Collapsible sidebar
    ├── items (many)         # Direct navigation items
    ├── sections (many)      # Collapsible groups
    │   └── items (many)     # Items within sections
    └── footer (one)         # Footer content (e.g., user profile)
```

## Basic Usage

### Simple ChatGPT-Style Layout

```erb
<%= render FlatPack::Navbar::Component.new(dark_mode: :auto) do |navbar| %>
  <%# Top Navigation %>
  <% navbar.top_nav(
    transparent: true,
    blur: true,
    logo_text: "ChatGPT"
  ) do |top| %>
    <% top.action do %>
      <%= render FlatPack::Button::Component.new(
        text: "Upgrade",
        style: :primary,
        size: :sm
      ) %>
    <% end %>
  <% end %>
  
  <%# Left Sidebar %>
  <% navbar.left_nav(collapsible: true) do |left| %>
    <% left.item(
      text: "New chat",
      icon: "plus",
      href: new_chat_path
    ) %>
    
    <% left.section(title: "Recent", collapsible: true) do |section| %>
      <% @chats.each do |chat| %>
        <% section.item(
          text: chat.title,
          href: chat_path(chat),
          active: current_page?(chat_path(chat))
        ) %>
      <% end %>
    <% end %>
  <% end %>
  
  <%# Main Content Area %>
  <div class="p-6">
    <%= yield %>
  </div>
<% end %>
```

## Main Navbar Component

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `left_nav_collapsed` | Boolean | `false` | Initial desktop sidebar state |
| `left_nav_width` | String | `"256px"` | Expanded sidebar width |
| `left_nav_collapsed_width` | String | `"64px"` | Collapsed sidebar width |
| `top_nav_height` | String | `"64px"` | Top navigation height |
| `dark_mode` | Symbol | `:auto` | Theme mode (`:auto`, `:light`, `:dark`) |

### Example with Custom Dimensions

```erb
<%= render FlatPack::Navbar::Component.new(
  left_nav_collapsed: true,
  left_nav_width: "320px",
  left_nav_collapsed_width: "80px",
  top_nav_height: "72px",
  dark_mode: :dark
) do |navbar| %>
  <%# ... %>
<% end %>
```

## Top Nav Component

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `transparent` | Boolean | `true` | Transparent background |
| `blur` | Boolean | `true` | Backdrop blur effect |
| `border_bottom` | Boolean | `true` | Bottom border |
| `logo_url` | String | `nil` | Logo link destination |
| `logo_text` | String | `nil` | Logo text content |
| `show_menu_toggle` | Boolean | `true` | Show hamburger menu (mobile) |
| `show_theme_toggle` | Boolean | `true` | Show theme toggle button |
| `height` | String | `"64px"` | Navigation bar height |

### Examples

#### With Logo and Actions

```erb
<% navbar.top_nav(
  logo_text: "My App",
  logo_url: root_path,
  transparent: true,
  blur: true
) do |top| %>
  <%# Center Content %>
  <% top.center_content do %>
    <div class="text-lg font-semibold">Dashboard</div>
  <% end %>
  
  <%# Right Actions %>
  <% top.action do %>
    <%= render FlatPack::Button::Component.new(
      text: "Notifications",
      icon: "bell",
      style: :ghost
    ) %>
  <% end %>
  
  <% top.action do %>
    <%= render FlatPack::Button::Component.new(
      text: "Profile",
      icon: "user",
      style: :ghost
    ) %>
  <% end %>
<% end %>
```

#### Solid Background Without Blur

```erb
<% navbar.top_nav(
  transparent: false,
  blur: false,
  border_bottom: true
) do |top| %>
  <%# ... %>
<% end %>
```

## Left Nav Component

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `collapsible` | Boolean | `true` | Enable collapse/expand |
| `show_toggle` | Boolean | `true` | Show toggle button |

### Mobile Behavior

On mobile (`< 768px`):
- Sidebar is **completely hidden** (display: none) - takes zero space
- Hamburger menu appears in top navigation
- Tapping hamburger slides sidebar from **RIGHT** as fixed overlay
- Darkened overlay (50% black) appears behind sidebar
- Tapping overlay or pressing Escape dismisses sidebar
- Smooth 300ms slide animation

### Desktop Behavior

On desktop (`≥ 768px`):
- Sidebar always visible in document flow
- Collapsible between 256px (expanded) and 64px (collapsed)
- Toggle button shows/hides text labels and badges
- Icons remain visible when collapsed
- State persists in localStorage

### Examples

#### With Sections and Items

```erb
<% navbar.with_left_nav do |left| %>
  <%# Direct Items %>
  <% left.item(
    text: "Dashboard",
    icon: "home",
    href: dashboard_path,
    active: current_page?(dashboard_path)
  ) %>
  
  <% left.item(
    text: "Messages",
    icon: "mail",
    href: messages_path,
    badge: "5",
    badge_style: :danger
  ) %>
  
  <%# Collapsible Section %>
  <% left.section(
    title: "Projects",
    collapsible: true,
    collapsed: false
  ) do |section| %>
    <% @projects.each do |project| %>
      <% section.item(
        text: project.name,
        icon: "folder",
        href: project_path(project)
      ) %>
    <% end %>
  <% end %>
  
  <%# Another Section %>
  <% left.section(title: "Settings") do |section| %>
    <% section.item(text: "Profile", icon: "user", href: profile_path) %>
    <% section.item(text: "Security", icon: "shield", href: security_path) %>
  <% end %>
  
  <%# Footer Content %>
  <% left.footer do %>
    <div class="p-4 border-t border-[var(--color-border)]">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 rounded-full bg-[var(--color-primary)]"></div>
        <div class="flex-1" data-navbar-target="collapseText">
          <div class="text-sm font-medium"><%= current_user.name %></div>
          <div class="text-xs text-[var(--color-muted-foreground)]">
            <%= current_user.email %>
          </div>
        </div>
      </div>
    </div>
  <% end %>
<% end %>
```

## Nav Item Component

Individual navigation links or buttons with icons, badges, and active states.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | String | **required** | Display text |
| `href` | String | `nil` | Link URL (renders `<button>` if nil) |
| `icon` | String | `nil` | Lucide icon name |
| `active` | Boolean | `false` | Highlight as current page |
| `badge` | String | `nil` | Badge text (e.g., notification count) |
| `badge_style` | Symbol | `:primary` | Badge color (`:primary`, `:success`, `:warning`, `:danger`) |

### Examples

#### Link with Icon

```erb
<% left.item(
  text: "Home",
  icon: "home",
  href: root_path
) %>
```

#### Active State

```erb
<% left.item(
  text: "Dashboard",
  icon: "layout-dashboard",
  href: dashboard_path,
  active: current_page?(dashboard_path)
) %>
```

#### With Badge

```erb
<% left.item(
  text: "Notifications",
  icon: "bell",
  href: notifications_path,
  badge: unread_notifications_count.to_s,
  badge_style: :danger
) %>
```

#### Button (No href)

```erb
<% left.item(
  text: "Logout",
  icon: "log-out"
) %>
```

## Nav Section Component

Group related navigation items with optional collapsible behavior.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | String | `nil` | Section header text |
| `collapsible` | Boolean | `false` | Allow collapse/expand |
| `collapsed` | Boolean | `false` | Initial collapsed state |

### Examples

#### Static Section

```erb
<% left.section(title: "Main") do |section| %>
  <% section.item(text: "Home", icon: "home", href: "/") %>
  <% section.item(text: "About", icon: "info", href: "/about") %>
<% end %>
```

#### Collapsible Section

```erb
<% left.section(
  title: "Projects",
  collapsible: true,
  collapsed: false
) do |section| %>
  <% @projects.each do |project| %>
    <% section.item(
      text: project.name,
      icon: "folder",
      href: project_path(project)
    ) %>
  <% end %>
<% end %>
```

## Theme Toggle Component

Button to switch between auto/light/dark modes.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | Symbol | `:md` | Button size (`:sm`, `:md`, `:lg`) |
| `show_label` | Boolean | `false` | Show "Theme" text label |

### Examples

#### Default (Icon Only)

```erb
<% top.with_theme_toggle %>
```

#### With Label

```erb
<% top.with_theme_toggle(size: :lg, show_label: true) %>
```

## Dark Mode

### Theme Modes

- **`:auto`** - Follows system preference (default)
- **`:light`** - Always light mode
- **`:dark`** - Always dark mode

### Behavior

1. **Initial Load**: Reads saved preference from `localStorage` or uses provided `dark_mode` parameter
2. **System Detection**: Monitors `prefers-color-scheme` media query
3. **Toggle**: Cycles through auto → light → dark → auto
4. **Persistence**: Saves preference to `localStorage` as `"flatpack-theme"`
5. **Apply**: Adds `.light` or `.dark` class to `<html>` element

### Prevent Flash of Wrong Theme

Add this inline script in your `<head>` tag before other styles:

```html
<script>
  (function() {
    const theme = localStorage.getItem('flatpack-theme') || 'auto';
    const isDark = theme === 'dark' || 
      (theme === 'auto' && matchMedia('(prefers-color-scheme: dark)').matches);
    
    document.documentElement.classList.add(isDark ? 'dark' : 'light');
  })();
</script>
```

### CSS Variables

All components use CSS variables that automatically adapt to dark mode:

```css
/* Light mode (default) */
:root {
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.20 0.01 250);
  --color-primary: oklch(0.52 0.26 250);
}

/* Dark mode */
.dark {
  --color-background: oklch(0.15 0.01 250);
  --color-foreground: oklch(0.95 0.01 250);
  --color-primary: oklch(0.62 0.22 250);
}
```

## State Persistence

The Navbar Component automatically persists state to `localStorage`:

- **`flatpack-navbar-collapsed`**: Desktop sidebar collapsed state (true/false)
- **`flatpack-theme`**: Theme preference ("auto", "light", or "dark")

## Responsive Breakpoints

- **Mobile**: `< 768px` - Sidebar hidden, hamburger visible
- **Desktop**: `≥ 768px` - Sidebar visible, hamburger hidden

## Accessibility

### ARIA Attributes

- `aria-label` on all icon-only buttons
- `aria-current="page"` on active navigation items
- `aria-expanded` on collapsible sections (via Stimulus)

### Keyboard Navigation

- **Tab**: Navigate between interactive elements
- **Enter/Space**: Activate buttons and links
- **Escape**: Close mobile sidebar
- **Arrow Keys**: Navigate through collapsible sections

### Screen Readers

- Descriptive labels on all interactive elements
- Semantic HTML (`<nav>`, `<aside>`, `<main>`)
- Proper heading hierarchy

## Stimulus Controllers

### Navbar Controller

**Data Attributes:**
- `data-controller="navbar"`
- `data-navbar-collapsed-value`: Initial collapsed state
- `data-navbar-width-value`: Expanded width
- `data-navbar-collapsed-width-value`: Collapsed width

**Targets:**
- `data-navbar-target="leftNav"`: Sidebar element
- `data-navbar-target="toggle"`: Toggle button
- `data-navbar-target="collapseText"`: Text/badges to hide when collapsed
- `data-navbar-target="chevron"`: Chevron icon to rotate

**Actions:**
- `data-action="click->navbar#toggleDesktop"`: Desktop collapse/expand
- `data-action="click->navbar#toggleMobile"`: Mobile open/close

### Theme Controller

**Data Attributes:**
- `data-controller="theme"`
- `data-theme-mode-value`: Initial theme mode

**Actions:**
- `data-action="click->theme#toggle"`: Toggle theme

### Left Nav Controller

**Data Attributes:**
- `data-controller="left-nav"` (on `<nav>` element)

**Actions:**
- `data-action="click->left-nav#toggleSection"`: Toggle section collapse

## Advanced Examples

### Multi-Level Navigation

```erb
<% navbar.with_left_nav do |left| %>
  <% left.section(title: "Administration", collapsible: true) do |admin| %>
    <% admin.item(text: "Users", icon: "users", href: admin_users_path) %>
    <% admin.item(text: "Roles", icon: "shield", href: admin_roles_path) %>
    <% admin.item(text: "Settings", icon: "settings", href: admin_settings_path) %>
  <% end %>
  
  <% left.section(title: "Content", collapsible: true) do |content| %>
    <% content.item(text: "Pages", icon: "file", href: pages_path) %>
    <% content.item(text: "Media", icon: "image", href: media_path) %>
  <% end %>
<% end %>
```

### Custom Footer with User Profile

```erb
<% left.footer do %>
  <div class="p-4 border-t border-[var(--color-border)]">
    <%= link_to profile_path, class: "flex items-center gap-3 p-2 rounded-lg hover:bg-[var(--color-muted)] transition-colors" do %>
      <%= image_tag current_user.avatar_url, class: "w-8 h-8 rounded-full" %>
      <div class="flex-1" data-navbar-target="collapseText">
        <div class="text-sm font-medium"><%= current_user.name %></div>
        <div class="text-xs text-[var(--color-muted-foreground)]">View profile</div>
      </div>
    <% end %>
  </div>
<% end %>
```

### Badge Variants

```erb
<% left.item(
  text: "Errors",
  icon: "alert-triangle",
  badge: "3",
  badge_style: :danger
) %>

<% left.item(
  text: "Warnings",
  icon: "alert-circle",
  badge: "12",
  badge_style: :warning
) %>

<% left.item(
  text: "Success",
  icon: "check-circle",
  badge: "5",
  badge_style: :success
) %>
```

## Best Practices

1. **Active States**: Always set `active: true` on the current page item
2. **Icons**: Use consistent icon style throughout navigation
3. **Badges**: Keep badge text short (preferably numbers)
4. **Sections**: Group related items into logical sections
5. **Mobile**: Test sidebar behavior on mobile viewports
6. **Dark Mode**: Use CSS variables for custom colors to ensure dark mode compatibility
7. **Performance**: Avoid excessive items (consider pagination for large lists)

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- iOS Safari 14+
- Android Chrome 90+

## See Also

- [Button Component](button.md)
- [Badge Component](badge.md)
- [Dark Mode Guide](../dark_mode.md)
- [Theming Guide](../theming.md)
