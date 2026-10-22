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
| `collapse` | `false`, `:menu` | `false` | no | `false` is the joined row. `:menu` keeps that row from `collapse_at` up and, below it, shows one hamburger trigger. The panel is the same element in both layouts, so each button is in the DOM once. |
| `menu_label` | String, nil | `nil` | no | Visible trigger text when `collapse: :menu`. Also the accessible name of the group. Omit it for an icon-only trigger labelled "Menu". Ignored when `collapse` is `false`. |
| `menu_icon` | String | `"menu"` | no | Heroicon name on the trigger. `"menu"` is the bars glyph. Ignored when `collapse` is `false`. |
| `collapse_at` | Integer | `768` | no | Viewport width, in pixels, where the row replaces the menu. Ignored when `collapse` is `false`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Add rendered button-like content (typically `FlatPack::Button::Component`). |

## Variants
- Joined row (`collapse: false`, the default).
- Collapsing menu (`collapse: :menu`). Wide viewport: joined row, trigger hidden. Narrow viewport: trigger visible, panel hidden until opened, then stacked in a menu. Escape and a click outside close it. A press inside a child dropdown's menu does not. That menu is moved to `document.body` and carries `data-flat-pack-dropdown-owner`, the id of the dropdown root. The group stays open only when that root sits inside the group.
- A `FlatPack::Button::Dropdown::Component` in either joined row takes the segment shape on its trigger, not on the wrapper. That still holds when another element wraps the dropdown. Below `collapse_at` the stacked trigger keeps its own radius. A dropdown outside a button group is unchanged.

## Example — collapsing menu
```erb
<%= render FlatPack::ButtonGroup::Component.new(collapse: :menu, menu_label: "More") do |group| %>
  <% group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Archive", style: :danger)) %>
<% end %>
```

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
- With `collapse: :menu`, the trigger has `aria-expanded`, `aria-controls`, and `aria-haspopup`. The panel is `role="group"` and keeps the buttons' ids. Opening, Escape, and an outside click update `aria-expanded`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Button::Component`.
