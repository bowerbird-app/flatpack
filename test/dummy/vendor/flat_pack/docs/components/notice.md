# Notice

## Purpose
Render a polite inline status message for info or success. The box matches Alert. The root is `role="status"`, so a screen reader does not treat it as urgent.

## When to use
Use Notice for informational or success feedback near page content, including a Rails `notice`. Use [`FlatPack::Alert::Component`](alert.md) for warning or danger. A Rails flash that should stay on the page is [`FlatPack::Flash::Component`](flash.md) with `as: :alert`. That mode renders Notice for `notice`, `info`, `success`, and unknown keys.

## Class
- Primary: `FlatPack::Notice::Component`
- Related classes: `FlatPack::Alert::Component`

The box, icon, type, padding, and dismiss control live in the internal `FlatPack::Shared::StatusMessage` renderer. Alert uses that same renderer with `role="alert"`.

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | no | Optional heading text. |
| `description` | String | `nil` | no | Optional supporting description text. |
| `style` | Symbol | `:info` | no | Variant style: `:info`, `:success`. Any other value raises `ArgumentError`. |
| `dismissible` | Boolean | `false` | no | Shows dismiss button and binds the alert dismiss controller. |
| `icon` | Boolean | `true` | no | Shows variant icon when true. |
| `size` | Symbol | `:md` | no | Density for padding, title, and description: `:sm`, `:md`, `:lg`. Padding comes from `--alert-padding-sm`, `--alert-padding-md`, and `--alert-padding-lg`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the notice wrapper. |

## Slots
None (optional block content replaces title/description rendering).

## Variants
- `:info`, `:success`.

## Example
```erb
<%= render FlatPack::Notice::Component.new(
  title: "Saved",
  description: "The take is in the library.",
  style: :success,
  dismissible: true
) %>
```

## Accessibility
- Wrapper uses `role="status"` (polite). It does not use `role="alert"`.
- Dismiss button includes `aria-label="Dismiss"`.
- Preserve meaningful title/description or block content text.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Dismissible mode attaches Stimulus controller `flat-pack--alert`. The dismiss action is `flat-pack--alert#dismiss`. The custom event name stays `alert:dismissed`.
- The dismiss control is the same ghost icon-only Button as Alert. Copy comes from `flatpack.alert.dismiss`.
- Dismiss collapses height and opacity on `--duration-slow` / `--easing-exit` via `playCollapseExit`, so stacked notices do not jump. Reduced motion snaps.
