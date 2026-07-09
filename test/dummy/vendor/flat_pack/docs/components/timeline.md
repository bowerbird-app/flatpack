# Timeline

## Purpose
Render chronological items with markers and connecting lines for event history displays.

## When to use
Use Timeline for activity logs, milestones, process history, and progress narratives.

## Class
- Primary: `FlatPack::Timeline::Component`
- Related classes: `FlatPack::Timeline::Item`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for timeline wrapper (`role="list"`). |

`FlatPack::Timeline::Item` props:

| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Item title; blank values raise `ArgumentError`. |
| `timestamp` | String | `nil` | no | Optional timestamp text rendered in `<time>`. |
| `variant` | Symbol | `:default` | no | Marker style: `:default`, `:success`, `:warning`, `:danger`; invalid values raise `ArgumentError`. |
| `status` | Symbol | `nil` | no | Alias for variant; when provided, overrides `variant`. |
| `description` | String | `nil` | no | Plain text description rendered below header. |
| `icon` | String | `nil` | no | Optional SVG string (`<svg...`) for marker icon; otherwise dot marker is used. |
| `last` | Boolean | `false` | no | Hides vertical connector when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for timeline item wrapper (`role="listitem"`). |

## Slots
- `FlatPack::Timeline::Component` has no slot API; render `FlatPack::Timeline::Item` instances inside its block.
- `FlatPack::Timeline::Item` accepts block content as rich body when `description` is not provided.

## Variants
- Item marker variants: `:default`, `:success`, `:warning`, `:danger`.
- Item connector behavior: standard line or terminal item (`last: true`).

## Example
```erb
<%= render FlatPack::Timeline::Component.new do %>
  <%= render FlatPack::Timeline::Item.new(
    title: "Deployed",
    timestamp: "5 minutes ago",
    variant: :success,
    last: true
  ) %>
<% end %>
```

## Accessibility
- Timeline wrapper is rendered with `role="list"`.
- Each item is rendered with `role="listitem"`.
- Marker decoration is hidden from assistive tech via `aria-hidden="true"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
