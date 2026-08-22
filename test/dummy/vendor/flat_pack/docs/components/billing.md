# Billing

## Purpose
Define the presentational FlatPack billing component family so hosts can render plan, usage, payment, and invoice UI without payment-provider logic in FlatPack.

## When to use
Use these components when a host (or a billing addon) already owns plans, invoices, and payment methods, and only needs consistent FlatPack surfaces for display and navigation actions.

Do **not** use this family to collect raw card numbers, run checkout, or mount a full billing settings app inside FlatPack.

## Status
**Implemented.** Presentational components ship under `FlatPack::Billing::*` with fixture-only dummy demos.

## Class
- Family namespace: `FlatPack::Billing`
- Related classes:
  - `FlatPack::Billing::PlanSummary::Component` — [billing-plan-summary.md](billing-plan-summary.md)
  - `FlatPack::Billing::PlanPicker::Component` — [billing-plan-picker.md](billing-plan-picker.md)
  - `FlatPack::Billing::UsageMeter::Component` — [billing-usage-meter.md](billing-usage-meter.md)
  - `FlatPack::Billing::PaymentMethod::Component` — [billing-payment-method.md](billing-payment-method.md)
  - `FlatPack::Billing::InvoiceList::Component` — [billing-invoice-list.md](billing-invoice-list.md)
  - `FlatPack::Billing::StatusAlert::Component` — [billing-status-alert.md](billing-status-alert.md)

## Props
Not applicable at the family level. Each child component documents its own props.

## Slots
None at the family level. Hosts compose child components under `FlatPack::PageTitle::Component` or `FlatPack::PageHeader::Component`.

## Variants
None. Do not add a monolithic `FlatPack::Billing::Component` that owns an entire settings page.

## Example
```erb
<%= render FlatPack::PageHeader::Component.new(
  title: "Billing",
  subtitle: "Manage plans, invoices, and payment methods"
) %>

<%= render FlatPack::Billing::StatusAlert::Component.new(status: :past_due) %>

<%= render FlatPack::Billing::PlanSummary::Component.new(
  plan_name: "Pro",
  price_text: "$29 / month",
  status: :active,
  renews_on: "1 Sep 2026"
) do |summary| %>
  <% summary.actions do %>
    <%= render FlatPack::Button::Component.new(text: "Change plan", href: "/billing/plans", style: :secondary) %>
  <% end %>
  <% summary.footer do %>
    <%= render FlatPack::Button::Component.new(text: "Cancel plan", href: "/billing/cancel", style: :secondary) %>
  <% end %>
<% end %>

<%= render FlatPack::Billing::UsageMeter::Component.new(
  label: "Seats",
  used: 8,
  limit: 10,
  unit: "seats"
) %>

<%= render FlatPack::Billing::PaymentMethod::Component.new(
  brand: "Visa",
  last4: "4242",
  expires_text: "09/28"
) do |method| %>
  <% method.actions do %>
    <%= render FlatPack::Button::Component.new(text: "Update card", href: "/billing/payment-method", style: :secondary) %>
  <% end %>
<% end %>

<%= render FlatPack::Billing::InvoiceList::Component.new(items: @invoices) %>
```

## Non-goals

- No Stripe, PayPal, or other SDK scripts, Elements mounts, or webhook handling
- No subscribe, cancel, or customer-portal business logic
- No forms that collect full PAN or CVC (PCI stays with the host or provider)
- No mountable routes, controllers, or “Billing settings” screens in FlatPack
- No `plan_id` or user-centric billing assumptions — props are display strings and status enums only

## Param conventions

Follow [PARAMS.md](PARAMS.md):

| Concept | Param | Billing use |
|---|---|---|
| Semantic color | `style` | Badge and alert appearance |
| Layout shape | `variant` | Only if a child needs a layout choice (not color) |
| Navigation | `href` | Change plan, update card, download invoice |
| Form endpoints | `*_url` | Only if a future child posts a form |
| Button copy | `text` | Action labels |
| Section / empty headings | `title`, `empty_title` | Empty states and alert titles |
| Supporting copy | `description`, `empty_description`, `subtitle` | Helper text under meters and empty states |
| Collections | `items` | Plan picker plans and invoice rows |
| Plan picker CTA | `cta`, `cta_text` | Body button after features. Default `"Choose plan"`; current plans default to a disabled `"Current"` button. `cta: false` omits the button |

Default copy stays short and plain: “Change plan”, “Update card”, “No invoices yet”.

## Composition map

| Component | Builds on |
|---|---|
| Plan summary | `Card`, `Badge`, `Button` (via slots) |
| Plan picker | `Grid`, `Card`, `Badge`, `Button`, feature list markup |
| Usage meter | `Progress`, `Tooltip` (optional) |
| Payment method | `Card`, `EmptyState`, `Button` (via slots) |
| Invoice list | `Table`, `Badge`, `Pagination`, `EmptyState`, `Button::Dropdown` |
| Status alert | `Alert` |

## Accessibility
- Each child doc lists accessibility requirements.
- Status must never rely on color alone — pair `Badge` / `Alert` text with `style`.
- Action buttons and links must have visible `text` and keyboard reachability.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Existing primitives listed in the composition map.
- Host supplies formatted dates, amounts, and action `href`s.

## Dummy demos

Fixture-only pages under `/demo/billing` and sibling routes. No live payment providers.
