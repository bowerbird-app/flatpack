# Billing Usage Meter

## Purpose
Show usage versus a plan limit with a progress bar and optional helper copy.

## When to use
Use Usage Meter for seat counts, storage, API calls, or other metered entitlements on a billing overview.

## Status
**Guidance only.** Not implemented yet. Intended class: `FlatPack::Billing::UsageMeter::Component`.

## Class
- Primary: `FlatPack::Billing::UsageMeter::Component`
- Related classes: `FlatPack::Progress::Component`, `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String | `nil` | yes | Meter field label (for example `"Seats"`). |
| `used` | Numeric | `nil` | yes | Current usage. Must be non-negative. |
| `limit` | Numeric | `nil` | no | Plan limit. When `nil`, treat as unlimited and skip the progress bar fill against a max. |
| `unit` | String | `nil` | no | Optional unit label appended in helper text (for example `"seats"`). |
| `description` | String | `nil` | no | Supporting sentence under the meter (for example reset timing). |
| `tooltip_text` | String | `nil` | no | Optional tooltip body for jargon near the label. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Progress mapping

| Condition | Progress behavior | Suggested `style` |
|---|---|---|
| `limit` present | `value: used`, `max: limit` | `:default` under ~80%; `:warning` near limit; `:danger` at or over limit |
| `limit` nil | Hide bar or show muted “Unlimited” copy | n/a |

Helper text examples:

- With limit: `"8 of 10 seats"`
- Unlimited: `"8 seats · Unlimited"`

## Slots
None.

## Variants
None. Progress `style` is derived from usage ratio when implemented.

## Example
```erb
<%= render FlatPack::Billing::UsageMeter::Component.new(
  label: "Seats",
  used: 8,
  limit: 10,
  unit: "seats",
  description: "Resets on your billing date.",
  tooltip_text: "Seats are counted for active members on this workspace."
) %>

<%= render FlatPack::Billing::UsageMeter::Component.new(
  label: "Storage",
  used: 2.4,
  limit: nil,
  unit: "GB",
  description: "Unlimited on Enterprise."
) %>
```

## Accessibility
- `label` is the accessible name for the meter.
- Progress uses `role="progressbar"` via `FlatPack::Progress::Component`.
- Tooltip content must also be available in visible `description` when it is required to act.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Progress` and optionally `Tooltip`.
- See family guidance: [billing.md](billing.md).
