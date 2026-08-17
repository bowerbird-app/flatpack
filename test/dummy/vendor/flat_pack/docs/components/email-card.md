# Email Card

## Purpose
Render a reusable email-safe container with table markup, inline styles, and max-width constrained layout behavior.

## When to use
Use Email Card when wrapping transactional email sections that must render reliably across Gmail, Outlook, and Apple Mail.

## Class
- Primary: `FlatPack::EmailCard::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `max_width` | Integer | `600` | no | Maximum content width in pixels. Card remains `width:100%` and caps at this size on larger viewports. |
| `padding` | String | `"24px"` | no | Inline-safe cell padding. Accepts CSS size tokens (`px`, `em`, `rem`, `%`) with up to 4 values. |
| `bg_color` | String | `"#ffffff"` | no | Card background color. Must be a safe CSS color value. |
| `border_color` | String | `"#e5e7eb"` | no | Card border color. Must be a safe CSS color value. |
| `align` | Symbol | `:center` | no | Container alignment: `:left`, `:center`, `:right`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer presentation table. |

## Slots
None (uses block content as card body).

## Variants
None.

## Example
```erb
<%= render FlatPack::EmailCard::Component.new(max_width: 600, padding: "24px") do %>
  <h1 style="margin:0 0 12px 0;font-family:Arial,sans-serif;font-size:24px;line-height:1.3;color:#111827;">Action required</h1>
  <p style="margin:0 0 16px 0;font-family:Arial,sans-serif;font-size:16px;line-height:1.5;color:#374151;">Please confirm your account details to continue securely.</p>

  <%= render FlatPack::EmailButton::Component.new(
    href: "https://example.com/confirm",
    text: "Confirm details",
    style: :primary,
    full_width: true
  ) %>

  <div style="height:12px;line-height:12px;font-size:12px;"></div>

  <%= render FlatPack::EmailButton::Component.new(
    href: "https://example.com/settings",
    text: "Review settings",
    style: :secondary,
    full_width: true
  ) %>

  <div style="height:20px;line-height:20px;font-size:20px;"></div>

  <%= render FlatPack::EmailFooterLinks::Component.new(
    links: [
      { label: "Privacy", href: "https://example.com/privacy" },
      { label: "Terms", href: "https://example.com/terms" },
      { label: "Unsubscribe", href: "https://example.com/unsubscribe" },
      { label: "Help", href: "https://example.com/help" }
    ]
  ) %>
<% end %>
```

## Accessibility
- Uses semantic `table[role="presentation"]` markup to communicate layout-only tables to assistive technology.
- Keep heading hierarchy and link/button text meaningful inside the content block.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
