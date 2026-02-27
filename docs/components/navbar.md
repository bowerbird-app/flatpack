# Navbar

## Purpose
Provide an application shell that composes a collapsible sidebar with a top navigation bar.

## When to use
Use Navbar for app layouts that need persistent primary navigation and responsive mobile/desktop behavior.

## Class
- Primary: `FlatPack::Navbar::Component`
- Related classes: `FlatPack::Navbar::Sidebar::Component`, `FlatPack::Navbar::SidebarItem::Component`, `FlatPack::Navbar::SidebarSection::Component`, `FlatPack::Navbar::TopNav::Component`

## Props
### `FlatPack::Navbar::Component`
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### `FlatPack::Navbar::Sidebar::Component`
| name | type | default | required | description |
|---|---|---|---|---|
| `collapsed` | Boolean | `false` | no | Initial desktop collapsed state. |
| `expanded_width` | String | `"256px"` | no | Sidebar width when expanded. |
| `collapsed_width` | String | `"64px"` | no | Sidebar width when collapsed. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for `<aside>`. |

### `FlatPack::Navbar::SidebarItem::Component`
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Item label text. |
| `href` | String | `nil` | no | Link URL; if omitted, item renders as a button. |
| `icon` | String/Symbol | `nil` | no | Icon name for `FlatPack::Shared::IconComponent`. |
| `active` | Boolean | `false` | no | Marks the item as active. |
| `badge` | String/Integer | `nil` | no | Optional badge content. |
| `badge_style` | Symbol | `:primary` | no | Badge style: `:primary`, `:secondary`, `:success`, `:warning`, `:danger`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for item element. |

### `FlatPack::Navbar::SidebarSection::Component`
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | no | Section heading text. |
| `collapsible` | Boolean | `false` | no | Enables section collapse toggle. |
| `collapsed` | Boolean | `false` | no | Initial collapsed state when `collapsible` is true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for section wrapper. |

### `FlatPack::Navbar::TopNav::Component`
| name | type | default | required | description |
|---|---|---|---|---|
| `height` | String | `"64px"` | no | Top nav height style value. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for top nav element. |

## Slots
### `FlatPack::Navbar::Component`
| name | type | required | description |
|---|---|---|---|
| `sidebar` | slot | no | Adds `FlatPack::Navbar::Sidebar::Component`. |
| `top_nav` | slot | no | Adds `FlatPack::Navbar::TopNav::Component`. |
| block content | block | no | Main page content rendered inside `<main>`. |

### `FlatPack::Navbar::Sidebar::Component`
| name | type | required | description |
|---|---|---|---|
| `item` | slot | no | Adds direct `SidebarItem` entries. |
| `section` | slot | no | Adds grouped `SidebarSection` entries. |

### `FlatPack::Navbar::SidebarSection::Component`
| name | type | required | description |
|---|---|---|---|
| `item` | slot | no | Adds section `SidebarItem` entries. |

### `FlatPack::Navbar::TopNav::Component`
| name | type | required | description |
|---|---|---|---|
| `left_section` | slot | no | Left-side content (hamburger + custom content). |
| `center_section` | slot | no | Center content area. |
| `right_section` | slot | no | Right-side content area. |

## Variants
- Sidebar width/state variants via `expanded_width`, `collapsed_width`, and `collapsed`.
- Sidebar section variants via `collapsible` and `collapsed`.
- Sidebar badge style variants: `:primary`, `:secondary`, `:success`, `:warning`, `:danger`.

## Example
```erb
<%= render FlatPack::Navbar::Component.new(class: "h-screen") do |navbar| %>
  <% navbar.sidebar do |sidebar| %>
    <% sidebar.item(text: "Dashboard", icon: :home, href: "/", active: true) %>

    <% sidebar.section(title: "Workspaces", collapsible: true) do |section| %>
      <% section.item(text: "Design", icon: :folder, href: "/design") %>
      <% section.item(text: "Product", icon: :folder, href: "/product", badge: 3, badge_style: :danger) %>
    <% end %>
  <% end %>

  <% navbar.top_nav do |top_nav| %>
    <% top_nav.left_section do %>
      <span class="text-lg font-semibold">FlatPack Demo</span>
    <% end %>

    <% top_nav.right_section do %>
      <%= render FlatPack::Button::Component.new(text: "New", icon: :plus, size: :sm) %>
    <% end %>
  <% end %>

  <section class="p-6">
    Main content
  </section>
<% end %>
```

## Accessibility
- Mobile toggle button has `aria-label="Toggle navigation"`.
- Sidebar items can be links or buttons; ensure each item text is descriptive.
- Preserve keyboard focus visibility when customizing styles via `system_arguments`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--navbar` (sidebar collapse/mobile overlay behavior).
- Stimulus controller: `flat-pack--sidebar` (section collapse behavior).
