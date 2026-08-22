# Billing Plan Picker

## Purpose
Render a responsive grid of plan cards so a host can offer plan choices with features and a single button per plan.

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
| `href` | String | no | Choose-button navigation target. Ignored when `current: true`. |
| `cta` | Boolean | `true` | Set `cta: false` to omit the body button. Current plans still default to a button unless the host sets this. |
| `cta_text` | String or `false` | `"Choose plan"` | Button `text`. Defaults to `"Current"` when `current: true`. Pass `cta_text: false` as an equivalent way to omit the button. |
| `current` | Boolean | `false` | Marks this plan as the workspace’s current plan. Renders a disabled body button, not a badge. |
| `highlighted` | Boolean | `false` | Visual emphasis (popular / recommended). Prefer one highlighted plan. |

Rules:

- Prefer `items` for the collection param name.
- Use `href` for choose-button navigation; do not use `url`.
- FlatPack does not run checkout. The choose button only navigates via `href`.
- The button sits in the card body after the feature list. Tiles do not render a card footer.
- When `current: true`, the body slot is a disabled secondary `FlatPack::Button` with default text `"Current"`. It has no `href`. Do not treat `current` as `cta: false`.
- When `cta: false` (or `cta_text: false`), omit the button entirely. Heights match when every tile keeps a body button.

## Slots
| name | type | required | description |
|---|---|---|---|
| `footer` | slot | no | Optional per-picker footer below the grid. |
| `plan_footer` | slot (per item, optional) | no | When implemented, allows replacing the default button for a specific plan. |

## Variants
None at the picker root. Card emphasis:

- `highlighted: true` → primary border / “Popular” badge
- `current: true` → disabled “Current” button in the body (not a badge); primary border
- `cta: false` → no body button

## Example
```erb
<%= render FlatPack::Billing::PlanPicker::Component.new(
  items: [
    {
      name: "Basic",
      price_text: "$9 / month",
      features: ["3 seats", "Email support"],
      href: "/billing/plans/basic"
    },
    {
      name: "Pro",
      price_text: "$29 / month",
      features: ["10 seats", "Priority support", "Usage insights"],
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
- Each plan card exposes a clear heading (`name`). When a button is shown it is the card’s single primary action.
- A current plan uses a disabled button with visible “Current” text, not color alone.
- “Popular” badges include text, not color alone.
- Feature lists use semantic list markup via `FlatPack::List::Component`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Grid`, `Card`, feature list markup, `Badge`, and `Button`.
- See family guidance: [billing.md](billing.md).
