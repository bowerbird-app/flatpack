# Quote

## Purpose
Display quoted text with optional citation and size styling.

## When to use
Use Quote for testimonials, excerpts, and highlighted statements.

## Class
- Primary: `FlatPack::Quote::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `text` | String | `nil` | conditional | Quote content; required unless provided via block content. |
| `cite` | String | `nil` | no | Optional citation/author line, prefixed with an em dash. |
| `size` | Symbol | `:md` | no | Typography size: `:sm`, `:md`, `:lg`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for `<figure>` wrapper. |

## Slots
None (content can be passed as block instead of `text`).

## Variants
- Size variants: `:sm`, `:md`, `:lg`.

## Example
```erb
<%= render FlatPack::Quote::Component.new(
  text: "Design is the rendering of intent.",
  cite: "Jared Spool",
  size: :md
) %>
```

## Accessibility
- Uses semantic `<figure>`, `<blockquote>`, and optional `<figcaption>` structure.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
