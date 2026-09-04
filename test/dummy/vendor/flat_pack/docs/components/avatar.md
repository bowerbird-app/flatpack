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
| `initials` | String | `nil` | no | Explicit initials fallback text. |
| `icon` | String, Symbol, nil | `nil` | no | Heroicons v2 name rendered when there is no `src` and no initials, e.g. `"photo"`. Same `icon:` API as Button. Omit to keep the person glyph. |
| `size` | Symbol | `:md` | no | Size: `:xs`, `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`; invalid values raise `ArgumentError`. |
| `shape` | Symbol | `:circle` | no | Shape: `:circle`, `:rounded`, `:square`; invalid values raise `ArgumentError`. |
| `status` | Symbol | `nil` | no | Status dot: `:online`, `:offline`, `:busy`, `:away`; invalid values raise `ArgumentError`. |
| `href` | String | `nil` | no | When present, renders as a link (`<a>`); otherwise renders as `<span>`. |
| `show_tooltip` | Boolean | `true` | no | Renders a tooltip from `name` or `alt` when identity text is present. Boolean-like values such as `"false"` are cast. |
| `tooltip_placement` | Symbol | `:bottom` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper element. |

## Slots
None.

## Variants
- Sizes: `:xs`, `:sm`, `:md`, `:lg`, `:xl`, `:"2xl"`.
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

Disable the automatic tooltip when the avatar is already labelled by nearby content:

```erb
<%= render FlatPack::Avatar::Component.new(
  name: "Jane Doe",
  size: :md,
  show_tooltip: false
) %>
```

```erb
<%= render FlatPack::Avatar::Component.new(
  icon: "photo",
  size: :md,
  shape: :square
) %>
```

## Accessibility
- Provide `alt` for image avatars; if omitted, component falls back to `name` then `"Avatar"`.
- Initials are computed from `name` or `alt`. When those are absent, `icon:` renders that Heroicon. When `icon:` is omitted too, a person glyph is used.
- Status indicator is decorative and rendered with `aria-hidden="true"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
