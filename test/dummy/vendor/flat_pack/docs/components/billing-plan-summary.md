# Billing Plan Summary

## Purpose
Show the workspace’s current plan name, price, status, and renewal or trial timing with host-supplied actions.

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

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Primary action row (Change plan, Manage billing). Host renders `Button` with `href`. |
| `footer` | slot | no | Optional footer region below the body. |

## Variants
None. Visual container uses `FlatPack::Card::Component` with `style: :default` (implementation detail).

## Example
```erb
<%= render FlatPack::Billing::PlanSummary::Component.new(
  plan_name: "Pro",
  price_text: "$29 / month",
  status: :active,
  renews_on: "Renews 1 Sep 2026",
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
- Action buttons must include descriptive `text`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Card`, `Badge`, and host-provided `Button`s.
- See family guidance: [billing.md](billing.md).
