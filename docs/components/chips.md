# Chip

## Purpose
Render compact labels that can be static, interactive, link-based, or removable.

## When to use
Use Chip for tags, filters, selected states, and quick token-like actions.

## Class
- Primary: `FlatPack::Chip::Component`
- Related classes: `FlatPack::ChipGroup::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | no | Chip label; if omitted, block content is used. |
| `style` | Symbol | `:default` | no | Style: `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`; invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Size: `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `selected` | Boolean | `false` | no | Selected state; applies visual ring for `type: :button`. |
| `disabled` | Boolean | `false` | no | Disabled state; disables button chips and renders disabled link chips as `<span>`. |
| `removable` | Boolean | `false` | no | Adds remove control and `flat-pack--chip` controller when not disabled. |
| `href` | String | `nil` | no | Link URL used when `type: :link` and not disabled. |
| `type` | Symbol | `:static` | no | Root type: `:static`, `:button`, `:link`; invalid values raise `ArgumentError`. |
| `value` | String | `nil` | no | Value passed through removable-chip data payload/events. |
| `name` | String | `nil` | no | Reserved name metadata for future form integration. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for chip root element. |

## Slots
- `leading`: content shown before label.
- `trailing`: content shown after label.
- `remove_button`: custom remove control (overrides default removable button).

## Variants
- Styles: `:default`, `:primary`, `:success`, `:warning`, `:danger`, `:info`.
- Sizes: `:sm`, `:md`, `:lg`.
- Types: `:static`, `:button`, `:link`.

## Example
```erb
<%= render FlatPack::Chip::Component.new(
  text: "Active",
  type: :button,
  style: :primary,
  selected: true,
  value: "active"
) %>
```

## Accessibility
- Button chips expose `aria-pressed` for selected state.
- Disabled chips use disabled semantics for buttons and non-interactive rendering for links.
- Default remove control includes `aria-label="Remove"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Removable chips attach Stimulus controller `flat-pack--chip`.
