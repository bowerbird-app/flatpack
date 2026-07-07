# Button Group

## Purpose
Render multiple buttons as a single segmented control with shared borders and rounded edges.

## When to use
Use Button Group when a compact row of related actions should look visually connected.

## Class
- Primary: `FlatPack::ButtonGroup::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Add rendered button-like content (typically `FlatPack::Button::Component`). |

## Variants
None.

## Example
```erb
<%= render FlatPack::ButtonGroup::Component.new do |group| %>
  <% group.button(render(FlatPack::Button::Component.new(text: "Day", style: :secondary))) %>
  <% group.button(render(FlatPack::Button::Component.new(text: "Week", style: :secondary))) %>
  <% group.button(render(FlatPack::Button::Component.new(text: "Month", style: :primary))) %>
<% end %>
```

## Accessibility
- Use descriptive button labels because grouping is visual by default.
- Forward `aria-*` attributes via `system_arguments` when needed.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Button::Component`.
