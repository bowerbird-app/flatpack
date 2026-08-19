# Billing Status Alert

## Purpose
Show billing-state feedback (past due, trial ending, payment failed) with consistent Alert styling and optional host action.

## When to use
Use Status Alert above plan/payment sections when the workspace needs immediate billing attention. Prefer plain `FlatPack::Alert::Component` when you only need a one-off message without billing status defaults.

## Status
**Implemented.** Intended class: `FlatPack::Billing::StatusAlert::Component`. Keep this wrapper thin; default copy is the main value over raw `Alert`.

## Class
- Primary: `FlatPack::Billing::StatusAlert::Component`
- Related classes: `FlatPack::Alert::Component`, `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `status` | Symbol | `nil` | no | Billing status shortcut: `:past_due`, `:trial_ending`, `:payment_failed`, `:canceled`; invalid values raise `ArgumentError`. |
| `style` | Symbol | inferred | no | Alert style override: `:info`, `:success`, `:warning`, `:danger`. When set, overrides the status default. |
| `title` | String | inferred | no | Alert title. Defaults from `status` when omitted. |
| `description` | String | inferred | no | Alert body. Defaults from `status` when omitted. |
| `dismissible` | Boolean | `false` | no | Passes through to `Alert`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the alert wrapper. |

### Status defaults

| `status` | `style` | Default `title` | Default `description` |
|---|---|---|---|
| `:past_due` | `:warning` | Past due | Update your payment method to keep this workspace on its plan. |
| `:trial_ending` | `:info` | Trial ending soon | Add a payment method before the trial ends to avoid interruption. |
| `:payment_failed` | `:danger` | Payment failed | Your last payment did not go through. Try another card or contact your bank. |
| `:canceled` | `:info` | Plan canceled | This workspace is no longer on a paid plan. |

When neither `status` nor `title`/`description` is enough, require explicit `title` or `description` (or both) like `Alert`.

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Optional action row (Update card, View invoices). Host supplies `Button` with `href`. |

If slot support is awkward inside `Alert`, document the pattern as an adjacent action row in the host template and keep this component title/description-only.

## Variants
Status-driven styles listed above. Reuse Alert variants; do not invent billing-only colors.

## Example
```erb
<%= render FlatPack::Billing::StatusAlert::Component.new(status: :past_due) do |alert| %>
  <% alert.actions do %>
    <%= render FlatPack::Button::Component.new(
      text: "Update card",
      href: "/billing/payment-method",
      style: :secondary,
      size: :sm
    ) %>
  <% end %>
<% end %>

<%= render FlatPack::Billing::StatusAlert::Component.new(
  style: :warning,
  title: "Usage limit reached",
  description: "You’ve used all seats on this plan. Remove a member or change plan."
) %>
```

## Accessibility
- Wrapper uses `role="alert"` via `FlatPack::Alert::Component`.
- Title and description (or block content) must remain meaningful without color.
- Dismissible mode keeps `aria-label="Dismiss"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Thin wrapper around `FlatPack::Alert::Component`.
- See family guidance: [billing.md](billing.md).
