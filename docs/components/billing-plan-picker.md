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
| `cols` | Integer or `:auto` | `3` | no | Desktop column count. Same presets as `FlatPack::Grid::Component`: `1`, `2`, `3`, `4`, `6`, `12`, `:auto`. Narrower breakpoints collapse (for `3`: one column, then two from `md`, then three from `lg`). Anything else raises `ArgumentError`. |
| `padding` | Symbol | `:md` | no | Card padding on each plan body and footer. `:none`, `:sm`, `:md`, `:lg`. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Item hash shape

| key | type | required | description |
|---|---|---|---|
| `name` | String | yes | Plan display name. |
| `price_text` | String | no | Host-formatted price (for example `"$29 / month"`). |
| `description` | String | no | Short supporting line under the name. |
| `features` | Array of String | no | Feature bullets rendered with `List`. |
| `href` | String | no | CTA navigation target. Renders a link. Do not combine with `url`. |
| `url` | String | no | CTA form action. Renders `FlatPack::Button::Component` form mode (a `form.contents` and a submit button). Do not combine with `href`. |
| `method` | Symbol | `:post` when `url` is set | Form verb forwarded to Button: `:get`, `:post`, `:put`, `:patch`, `:delete`. With `href` and no `url`, forwarded to `link_to`. |
| `params` | Hash | no | Hidden fields for the form. Needs `url`. Nested hashes use `name[key]`. Arrays use `name[]`. |
| `turbo` | Boolean | `true` | Sets `data-turbo` on the form. `false` is a full-page submit. |
| `cta_text` | String | `"Get started"` | Button `text` for the default CTA. Use current-plan copy such as `"Current plan"` when `current: true`. |
| `current` | Boolean | `false` | Marks this plan as the workspace’s current plan. |
| `highlighted` | Boolean | `false` | Visual emphasis (popular / recommended). Prefer one highlighted plan. |

Rules:

- Prefer `items` for the collection param name.
- Use `href` when the CTA navigates. Use `url` when the CTA submits a form. `href` and `url` on the same plan raise `ArgumentError`.
- FlatPack does not run checkout. A form posts to the host `url`. The host owns the action.
- `params` without `url`, a non-Hash `params`, an unknown `method` with `url`, or a `turbo` value other than `true` or `false` raises `ArgumentError`.
- When `current: true`, the default CTA is secondary with `cta_text: "Current plan"` (the host may still supply an `href` or `url`).

## Slots
| name | type | required | description |
|---|---|---|---|
| `footer` | slot | no | Optional per-picker footer below the grid. `picker.footer`. |
| `plan_footer` | slot, collection | no | Replaces the default CTA for one plan. `picker.plan_footer(name: "Enterprise")`. `name` must match exactly one item `name`. An unknown name, a blank name, or a second slot with the same name raises `ArgumentError`. The block renders in that card's footer. |

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

A form CTA. `method` defaults to `:post`. `turbo` defaults to `true`.

```erb
<%= render FlatPack::Billing::PlanPicker::Component.new(
  items: [
    {
      name: "Basic",
      price_text: "$9 / month",
      url: "/billing/plans/basic",
      params: { plan: "basic" },
      cta_text: "Subscribe"
    },
    {
      name: "Pro",
      price_text: "$29 / month",
      url: "/billing/plans/pro",
      method: :patch,
      params: { plan: "pro" },
      turbo: false,
      cta_text: "Switch to Pro"
    }
  ]
) %>
```

Replace one plan's button. Other plans keep the default CTA.

```erb
<%= render FlatPack::Billing::PlanPicker::Component.new(
  items: [
    { name: "Basic", href: "/billing/plans/basic", cta_text: "Choose Basic" },
    { name: "Enterprise", href: "/billing/contact", cta_text: "Contact sales" }
  ]
) do |picker| %>
  <% picker.plan_footer(name: "Enterprise") do %>
    <%= render FlatPack::Button::Component.new(text: "Book a call", href: "/billing/contact", style: :secondary, class: "w-full") %>
  <% end %>
<% end %>
```

Desktop columns and card padding. `cols: 4` is one column on a phone, two from `md`, and four from `lg`.

```erb
<%= render FlatPack::Billing::PlanPicker::Component.new(
  cols: 4,
  padding: :lg,
  items: [
    { name: "Basic", price_text: "$9 / month", href: "/billing/plans/basic" },
    { name: "Pro", price_text: "$29 / month", href: "/billing/plans/pro" }
  ]
) %>
```

## Accessibility
- Each plan card exposes a clear heading (`name`) and a single primary action.
- A `url` CTA is a submit button inside a form. An `href` CTA is a link. A `plan_footer` replaces that action with the host block.
- “Current” and “Popular” badges include text, not color alone.
- Feature lists use semantic list markup via `FlatPack::List::Component`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Grid`, `Card`, feature list markup, `Badge`, and `Button`.
- See family guidance: [billing.md](billing.md).
