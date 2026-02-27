# Progress Bar Component

## Purpose
Display numeric progress as a horizontal bar with optional label text.

## When to use
Use Progress when users need a visual indicator of completion for uploads, tasks, or step flows.

## Class
- Primary: `FlatPack::Progress::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `value` | Numeric | none | Yes | Current progress value. Must be non-negative. |
| `max` | Numeric | `100` | No | Maximum value. Must be greater than zero. |
| `variant` | Symbol | `:default` | No | Fill color variant. Allowed: `:default`, `:success`, `:warning`, `:danger`. |
| `size` | Symbol | `:md` | No | Bar height. Allowed: `:sm`, `:md`, `:lg`, `:xl`. |
| `label` | String or nil | `nil` | No | Optional visible label text and default `aria-label` source. |
| `show_label` | Boolean | `false` | No | When true and `label` is nil, renders computed percentage text. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into outer wrapper. |

## Slots
None.

## Variants

| variant | description |
|---------|-------------|
| `variant: :default` | Primary fill color (`bg-primary`). |
| `variant: :success` | Success fill color (`bg-success-background-color`). |
| `variant: :warning` | Warning fill color (`bg-warning-background-color`). |
| `variant: :danger` | Danger fill color (`bg-danger-background-color`). |

## Example

```erb
<%= render FlatPack::Progress::Component.new(
  value: 72,
  max: 100,
  variant: :default,
  show_label: true
) %>
```

## Accessibility
The inner track uses `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, and `aria-label` (from `label` or fallback `"Progress"`). A screen-reader-only percentage is included inside the fill element.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
