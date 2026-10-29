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
| `presets` | Array of names or hashes, nil | default quick list | no | Quick ranges shown in the picker. Omit to keep the default names. A name is a built-in key such as `:last_30_days` or `:last_4_weeks`. `:last_30_days` is built in and is not in the default list. A hash is `label:` plus `days:` (inclusive window ending today) or `start:` and `end:`. Optional `key:` sets the Stimulus preset id. `FlatPack::DateRangeInput::Component::DEFAULT_PRESET_KEYS` is the default name list. |
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
	start_value: (Date.today - 29).to_s,
	end_value: Date.today.to_s,
	min: (Date.today - 365).to_s,
	max: Date.today.to_s,
	presets: [:last_30_days, *FlatPack::DateRangeInput::Component::DEFAULT_PRESET_KEYS]
) %>
```

## Accessibility
- The visible trigger is keyboard-toggleable (`Enter`/`Space`) and exposes dialog semantics via `aria-haspopup` and `aria-expanded`.
- Error state sets `aria-invalid="true"` and links to inline error text with `aria-describedby`.
- Submitted values are stored in hidden `start_name`/`end_name` fields so forms post a predictable date pair.

## Display behavior
- Selecting a quick preset (for example `Last week`) shows that preset label in the trigger field after Apply.
- Calendar ranges display a quick preset label when the chosen start/end exactly match a preset; otherwise they display as `YYYY-MM-DD to YYYY-MM-DD`.
- On first render, if `start_value` and `end_value` match a known quick preset range for today, the trigger displays that preset label.
- Open/close uses `--duration-base` with `--easing-enter` / `--easing-exit` and a few pixels of offset from the trigger, the same helper as Popover. A close in flight can reverse. The panel stays `display: none` while closed because it also uses `md:flex`.
- The open panel moves to `document.body`. `place` in `flat_pack/positioning.js` puts it below the trigger, or above when below does not fit. The gap is 8px. The clamp reads `--overlay-edge-offset`, and an oversized panel sticks to that edge. The controller sets the panel width to the measured width or the viewport minus that inset, whichever is smaller. At `max-width: 767px` the panel is `inset: 0`, `100vw`, and `100dvh`. Scroll and resize while open run the same placement. Disconnect removes those listeners. A click on the trigger or the portaled panel does not close it.

## Dependencies
- Stimulus controller: `app/javascript/flat_pack/controllers/flatpack_date_picker_controller.js`.
- Overlay motion: `playOverlayEnter` / `playOverlayExit` from `controllers/flat_pack/reduced_motion`.
- Popup markup: internal `FlatPack::DatePicker::Panel` (also used by `DateInput` in `picker: :flatpack_date_picker`). Buttons in the popup are `FlatPack::Button::Component`.
- Shared trigger, ids, preset list, and date formatting: `FlatPack::DatePicker::Field`.
- Pass `presets:` for the list. Named built-ins include `:last_30_days` (today and the 29 days before it). Custom hashes send their range to the Stimulus controller as `presetRanges`. The browser fills start and end on click.
- `quick_range_presets` and `preset_range_for` remain instance methods on this component. A prepend can still add a preset by overriding those two methods and calling `super`. Prefer `presets:` so hosts do not need a prepend. The panel renders the list it is given. It does not keep a second copy.
