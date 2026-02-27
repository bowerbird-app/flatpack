# Page Header

## Purpose
Render a prominent page heading with optional subtitle and divider spacing.

## When to use
Use Page Header at the top of pages that need a strong title boundary from subsequent content.

## Class
- Primary: `FlatPack::PageHeader::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Primary page heading text. |
| `subtitle` | String | `nil` | no | Secondary descriptive copy below title. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for wrapper element. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::PageHeader::Component.new(
  title: "Billing",
  subtitle: "Manage plans, invoices, and payment methods"
) %>
```

## Accessibility
- Uses semantic `h1` heading for page title.
- Provide descriptive subtitle text where context is needed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
