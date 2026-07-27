# Email Footer Links

## Purpose
Render compact footer links for emails with table-safe structure, explicit text separators, and muted inline typography.

## When to use
Use Email Footer Links in the bottom area of transactional emails for links like Privacy, Terms, Unsubscribe, and Help.

## Class
- Primary: `FlatPack::EmailFooterLinks::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `links` | Array<Hash> | `[]` | yes | Link list as `[{ label:, href: }]`. Each `href` is validated for URL safety. |
| `align` | Symbol | `:center` | no | Footer alignment: `:left`, `:center`, `:right`. |
| `color` | String | `"#6b7280"` | no | Link and separator color. Must be a safe CSS color value. |
| `font_size` | String | `"12px"` | no | Footer text size. Accepts an email-safe CSS size (`px`, `em`, `rem`, `%`). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer presentation table. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::EmailFooterLinks::Component.new(
  links: [
    { label: "Privacy", href: "https://example.com/privacy" },
    { label: "Terms", href: "https://example.com/terms" },
    { label: "Unsubscribe", href: "https://example.com/unsubscribe" },
    { label: "Help", href: "https://example.com/help" }
  ]
) %>
```

## Accessibility
- Uses explicit separator text (`|`) instead of pseudo-elements so separators remain visible in strict clients.
- Links remain plain inline text and wrap naturally on narrow widths.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
