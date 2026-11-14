# Billing Usage Meter

## Purpose
Show usage versus a plan limit with one progress bar and optional helper copy.

## When to use
Use Usage Meter for seat counts, storage, API calls, or other metered entitlements on a billing overview.

## Status
**Implemented.** Intended class: `FlatPack::Billing::UsageMeter::Component`.

## Class
- Primary: `FlatPack::Billing::UsageMeter::Component`
- Related classes: `FlatPack::Progress::Component`, `FlatPack::Tooltip::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String | `nil` | yes | Meter field label (for example `"Seats"`). |
| `used` | Numeric | `nil` | yes | Current usage. Must be non-negative. |
| `limit` | Numeric | `nil` | no | Plan limit. `nil` is unlimited and skips the bar. `0` renders “None on plan” and skips the bar. Omit when `included` and `purchased` are set. Must be non-negative. |
| `included` | Numeric | `nil` | no | Allowance included on the plan. Set together with `purchased`. Non-negative. |
| `purchased` | Numeric | `nil` | no | Extra allowance bought on top of `included`. Set together with `included`. Non-negative. |
| `warning_ratio` | Numeric | `0.8` | no | Share of the limit that switches the bar to warning. From `0` to `1` inclusive. At or over the limit the bar is danger. |
| `unit` | String | `nil` | no | Optional unit label appended in helper text (for example `"seats"`). |
| `description` | String | `nil` | no | Supporting sentence under the meter (for example reset timing). |
| `tooltip_text` | String | `nil` | no | Optional tooltip body for jargon near the label. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

`included` and `purchased` are display counts. Their sum is the limit. The meter still draws one progress bar. A line under the helper reads “100 included + 50 purchased”. When the sum is `0`, the helper is “None on plan” and that line is omitted. Do not pass provider ids.

### Progress mapping

| Condition | Progress behavior | `style` |
|---|---|---|
| `limit` positive, or `included` + `purchased` positive | One bar. `value` is `used`. `max` is the limit (the sum, when the pair is set). | `:default` under `warning_ratio`; `:warning` at or above `warning_ratio` and under the limit; `:danger` at or over the limit |
| `limit` is `0`, or `included` + `purchased` is `0` | No bar. Helper is “None on plan”. | n/a |
| `limit` nil | No bar. Helper is “Unlimited”. | n/a |

Helper text examples:

- With limit: `"8 of 10 seats"`
- Split allowance: `"80 of 150 calls"` and `"100 included + 50 purchased"`
- None on plan: `"None on plan"`
- Unlimited: `"8 seats · Unlimited"`

## Slots
None.

## Variants
None. Progress `style` is derived from the usage ratio and `warning_ratio`. There is no segmented bar.

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
  label: "API calls",
  used: 80,
  included: 100,
  purchased: 50,
  unit: "calls"
) %>

<%= render FlatPack::Billing::UsageMeter::Component.new(
  label: "Exports",
  used: 0,
  limit: 0
) %>

<%= render FlatPack::Billing::UsageMeter::Component.new(
  label: "Build minutes",
  used: 55,
  limit: 100,
  unit: "minutes",
  warning_ratio: 0.5
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
- “None on plan”, the breakdown line, and the over-limit helper are visible text. State does not rely on bar color alone.
- Tooltip content must also be available in visible `description` when it is required to act.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Progress` and optionally `Tooltip`.
- See family guidance: [billing.md](billing.md).
