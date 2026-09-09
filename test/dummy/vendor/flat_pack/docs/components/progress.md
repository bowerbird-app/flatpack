# Progress

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
| `style` | Symbol | `:default` | No | Fill color style. Allowed: `:default`, `:success`, `:warning`, `:danger`. |
| `size` | Symbol | `:md` | No | Bar height. Allowed: `:sm`, `:md`, `:lg`, `:xl`. |
| `label` | String or nil | `nil` | No | Optional visible label text and default `aria-label` source. |
| `show_label` | Boolean | `false` | No | When true and `label` is nil, renders computed percentage text. |
| `label_visible` | Boolean | `true` | No | When false, suppresses the visible label while keeping `label` as the `aria-label`. Use when a surrounding component already shows the name. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into outer wrapper. |

## Slots
None.

## Variants

| style | description |
|---------|-------------|
| `style: :default` | Primary fill (`.fp-progress-fill`, `--progress-fill-color`). |
| `style: :success` | Success fill (`.fp-progress-fill--success`). |
| `style: :warning` | Warning fill (`.fp-progress-fill--warning`). |
| `style: :danger` | Danger fill (`.fp-progress-fill--danger`). |

## Example

```erb
<%= render FlatPack::Progress::Component.new(
  value: 72,
  max: 100,
  style: :default,
  show_label: true
) %>
```

## Accessibility
The inner track uses `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, and `aria-label` (from `label` or fallback `"Progress"`). A screen-reader-only percentage is included inside the fill element.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Kit CSS: `.fp-progress-fill` and `--progress-fill-color`, `--progress-success-fill-color`, `--progress-warning-fill-color`, `--progress-danger-fill-color`. The default fill does not use Tailwind `bg-primary`.
