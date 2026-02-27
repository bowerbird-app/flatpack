# Segmented Buttons

## Purpose
Compose multiple buttons into a compact segmented selector with selected/unselected styling.

## When to use
Use Segmented Buttons for small mutually-related action sets such as view mode or time-range switching.

## Class
- Primary: `FlatPack::SegmentedButtons::Component`
- Related classes: `FlatPack::Button::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` (`with_button`) | slot | no | Creates a `FlatPack::Button::Component` via `text:`, `selected:`, and forwarded button args. |

## Variants
- Per-button selected state: `selected: true` uses button `style: :primary`; otherwise `:secondary`.

## Example
```erb
<%= render FlatPack::SegmentedButtons::Component.new do |group| %>
  <% group.with_button(text: "Day") %>
  <% group.with_button(text: "Week", selected: true) %>
  <% group.with_button(text: "Month") %>
<% end %>
```

## Accessibility
- Use clear button labels and indicate current state visually and semantically where needed.
- Forward additional ARIA attributes through forwarded button args as appropriate.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component`.
