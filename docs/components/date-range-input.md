# Date Range Input

## Purpose
Provide a single range picker input that writes `start` and `end` values to hidden fields while offering quick presets and calendar selection.

## When to use
Use this when your form needs a start and end date pair with one compact control and consistent FlatPack styling.

## Class
- Primary: `FlatPack::DateRangeInput::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `start_name` | String | none | yes | Hidden input name for the selected range start date. |
| `end_name` | String | none | yes | Hidden input name for the selected range end date. |
| `start_value` | String, Date, Time, DateTime, nil | `nil` | no | Initial selected start date; normalized to `YYYY-MM-DD`. |
| `end_value` | String, Date, Time, DateTime, nil | `nil` | no | Initial selected end date; normalized to `YYYY-MM-DD`. |
| `placeholder` | String, nil | `"Select date range"` | no | Trigger placeholder when no range is selected. |
| `disabled` | Boolean | `false` | no | Disables trigger interaction and hidden fields updates. |
| `required` | Boolean | `false` | no | Marks the trigger as required for form validation. |
| `label` | String, nil | `nil` | no | Optional visible label rendered above the trigger. |
| `error` | String, nil | `nil` | no | Error text shown below the control; sets `aria-invalid`. |
| `min` | String, Date, Time, DateTime, nil | `nil` | no | Minimum selectable date. |
| `max` | String, Date, Time, DateTime, nil | `nil` | no | Maximum selectable date. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the wrapper/trigger (for example `id`, `class`, `data`, `aria`). |

## Slots
None.

## Variants
None.

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
- The visible trigger is keyboard-toggleable (`Enter`/`Space`) and exposes dialog semantics via `aria-haspopup` and `aria-expanded`.
- Error state sets `aria-invalid="true"` and links to inline error text with `aria-describedby`.
- Submitted values are stored in hidden `start_name`/`end_name` fields so forms post a predictable date pair.

## Dependencies
- Stimulus controller: `app/javascript/flat_pack/controllers/flatpack_date_picker_controller.js`.
- Uses `FlatPack::Button::Component` for preset, calendar navigation, and action controls.
