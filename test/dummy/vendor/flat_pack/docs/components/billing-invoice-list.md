# Billing Invoice List

## Purpose
Render a table of invoices with status badges, optional row actions, pagination, and an empty state.

## When to use
Use Invoice List for invoice history on a billing overview. FlatPack does not download files; the host supplies view/download `href`s.

## Status
**Implemented.** Intended class: `FlatPack::Billing::InvoiceList::Component`.

## Class
- Primary: `FlatPack::Billing::InvoiceList::Component`
- Related classes: `FlatPack::Table::Component`, `FlatPack::Badge::Component`, `FlatPack::Pagination::Component`, `FlatPack::EmptyState::Component`, `FlatPack::Button::Dropdown::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `items` | Array of Hash | `[]` | no | Invoice row hashes. Empty or omitted triggers the empty state. |
| `title` | String | `"Invoices"` | no | Optional section heading above the table. |
| `empty_title` | String | `"No invoices yet"` | no | Empty-state title. |
| `empty_description` | String | `"They’ll show up here after your first payment."` | no | Empty-state supporting copy. |
| `pagy` | Object | `nil` | no | Optional Pagy object passed through to `FlatPack::Pagination::Component`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root wrapper. |

### Item hash shape

| key | type | required | description |
|---|---|---|---|
| `date` | String | yes | Host-formatted invoice date. |
| `amount` | String | yes | Host-formatted amount (for example `"$29.00"`). |
| `status` | Symbol/String | yes | Invoice status used for badge mapping. |
| `href` | String | no | Primary row action navigation (view or download). |
| `id` | String | no | Optional stable id for row keys. |

### Status → Badge mapping

| `status` | Badge `text` | Badge `style` |
|---|---|---|
| `:paid` / `"paid"` | Paid | `:success` |
| `:open` / `"open"` | Open | `:info` |
| `:failed` / `"failed"` | Failed | `:danger` |
| `:void` / `"void"` | Void | `:default` |
| other | Host string / titleized symbol | `:default` |

## Slots
| name | type | required | description |
|---|---|---|---|
| `actions` | slot | no | Optional header actions (for example filter). |
| `row_actions` | slot | no | Optional per-row actions; when implemented, receives the item. Prefer `Button::Dropdown` for Download / View. |

## Variants
None.

## Example
```erb
<%= render FlatPack::Billing::InvoiceList::Component.new(
  items: [
    { date: "1 Aug 2026", amount: "$29.00", status: :paid, href: "/billing/invoices/1" },
    { date: "1 Jul 2026", amount: "$29.00", status: :paid, href: "/billing/invoices/2" },
    { date: "1 Jun 2026", amount: "$29.00", status: :failed, href: "/billing/invoices/3" }
  ],
  pagy: @pagy
) %>

<%= render FlatPack::Billing::InvoiceList::Component.new(
  items: [],
  empty_title: "No invoices yet",
  empty_description: "They’ll show up here after your first payment."
) %>
```

Suggested columns when implemented:

1. Date
2. Amount
3. Status (`Badge`)
4. Actions (link or dropdown using `href`)

## Accessibility
- Table headers must label each column.
- Status badges include text so color is not the only signal.
- Empty state and row actions must be keyboard reachable.
- Download/view actions use clear `text` (for example `"Download"`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `Table`, `Badge`, `EmptyState`, optional `Pagination` (Pagy), optional `Button::Dropdown`.
- See family guidance: [billing.md](billing.md).
