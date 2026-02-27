# Toast

## Purpose
Show transient status notifications with optional auto-dismiss and manual dismissal.

## When to use
Use Toast for non-blocking feedback such as success confirmations, warnings, and lightweight errors.

## Class
- Primary: `FlatPack::Toast::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `message` | String | `nil` | yes | Notification message content. |
| `type` | Symbol | `:info` | no | Visual type: `:info`, `:success`, `:warning`, `:error`. |
| `timeout` | Integer | `5000` | no | Auto-dismiss timeout in milliseconds; must be non-negative. |
| `dismissible` | Boolean | `true` | no | Shows dismiss button and allows manual dismissal when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for toast root. |

## Slots
None.

## Variants
- Type variants: `:info`, `:success`, `:warning`, `:error`.

## Example
```erb
<%= render FlatPack::Toast::Component.new(
  message: "Settings saved",
  type: :success,
  timeout: 4000,
  dismissible: true
) %>
```

## Accessibility
- Uses `role="status"` with polite live-region settings.
- Dismiss button includes `aria-label="Dismiss"` when shown.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--toast`.
