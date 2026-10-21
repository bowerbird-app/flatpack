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
| `style` | Symbol | omitted | no | Button style name for the selected segment. Omit it and the selected segment uses the neutral active surface on a secondary button. A named [Button](button.md) style, including `:primary`, paints that colour. With `indicator: :slide`, the same `style` paints the sliding indicator instead of the button fill. Unknown names raise the same `ArgumentError` as Button. |
| `size` | Symbol | `:md` | no | Forwards into each `button(...)` unless that call already passes `size:`. Uses Button sizes (`:sm`, `:md`, `:lg`). |
| `indicator` | Symbol | `nil` | no | Omit for the joined button group. `:slide` uses the same pill track and `flat-pack--slide-indicator` controller as [Tabs](tabs.md) `variant: :pills`. Unknown values raise `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Creates a `FlatPack::Button::Component` via `text:`, `selected:`, and forwarded button args (`href:`, `type:`, Stimulus `data`, ARIA). `selected: true` uses the group `style`, or the neutral active surface when `style` is omitted. Other segments stay `:secondary`. A per-segment `style:` raises `ArgumentError`. With `indicator: :slide`, every segment stays a button and `selected: true` sets `aria-pressed="true"`. |

## Variants
- Selected segment uses the group `style`. Omit `style:` for the neutral active surface (`.fp-button-current` on a secondary button).
- Unselected segments stay `:secondary`.
- `indicator: :slide` replaces the joined borders with the pill track. Omit `style:` for the neutral grey indicator. A named style, including `:primary`, paints the indicator that button colour.

## Example
```erb
<%= render FlatPack::SegmentedButtons::Component.new(style: :default) do |group| %>
  <% group.button(text: "List") %>
  <% group.button(text: "Grid", selected: true) %>
  <% group.button(text: "Table") %>
<% end %>
```

`indicator: :slide` keeps each option a button. A click moves the indicator, sets `aria-pressed`, then dispatches `flat-pack--segmented-buttons:change` on the group. `detail` is `{ index, button }`. Call `preventDefault()` on that event to leave the indicator on the previous option. The button's link, submit, or Stimulus action still runs.

```erb
<%= render FlatPack::SegmentedButtons::Component.new(indicator: :slide, style: :primary) do |group| %>
  <% group.button(text: "Day", selected: true) %>
  <% group.button(text: "Week") %>
  <% group.button(text: "Month") %>
<% end %>
```

## Accessibility
- Use clear button labels and indicate current state visually and semantically where needed.
- Forward additional ARIA attributes through forwarded button args as appropriate.
- `indicator: :slide` sets `aria-pressed` from `selected:`. The indicator element is `aria-hidden`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Uses `FlatPack::Button::Component`.
- `indicator: :slide` uses the existing `flat-pack--slide-indicator` controller. No new pin.
