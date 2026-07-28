# Email Button

## Purpose
Render reusable email-safe primary or secondary call-to-action buttons using table-based markup and inline styles.

## When to use
Use Email Button for CTA links in emails where reliable click area and client compatibility are required.

## Class
- Primary: `FlatPack::EmailButton::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `href` | String | `nil` | yes | Destination URL. Validated by `FlatPack::AttributeSanitizer.validate_href!`. |
| `label` | String | `nil` | yes | Button text label rendered inside the link. |
| `variant` | Symbol | `:primary` | no | Visual variant: `:primary` (solid blue) or `:secondary` (neutral background + border). |
| `align` | Symbol | `:center` | no | Alignment for button table cell: `:left`, `:center`, `:right`. |
| `full_width` | Boolean | `false` | no | When `true`, renders 100% width table and block-level anchor for wide tap/click area. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer presentation table. |

## Slots
None.

## Variants
- `:primary`
- `:secondary`

## Example
```erb
<%= render FlatPack::EmailButton::Component.new(
  href: "https://example.com/confirm",
  label: "Confirm details",
  variant: :primary,
  full_width: true
) %>
```

## Accessibility
- Uses a true anchor element for navigation behavior in email clients.
- Defaults to high-contrast text for both variants and a large click target.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
