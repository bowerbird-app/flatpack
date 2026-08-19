# Billing Payment Method

## Purpose
Show the on-file payment method (brand, last four, expiry) or an empty state with host-supplied actions.

## When to use
Use Payment Method on a billing overview to display how the workspace pays. Do not use it to collect full card numbers or CVC.

## Status
**Implemented.** Intended class: `FlatPack::Billing::PaymentMethod::Component`.

## Class
- Primary: `FlatPack::Billing::PaymentMethod::Component`
- Related classes: `FlatPack::Card::Component`, `FlatPack::EmptyState::Component`, `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `brand` | String | `nil` | no | Card brand display name (for example `"Visa"`). Required with `last4` for a filled state. |
| `last4` | String | `nil` | no | Last four digits only. Never accept a full PAN. |
| `expires_text` | String | `nil` | no | Host-formatted expiry (for example `"09/28"`). Prefer this over a raw date object. |
| `expires_on` | String | `nil` | no | Alternate host-formatted expiry string if `expires_text` is unused. |
| `title` | String | `"Payment method"` | no | Card heading. |
| `empty_title` | String | `"No card on file"` | no | Empty-state title when brand/last4 are blank. |
| `empty_description` | String | `"Add a payment method to keep billing up to date."` | no | Empty-state supporting copy. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Filled vs empty

| Condition | Render |
|---|---|
| `brand` and `last4` present | Card body with brand, masked number (`•••• 4242`), expiry |
| Otherwise | `EmptyState` using `empty_title` / `empty_description` |

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Update card / Add payment method buttons. Host supplies `href`s. |

## Variants
None.

## Example
```erb
<%= render FlatPack::Billing::PaymentMethod::Component.new(
  brand: "Visa",
  last4: "4242",
  expires_text: "09/28"
) do |method| %>
  <% method.actions do %>
    <%= render FlatPack::Button::Component.new(
      text: "Update card",
      href: "/billing/payment-method",
      style: :secondary
    ) %>
  <% end %>
<% end %>

<%= render FlatPack::Billing::PaymentMethod::Component.new(
  empty_title: "No card on file",
  empty_description: "Add a card to continue after your trial."
) do |method| %>
  <% method.actions do %>
    <%= render FlatPack::Button::Component.new(
      text: "Add payment method",
      href: "/billing/payment-method",
      style: :primary
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Masked card display must remain readable as text (brand + last four).
- Empty state title and actions must be keyboard reachable.
- Do not rely on card-brand color alone for recognition.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Card`, `EmptyState`, and host-provided `Button`s.
- PCI: hosts redirect to a provider-hosted flow via `href`; FlatPack never mounts card fields.
- See family guidance: [billing.md](billing.md).
