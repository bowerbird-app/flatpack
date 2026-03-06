# Avatar

## Purpose
Render a user identity image with initials or icon fallback and optional status indicator.

## When to use
Use Avatar in navigation, lists, comments, and profile surfaces where a compact user identity marker is needed.

## Class
- Primary: `FlatPack::Avatar::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `src` | String | `nil` | no | Image URL; when present, image is rendered. |
| `alt` | String | `name` or `"Avatar"` | no | `img` alt text. |
| `name` | String | `nil` | no | Name used for initials fallback and default alt text. |
| `size` | Symbol | `:md` | no | Size: `:xs`, `:sm`, `:md`, `:lg`, `:xl`; invalid values raise `ArgumentError`. |
| `shape` | Symbol | `:circle` | no | Shape: `:circle`, `:rounded`, `:square`; invalid values raise `ArgumentError`. |
| `status` | Symbol | `nil` | no | Status dot: `:online`, `:offline`, `:busy`, `:away`; invalid values raise `ArgumentError`. |
| `href` | String | `nil` | no | When present, renders as a link (`<a>`); otherwise renders as `<span>`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper element. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`, `:xl`.
- Shapes: `:circle`, `:rounded`, `:square`.
- Status: `:online`, `:offline`, `:busy`, `:away`.

## Example
```erb
<%= render FlatPack::Avatar::Component.new(
  name: "Jane Doe",
  src: "https://example.com/jane.jpg",
  size: :md,
  shape: :circle,
  status: :online
) %>
```

## Accessibility
- Provide `alt` for image avatars; if omitted, component falls back to `name` then `"Avatar"`.
- Initials are computed from `name` or `alt`; icon fallback is used when neither is available.
- Status indicator is decorative and rendered with `aria-hidden="true"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
