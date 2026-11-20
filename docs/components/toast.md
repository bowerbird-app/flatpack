# Toast

## Purpose
Show transient status notifications with optional auto-dismiss and manual dismissal. The default theme matches Alert. The surface is tinted, and the icon and the border carry the colour. Info uses the quiet info alert tokens, not `--color-primary`. On the rounded theme, every style uses `--surface-background-color` and `--surface-border-color`. The icon carries the type. Success, warning, and danger use the status fill (`--color-success-background-color`, `--color-warning-background-color`, `--color-danger-background-color`). There is no `--color-info`, so the info icon stays `--surface-muted-content-color`. Text stays `--surface-content-color`. `data-theme="dark rounded"` keeps that shell on the dark surface. Alert is unchanged. The close control is a ghost icon-only `FlatPack::Button::Component` at `size: :xs`. The paint is icon-sized, and the hit target is 44px via `.fp-hit-slop`, not a 44px filled chip. `.fp-toast__dismiss` maps `--toast-dismiss-*` onto `--button-ghost-*`. Every toast style uses that same control.

## When to use
Use Toast for non-blocking feedback such as success confirmations, warnings, and lightweight errors. A Rails flash that should auto-dismiss is [`FlatPack::Flash::Component`](flash.md) with `as: :toast`.

## Class
- Primary: `FlatPack::Toast::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Notification text content. |
| `style` | Symbol | `:info` | no | Visual style: `:info`, `:success`, `:warning`, `:danger`. |
| `timeout` | Integer | `5000` | no | Auto-dismiss timeout in milliseconds; must be non-negative. |
| `dismissible` | Boolean | `true` | no | Shows dismiss button and allows manual dismissal when true. |
| `size` | Symbol | `:md` | no | Density for padding, gap, and text: `:sm`, `:md`, `:lg`. Padding comes from `--toast-padding-sm`, `--toast-padding-md`, and `--toast-padding-lg`. |
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
