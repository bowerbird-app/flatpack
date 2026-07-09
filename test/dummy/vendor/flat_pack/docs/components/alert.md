# Alert

## Purpose
Render inline status messages for informational, success, warning, or danger feedback.

## When to use
Use Alert when users need immediate contextual feedback near form content or page state.

## Class
- Primary: `FlatPack::Alert::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | no | Optional heading text. |
| `description` | String | `nil` | no | Optional supporting description text. |
| `style` | Symbol | `:info` | no | Variant style: `:info`, `:success`, `:warning`, `:danger`; invalid values raise `ArgumentError`. |
| `dismissible` | Boolean | `false` | no | Shows dismiss button and binds dismiss controller behavior. |
| `icon` | Boolean | `true` | no | Shows variant icon when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for alert wrapper. |

## Slots
None (optional block content replaces title/description rendering).

## Variants
- `:info`, `:success`, `:warning`, `:danger`.

## Example
```erb
<%= render FlatPack::Alert::Component.new(
  title: "Success",
  description: "Your profile was updated.",
  style: :success,
  dismissible: true
) %>
```

## Accessibility
- Wrapper uses `role="alert"`.
- Dismiss button includes `aria-label="Dismiss"`.
- Preserve meaningful title/description or block content text.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Dismissible mode attaches Stimulus controller `alert`.
