# Spinner

## Purpose
Show a spinning loading mark for a wait that is already in progress.

## When to use
Use Spinner inline next to copy, or let Button render it when `loading: true`. Prefer Skeleton when the whole region is a placeholder.

## Class
- Primary: `FlatPack::Spinner::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `size` | Symbol | `:md` | no | One of `:sm`, `:md`, `:lg`, `:xl` (same scale as `IconComponent`). |
| `label` | String or nil | `"Loading"` | no | Accessible name. When present, the SVG is `role="status"`. Pass `nil` for a decorative spinner (`aria-hidden`). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the SVG. |

## Slots
None.

## Variants
- Sizes via `size`.
- Named vs decorative via `label`.

## Example
```erb
<%= render FlatPack::Spinner::Component.new(size: :md, label: "Loading") %>
```

Button loading reuses the decorative spinner:

```erb
<%= render FlatPack::Button::Component.new(text: "Save", loading: true) %>
```

## Accessibility
- A labelled spinner is a live status. A `label: nil` spinner is hidden from assistive tech; the parent must name the wait (Button does this with `Loading` / `aria-busy`).
- Spinning uses `.fp-spinner`. Default is a 1s rotate. Under `prefers-reduced-motion`, the mark opacity-pulses (no transform) so loading stays visible. Pulse duration is not `--duration-*`, so it does not collapse to `0ms`.

## Dependencies
- `FlatPack::Shared::IconComponent::SIZES` for the size scale.
