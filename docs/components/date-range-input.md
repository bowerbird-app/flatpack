# Date Range Input

## Purpose
Provide a standalone date-range picker input with quick presets and calendar-based start/end selection.

## When to use
Use `DateRangeInput` when a form needs explicit start/end date fields but should present a single date-range picker UI.

## Class
- Primary: `FlatPack::DateRangeInput::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `start_name` | String | none | yes | Hidden input name used for the selected start date. |
| `end_name` | String | none | yes | Hidden input name used for the selected end date. |
| `start_value` | String, Date, Time, DateTime, nil | `nil` | no | Initial selected start date (`YYYY-MM-DD` after normalization). |
| `end_value` | String, Date, Time, DateTime, nil | `nil` | no | Initial selected end date (`YYYY-MM-DD` after normalization). |
| `placeholder` | String | `"Select date range"` | no | Trigger placeholder when no range is selected. |
| `label` | String, nil | `nil` | no | Visible label text above the picker trigger. |
| `error` | String, nil | `nil` | no | Error text displayed below the picker trigger. |
| `disabled` | Boolean | `false` | no | Disables trigger interaction and hidden input updates. |
| `required` | Boolean | `false` | no | Marks the trigger as required for forms expecting a range selection. |
| `min` | String, Date, Time, DateTime, nil | `nil` | no | Minimum selectable date. |
| `max` | String, Date, Time, DateTime, nil | `nil` | no | Maximum selectable date. |
| `**system_arguments` | Hash | `{}` | no | Standard HTML attributes (`id`, `class`, `data`, `aria`, etc.). |

## Slots
None.

## Variants
- Default empty range state
- Preselected range (`start_value` + `end_value`)
- Optional validation/error state

## Example
```erb
<%= render FlatPack::DateRangeInput::Component.new(
  start_name: "reporting_period_start",
  end_name: "reporting_period_end",
  label: "Reporting Period",
  start_value: (Date.today - 30).to_s,
  end_value: Date.today.to_s,
  min: (Date.today - 365).to_s,
  max: Date.today.to_s
) %>
```

## Accessibility
- Uses a readonly text trigger with `role="button"` and `aria-haspopup="dialog"`.
- Keeps dialog visibility and expanded state synchronized through ARIA attributes.
- Supports keyboard open interaction (`Enter` / `Space`) and Escape cancel behavior.

## Dependencies
- Stimulus controller: `flat-pack--flatpack-date-picker`
- `FlatPack::Button::Component` for preset, navigation, and action controls
