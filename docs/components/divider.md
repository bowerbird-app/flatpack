# Divider

## Purpose
Render a full-width horizontal rule, optionally with a muted label centered on the line (for example “Or” between password submit and Continue with Google).

## When to use
Use Divider to separate stacked actions or form blocks in login/register and similar two-auth layouts. Prefer this over ad-hoc borders when you need an optional centered label. Do not use `Chat::DateDivider` outside chat message lists — that component is chat-scoped and requires a label. Do not invent a LoginForm or AuthDivider special case; compose this with existing buttons and inputs.

## Class
- Primary: `FlatPack::Divider::Component`
- Related classes: `FlatPack::Chat::DateDivider::Component`, `FlatPack::Sidebar::Divider::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `label` | String | `nil` | no | Optional muted text centered on the rule (for example `"Or"`). Blank or omitted renders a plain rule. Non-string values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root element. |

## Slots
None.

## Variants
None. Presence of `label` toggles plain rule vs labeled rule.

## Example
```erb
<%= render FlatPack::Button::Component.new(text: "Sign in", style: :primary, class: "w-full") %>
<%= render FlatPack::Divider::Component.new(label: "Or", class: "my-4") %>
<%= render FlatPack::Button::Component.new(text: "Continue with Google", style: :secondary, class: "w-full") %>
```

Plain rule:

```erb
<%= render FlatPack::Divider::Component.new %>
```

## Accessibility
Root uses `role="separator"`. When `label` is present, it is also set as `aria-label`. Unlabeled dividers are decorative separators.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Theme tokens: `--surface-border-color`, `--surface-muted-content-color`.
