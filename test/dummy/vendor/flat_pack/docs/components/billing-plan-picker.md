# Billing Plan Picker

## Purpose
Render a responsive grid of plan cards so a host can offer plan choices with features and a single CTA per plan.

## When to use
Use Plan Picker when the user is selecting or comparing plans. Use Plan Summary for the currently active plan on an overview.

## Status
**Implemented.** Intended class: `FlatPack::Billing::PlanPicker::Component`.

## Class
- Primary: `FlatPack::Billing::PlanPicker::Component`
- Related classes: `FlatPack::Grid::Component`, `FlatPack::Card::Component`, `FlatPack::Badge::Component`, `FlatPack::Button::Component`, `FlatPack::Shared::IconComponent`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `items` | Array of Hash | `[]` | yes | Plan hashes. Prefer `items` over inventing `plans` (see [PARAMS.md](PARAMS.md)). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Item hash shape

| key | type | required | description |
|---|---|---|---|
| `name` | String | yes | Plan display name. |
| `price_text` | String | no | Host-formatted price (for example `"$29 / month"`). |
| `description` | String | no | Short supporting line under the name. |
| `features` | Array of String | no | Feature bullets rendered with `List`. |
| `href` | String | no | CTA navigation target. Required for a clickable CTA unless the host overrides `footer`. |
| `cta_text` | String | `"Get started"` | Button `text` for the default CTA. Use current-plan copy such as `"Current plan"` when `current: true`. |
| `current` | Boolean | `false` | Marks this plan as the workspace’s current plan. |
| `highlighted` | Boolean | `false` | Visual emphasis (popular / recommended). Prefer one highlighted plan. |

Rules:

- Prefer `items` for the collection param name.
- Use `href` for CTA navigation; do not use `url`.
- FlatPack does not run checkout. The CTA only navigates via `href`.
- When `current: true`, default CTA should be disabled or secondary with `cta_text: "Current plan"` (host may still supply an `href` for manage/change).

## Slots
| name | type | required | description |
|---|---|---|---|
| `footer` | slot | no | Optional per-picker footer below the grid. |
| `plan_footer` | slot (per item, optional) | no | When implemented, allows replacing the default CTA for a specific plan. |

## Variants
None at the picker root. Card emphasis:

- `highlighted: true` → primary border / “Popular” badge
- `current: true` → “Current” badge; muted or secondary CTA

## Example
```erb
<%= render FlatPack::Billing::PlanPicker::Component.new(
  items: [
    {
      name: "Basic",
      price_text: "$9 / month",
      features: ["3 seats", "Email support"],
      href: "/billing/plans/basic",
      cta_text: "Choose Basic"
    },
    {
      name: "Pro",
      price_text: "$29 / month",
      features: ["10 seats", "Priority support", "Usage insights"],
      href: "/billing/plans/pro",
      cta_text: "Current plan",
      current: true,
      highlighted: true
    },
    {
      name: "Enterprise",
      price_text: "Contact us",
      features: ["Unlimited seats", "Dedicated support"],
      href: "/billing/contact",
      cta_text: "Contact sales"
    }
  ]
) %>
```

## Accessibility
- Each plan card exposes a clear heading (`name`) and a single primary action.
- “Current” and “Popular” badges include text, not color alone.
- Feature lists use semantic list markup via `FlatPack::List::Component`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Grid`, `Card`, `List`, `Badge`, and `Button`.
- See family guidance: [billing.md](billing.md).
