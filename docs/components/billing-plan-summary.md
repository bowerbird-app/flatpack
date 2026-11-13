# Billing Plan Summary

## Purpose
Show the workspace’s current plan name, price, status, and renewal, trial, period-end, or scheduled-change timing with host-supplied actions.

## When to use
Use Plan Summary as the primary “current plan” card on a billing overview. Prefer Plan Picker when the user is choosing among plans.

## Status
**Implemented.** Intended class: `FlatPack::Billing::PlanSummary::Component`.

## Class
- Primary: `FlatPack::Billing::PlanSummary::Component`
- Related classes: `FlatPack::Card::Component`, `FlatPack::Badge::Component`, `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `plan_name` | String | `nil` | yes | Current plan display name (for example `"Pro"`). |
| `price_text` | String | `nil` | no | Host-formatted price string (for example `"$29 / month"`). FlatPack does not format currency. |
| `status` | Symbol | `:active` | no | Subscription status: `:active`, `:trialing`, `:past_due`, `:canceled`, `:incomplete`; invalid values raise `ArgumentError`. |
| `renews_on` | String | `nil` | no | Host-formatted renewal date or copy shown when status is not trialing. |
| `trial_ends_on` | String | `nil` | no | Host-formatted trial end copy; preferred over `renews_on` when `status` is `:trialing`. |
| `ends_on` | Date | `nil` | no | Period end date. Renders a secondary line (`Ends 1 Dec 2026`) and a warning badge, “Cancels at period end”. A `String` raises `ArgumentError`. Not a `status`. |
| `scheduled_change_text` | String | `nil` | no | Host sentence for a future plan change, such as `Changes to Basic on 1 Dec`. Rendered as its own secondary line. Not a `status`. |
| `badges` | Array | `[]` | no | Extra badges beside the status badge. Each hash is `{text:, style:}`. `style` is a `FlatPack::Badge::Component` style (`:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`). Missing text or an unknown style raises `ArgumentError`. |
| `description` | String | `nil` | no | Optional supporting sentence under the plan name. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Status → Badge mapping

| `status` | Badge `text` | Badge `style` |
|---|---|---|
| `:active` | Active | `:success` |
| `:trialing` | Trial | `:info` |
| `:past_due` | Past due | `:warning` |
| `:canceled` | Canceled | `:default` |
| `:incomplete` | Incomplete | `:warning` |

`status` stays this set. Do not add a canceling or scheduled value. An active plan can also be ending: pass `ends_on:` and the warning badge appears next to Active.

When `ends_on` is present, the extra badge is warning style with the text “Cancels at period end”. Host `badges` render after that badge. Omit `ends_on` and the cancel badge stays hidden, even if `scheduled_change_text` is set.

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Primary action row (Change plan, Manage billing). Host renders `Button` with `href`. |
| `footer` | slot | no | Optional footer region below the body. |

## Variants
None. Visual container uses `FlatPack::Card::Component` with `background: :default` (implementation detail).

## Example
```erb
<%= render FlatPack::Billing::PlanSummary::Component.new(
  plan_name: "Pro",
  price_text: "$29 / month",
  status: :active,
  renews_on: "Renews 1 Sep 2026",
  ends_on: Date.new(2026, 12, 1),
  scheduled_change_text: "Changes to Basic on 1 Dec",
  badges: [{text: "Annual", style: :info}],
  description: "Includes 10 seats and priority support."
) do |summary| %>
  <% summary.actions do %>
    <%= render FlatPack::Button::Component.new(
      text: "Change plan",
      href: "/billing/plans",
      style: :secondary
    ) %>
    <%= render FlatPack::Button::Component.new(
      text: "Manage billing",
      href: "/billing/portal",
      style: :default
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Plan name is the heading for the card region.
- Status badge text is always visible so color is not the only signal.
- The period-end badge uses the words “Cancels at period end”, not color alone.
- Action buttons must include descriptive `text`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Card`, `Badge`, and host-provided `Button`s.
- See family guidance: [billing.md](billing.md).
