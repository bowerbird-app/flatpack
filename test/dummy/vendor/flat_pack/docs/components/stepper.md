# Stepper

## Purpose
Show progress through a named sequence of steps.

## When to use
Use Stepper as a presentational trail. The host sets `current_step`. This is not a multi-page form controller.

## Class
- Primary: `FlatPack::Stepper::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `steps` | Array | none | yes | At least two labels. Strings, or hashes with `label:` and optional `description:`, `href:`. |
| `current_step` | Integer | `1` | no | 1-based index of the current step. Must fall inside the list. |
| `orientation` | Symbol | `:horizontal` | no | `:horizontal` or `:vertical`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the list. |

## Slots
None.

## Variants
- Layout via `orientation`.
- Status per step: complete, current, upcoming.

## Example
```erb
<%= render FlatPack::Stepper::Component.new(
  current_step: 2,
  steps: [
    {label: "Details", description: "Name and contact"},
    {label: "Review", description: "Check the summary"},
    {label: "Done", description: "Receipt sent"}
  ]
) %>
```

## Accessibility
- The list has `aria-label="Progress"`. The current label uses `aria-current="step"` when it is not a link.
- Completed markers show a check; upcoming markers show the step number.

## Dependencies
- `FlatPack::Shared::IconComponent` for completed checks.
- Tokens: `--stepper-current-color`, `--stepper-complete-color`, `--stepper-upcoming-color`, `--stepper-label-color`, `--stepper-muted-color`.
