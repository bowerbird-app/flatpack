# Link

## Purpose
Render a sanitized link component with FlatPack styling and secure target handling.

## When to use
Use Link when you want consistent link styling and URL validation in component-driven views.

## Class
- Primary: `FlatPack::Link::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `href` | String | `nil` | yes | Link URL. Validated by `FlatPack::AttributeSanitizer.validate_href!`. |
| `method` | Symbol/String | `nil` | no | Optional Rails method forwarding (for `link_to`). |
| `target` | String | `nil` | no | Link target. Automatically adds `rel="noopener noreferrer"` for `_blank`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the anchor tag. |

## Slots
None (uses block content as the link label/body).

## Variants
None.

## Example
```erb
<%= render FlatPack::Link::Component.new(href: "/docs/components") do %>
  Browse components
<% end %>
```

## Accessibility
- Provide meaningful link text in the block content.
- Forward `aria-*` attributes through `system_arguments` when needed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::AttributeSanitizer` for URL safety.
