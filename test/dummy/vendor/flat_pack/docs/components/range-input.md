# Range Input

## Purpose
Provide a slider control for selecting numeric values within a bounded range.

## When to use
Use `RangeInput` for numeric adjustments such as volume, opacity, thresholds, or scoring where dragging is faster than typing.

## Class
- Primary: `FlatPack::RangeInput::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `name` | String | none | yes | Form field name for submission. |
| `id` | String | `name` | no | Input id and label `for` binding. |
| `value` | Numeric | `min` | no | Initial slider value. |
| `min` | Numeric | `0` | no | Minimum slider value. Must be less than `max`. |
| `max` | Numeric | `100` | no | Maximum slider value. Must be greater than `min`. |
| `step` | Numeric | `1` | no | Slider increment step. |
| `label` | String | `nil` | no | Optional visible label. |
| `help_text` | String | `nil` | no | Optional plain-text guidance rendered below the slider in muted `text-xs` styling. Only plain `String` values are accepted; HTML-like content is escaped as text. |
| `show_value` | Boolean | `true` | no | Shows current value beside the label. |
| `disabled` | Boolean | `false` | no | Disables interaction. |
| `**system_arguments` | Hash | `{}` | no | Standard HTML attributes merged into the container. |

## Slots
None.

## Variants
- Value display: `show_value: true` (default) or `show_value: false`
- State: enabled or disabled (`disabled: true`)

## Example
```erb
<%= render FlatPack::RangeInput::Component.new(
  name: "volume",
  label: "Volume",
  min: 0,
  max: 100,
  step: 1,
  help_text: "Drag to set the preferred volume.",
  value: 50
) %>
```

## Accessibility
- Uses native `<input type="range">` semantics.
- Sets `aria-label`, `aria-valuenow`, `aria-valuemin`, and `aria-valuemax`.
- Links `help_text` with `aria-describedby` when present.
- Supports keyboard slider behavior provided by the browser.

## Dependencies
- Core install: `rails generate flat_pack:install`
- Stimulus: `flat-pack--range-input` for live value display updates and `range-input:change` custom events
