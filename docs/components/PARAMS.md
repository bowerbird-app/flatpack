# FlatPack Component Params

Use these names whenever a component exposes a shared concept. Prefer an existing name over inventing a synonym.

## Shared names

| Concept | Param | Use for |
| --- | --- | --- |
| Color / semantic appearance | `style` | `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`, and other visual schemes |
| Structural / layout shape | `variant` | Layout or composition choices such as `:underline` vs `:pills`, `:centered` vs `:split` |
| Navigation destination | `href` | User-facing links the visitor clicks to go somewhere |
| Data / form endpoint | `*_url` | Search, upload, reorder, form submit, and other non-navigation URLs |
| Compact visible copy | `text` | Primary string on buttons, badges, chips, nav items, quotes, and toasts |
| Form or accessible name | `label` | Field labels and dedicated accessible names that are not the primary visual copy |
| Section heading | `title` | Headings on pages, modals, cards, empty states, and sidebar groups |
| Supporting copy | `description` or `subtitle` | `description` for body explainer text; `subtitle` for a heading companion |
| Overlay position | `placement` | Tooltips, popovers, dropdowns, and notification menus |
| Scale | `size` | `:sm`, `:md`, `:lg`, and other size tokens |
| Extra CSS | `class` | System argument. Do not add `class_name` |
| Action button copy | `*_label` | Confirm, close, submit, cancel, and reset strings |
| Empty-state copy | `empty_text` or `empty_title` / `empty_description` | Single-line empty copy vs title-plus-body empty states |
| List of records | `items` | Search catalogs, pickers, avatar groups, billing plan/invoice rows, and other collections already in the page |
| Open / closed start state | `open` | Whether a collapse, group, or layout starts expanded |
| Host-formatted money | `price_text` / `amount` | Display-only plan prices and invoice amounts; FlatPack does not format currency |
| Host-formatted date copy | `renews_on`, `trial_ends_on`, `expires_text` | Billing renewal, trial, and card expiry strings the host already formatted |
| Subscription / invoice state | `status` | Billing enums such as `:active`, `:past_due`, `:paid`; map to Badge/Alert `style` in the component |

## Billing namespace notes

Planned family docs live under `docs/components/billing*.md`. When implementing `FlatPack::Billing::*`:

- Prefer `items` for plan picker and invoice collections (do not invent `plans` or `invoices` as prop names).
- Prefer `href` for Change plan, Update card, and invoice Download/View navigation.
- Prefer `empty_title` / `empty_description` for payment-method and invoice empty states.
- Prefer `price_text` and `amount` as preformatted strings; do not add a `currency` formatter in FlatPack.
- Prefer `cta_text` for plan-picker button copy (action label pattern via `*_text` / `text`).
- Prefer `cta: false` to omit a plan-picker button. Keep the card footer so tiles stay on one rhythm. `cta_text: false` is an equivalent omit.
- Keep PCI out of FlatPack: never add props for full PAN, CVC, or Elements mount points.

## Do not mix

- Do not use `variant`, `type`, `theme`, or `scheme` for color. Use `style`.
- Do not use `url` for a clickable navigation destination. Use `href`.
- Do not use `label` for the visible string of a compact control. Use `text`.
- Do not use `position` for overlay placement. Use `placement`.
- Keep `type` only for native HTML control types such as button `type: "submit"`.
- Do not use `plans` or `invoices` as collection prop names when `items` already covers the concept.
