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
| `text` | String | `nil` | yes | Notification text content. |
| `style` | Symbol | `:info` | no | Visual style: `:info`, `:success`, `:warning`, `:danger`. |
| `timeout` | Integer | `5000` | no | Auto-dismiss timeout in milliseconds; must be non-negative. |
| `dismissible` | Boolean | `true` | no | Shows dismiss button and allows manual dismissal when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for toast root. |

## Slots
None.

## Variants
- Styles: `:info`, `:success`, `:warning`, `:danger`.

## Example
```erb
<%= render FlatPack::Toast::Component.new(
  text: "Settings saved",
  style: :success,
  timeout: 4000,
  dismissible: true
) %>
```

## Accessibility
- Uses `role="status"` with polite live-region settings.
- Dismiss button includes `aria-label="Dismiss"` when shown.
- Under `prefers-reduced-motion: reduce`, the toast does not slide from off-screen and is removed immediately on dismiss.
- Enter slides from the stack edge on `--duration-slow` / `--easing-enter`. Exit uses `--duration-base` / `--easing-exit`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controller: `flat-pack--toast`.
