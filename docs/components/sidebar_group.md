# Sidebar Group Component

## Purpose
Render a collapsible group of sidebar items with persisted open/closed state.

## When to use
Use Sidebar Group inside sidebar navigation when related links should be grouped under a toggleable header.

## Class
- Primary: `FlatPack::Sidebar::Group::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `label` | String | none | Yes | Group header label text. |
| `icon` | Symbol or nil | `nil` | No | Optional leading icon in group header. |
| `default_open` | Boolean | `false` | No | Initial open state when no persisted state exists. |
| `collapsed` | Boolean | `false` | No | Collapsed sidebar mode hint; hides label and chevron visuals. |
| `group_id` | String or nil | `nil` | No | Persistence id. Defaults to parameterized `label` (fallback `"group"`). |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into group wrapper. |

## Slots

| name | type | required | description |
|------|------|----------|-------------|
| `items` | block slot | No | Collapsible panel content, usually `FlatPack::Sidebar::Item::Component` entries. |

## Variants

| variant | description |
|---------|-------------|
| `default_open: true` | Group starts open unless persisted state overrides it. |
| `collapsed: true` | Label becomes screen-reader-only and chevron hides for icon-only sidebar mode. |

## Example

```erb
<%= render FlatPack::Sidebar::Group::Component.new(
  label: "More",
  icon: :ellipsis_vertical,
  default_open: true
) do |group| %>
  <% group.items do %>
    <%= render FlatPack::Sidebar::Item::Component.new(label: "Settings", href: "/settings", icon: :cog_6_tooth) %>
    <%= render FlatPack::Sidebar::Item::Component.new(label: "Help", href: "/help", icon: :question_mark_circle) %>
  <% end %>
<% end %>
```

## Accessibility
Header uses a native `button` with `aria-expanded` and `aria-controls` tied to the panel id. Collapsed mode keeps label text available to assistive tech via `sr-only`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Interactive open/close and persisted state behavior requires Stimulus controller `flat-pack--sidebar-group`.
