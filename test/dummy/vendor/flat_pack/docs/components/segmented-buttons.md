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
| `style` | Symbol | `:primary` | no | Button style name for the selected segment. Names are the [Button](button.md) style names. Unknown names raise the same `ArgumentError` as Button. |
| `size` | Symbol | `:md` | no | Forwards into each `button(...)` unless that call already passes `size:`. Uses Button sizes (`:sm`, `:md`, `:lg`). |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Creates a `FlatPack::Button::Component` via `text:`, `selected:`, and forwarded button args. `selected: true` uses the group `style`. Other segments stay `:secondary`. A per-segment `style:` raises `ArgumentError`. |

## Variants
- Selected segment uses the group `style`. The default is `:primary`.
- Unselected segments stay `:secondary`.

## Example
```erb
<%= render FlatPack::SegmentedButtons::Component.new(style: :default) do |group| %>
  <% group.button(text: "List") %>
  <% group.button(text: "Grid", selected: true) %>
  <% group.button(text: "Table") %>
<% end %>
```

## Accessibility
- Use clear button labels and indicate current state visually and semantically where needed.
- Forward additional ARIA attributes through forwarded button args as appropriate.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component`.
