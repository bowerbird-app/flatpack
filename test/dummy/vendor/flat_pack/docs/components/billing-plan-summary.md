# Billing Plan Summary

## Purpose
Show the workspace’s current plan name, price, optional status, and renewal or trial timing with host-supplied actions.

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
| `status` | Symbol, `nil`, or `false` | `:active` | no | `:active`, `:trialing`, `:past_due`, `:canceled`, or `:incomplete` render a badge. `nil` or `false` omit the badge (the heading is just `plan_name`). Invalid values raise `ArgumentError`. |
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
| `nil` or `false` | *(no badge)* | — |

On a billing overview the current plan often needs no badge: status is implied by being on the page. Pass `status: nil` (or `false`).

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Primary action row (Change plan, Manage billing). Host renders `Button` with `href`. |
| `footer` | slot | no | Optional card footer below the body. Hosts put secondary actions such as Cancel plan here. Actions stay in the body. |

## Variants
None. Visual container uses `FlatPack::Card::Component` with `style: :default` (implementation detail).

## Example
```erb
<%= render FlatPack::Billing::PlanSummary::Component.new(
  plan_name: "Pro",
  price_text: "$29 / month",
  status: nil,
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
  <% summary.footer do %>
    <%= render FlatPack::Button::Component.new(
      text: "Cancel plan",
      href: "/billing/cancel",
      style: :secondary
    ) %>
  <% end %>
<% end %>
```

Named statuses still render a badge:

```erb
<%= render FlatPack::Billing::PlanSummary::Component.new(
  plan_name: "Pro",
  price_text: "$29 / month",
  status: :past_due,
  renews_on: "Payment failed on 1 Aug 2026"
) %>
```

## Accessibility
- Plan name is the heading for the card region.
- When a status badge is shown, its text is always visible so color is not the only signal. Omit `status` (`nil` / `false`) when the page already implies the current plan.
- Action buttons must include descriptive `text`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Card`, `Badge`, and host-provided `Button`s.
- See family guidance: [billing.md](billing.md).
