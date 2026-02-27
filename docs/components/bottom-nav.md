# Bottom Nav

## Purpose
Render a fixed mobile-first bottom navigation bar with icon+label items.

## When to use
Use Bottom Nav for primary navigation on small screens where sidebar/top-nav patterns are not ideal.

## Class
- Primary: `FlatPack::BottomNav::Component`
- Related classes: `FlatPack::BottomNav::Item::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer `<nav>` element. |

Related item props (`FlatPack::BottomNav::Item::Component`):

| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String | none | yes | Item label text shown under icon. |
| `href` | String | none | yes | Link URL. Sanitized and validated (`http`, `https`, `mailto`, `tel`, or relative URL). |
| `icon` | Symbol/String | `nil` | no | Icon name for `FlatPack::Shared::IconComponent`. |
| `active` | Boolean | `false` | no | Marks item as active and sets `aria-current="page"`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes forwarded to the item link element. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `item` | slot (`with_item`) | no | Adds one `FlatPack::BottomNav::Item::Component` entry. |

## Variants
None.

## Example
```erb
<%= render FlatPack::BottomNav::Component.new do |nav| %>
  <% nav.item(label: "Home", href: "/", icon: :home, active: true) %>
  <% nav.item(label: "Search", href: "/search", icon: :search) %>
  <% nav.item(label: "Alerts", href: "/alerts", icon: :bell) %>
  <% nav.item(label: "Profile", href: "/profile", icon: :user) %>
<% end %>
```

## Accessibility
- Renders semantic `<nav>` with `aria-label="Bottom navigation"`.
- Active item sets `aria-current="page"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::BottomNav::Item::Component` for links/items.
