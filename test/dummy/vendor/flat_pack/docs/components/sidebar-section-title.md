# Sidebar Section Title

## Purpose
Render a collapsible-aware section label inside a sidebar nav, with truncation and a tooltip when minimized.

## When to use
Use inside `FlatPack::Sidebar::Component` items area to group navigation links under a heading. Works in both static collapsed sidebars and JS-controlled `flat-pack--sidebar-layout` sidebars.

## Class
- Primary: `FlatPack::Sidebar::SectionTitle::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `label` | String | — | Yes | Section heading text displayed and used as tooltip content. |
| `collapsed` | Boolean | `false` | No | Renders in compact, centered mode (`px-1`). Use for static collapsed demos; the `flat-pack--sidebar-layout` controller toggles this dynamically. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the wrapper `<div>`. |

## Slots

None

## Variants

| variant | description |
|---------|-------------|
| `collapsed: false` (default) | Full-width label with `px-4` padding. |
| `collapsed: true` | Compact `px-1` padding, label centered and truncated with ellipsis. Tooltip shows the full label on hover. |

## Example

```erb
<nav class="py-4 space-y-1">
  <%= render FlatPack::Sidebar::SectionTitle::Component.new(label: "Getting Started") %>

  <%= render FlatPack::Sidebar::Item::Component.new(
    label: "Overview",
    href: "/overview",
    icon: :home,
    active: true
  ) %>

  <%= render FlatPack::Sidebar::Divider::Component.new %>

  <%= render FlatPack::Sidebar::SectionTitle::Component.new(label: "Settings") %>

  <%= render FlatPack::Sidebar::Item::Component.new(
    label: "Team",
    href: "/settings/team",
    icon: :users
  ) %>
</nav>
```

### Static collapsed (icon-only) demo

```erb
<%= render FlatPack::Sidebar::SectionTitle::Component.new(label: "Getting Started", collapsed: true) %>
```

### Dynamic (JS-controlled) sidebar

No `collapsed:` argument needed — the `flat-pack--sidebar-layout` controller targets elements with `data-flat-pack-sidebar-section-title="true"` and toggles `px-1`/`px-4` automatically on collapse/expand.

## Accessibility
- The wrapper has `data-flat-pack--tooltip-collapsed-only-value="true"`, so the tooltip only activates when the sidebar is collapsed.
- The label text is always in the DOM (not `sr-only`), providing readable text in both states.
- When truncated in collapsed mode, the full label text is available via the tooltip.

## Dependencies
- `flat-pack--tooltip` Stimulus controller (tooltip on hover when collapsed).
- `flat-pack--sidebar-layout` Stimulus controller (automatic padding toggle during collapse).
