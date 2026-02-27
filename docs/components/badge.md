# Badge

## Purpose
Render compact status/count labels with optional dot and removable behavior.

## When to use
Use Badge to annotate items with short labels, status states, or counts.

## Class
- Primary: `FlatPack::Badge::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | yes | Badge text content. |
| `style` | Symbol | `:default` | no | Variant style: `:default`, `:primary`, `:success`, `:warning`, `:info`; invalid values raise `ArgumentError`. |
| `size` | Symbol | `:md` | no | Size: `:sm`, `:md`, `:lg`; invalid values raise `ArgumentError`. |
| `dot` | Boolean | `false` | no | Shows small leading dot indicator. |
| `removable` | Boolean | `false` | no | Shows remove button and enables removable behavior. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for badge wrapper. |

## Slots
None.

## Variants
- Styles: `:default`, `:primary`, `:success`, `:warning`, `:info`.
- Sizes: `:sm`, `:md`, `:lg`.

## Example
```erb
<%= render FlatPack::Badge::Component.new(
  text: "Online",
  style: :success,
  size: :md,
  dot: true,
  removable: false
) %>
```

## Accessibility
- Badge text is always visible so color is not the only status signal.
- Removable mode uses a button with `aria-label="Remove"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Removable mode attaches Stimulus controller `flat-pack--badge`.
