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
| `collapse` | `false`, `:menu` | `false` | no | `false` is the joined row. `:menu` keeps that row from `collapse_at` up and, below it, shows one hamburger trigger. The wide row and the phone menu are separate elements. |
| `menu_label` | String, nil | `nil` | no | Visible trigger text when `collapse: :menu`. Also the accessible name of the group. Omit it for an icon-only trigger labelled "Menu". Ignored when `collapse` is `false`. |
| `menu_icon` | String | `"menu"` | no | Heroicon name on the trigger. `"menu"` is the bars glyph. Ignored when `collapse` is `false`. |
| `collapse_at` | Integer | `768` | no | Viewport width, in pixels, where the row replaces the menu. Ignored when `collapse` is `false`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Add rendered button-like content (typically `FlatPack::Button::Component`). |

## Variants
- Joined row (`collapse: false`, the default). The group rounds the outer corners and drops the shared edge on each direct child.
- Collapsing menu (`collapse: :menu`). Wide viewport: the joined row, trigger hidden. Narrow viewport: trigger visible, panel hidden until opened, then one menu. Escape and a click outside close it. A click inside the panel does not.

## Menu row
`collapse: :menu` asks each direct child for `menu_row`. The method returns HTML for the phone menu. The wide row is the child itself.

- `FlatPack::Button::Component#menu_row` is a plain row: the label, `href`, and icon, left aligned, with no button chrome. `style: :danger` is red text (`data-fp-style="danger"`), not a red fill. The wide control keeps `id`, `class`, and the button chrome. `menu_row` does not repeat `id`.
- `FlatPack::Button::Dropdown::Component#menu_row` renders that dropdown as `FlatPack::Menu::Collapse::Component`. The label and icon are the header. The items sit underneath. The wide row is still the floating dropdown. A dropdown outside a button group is unchanged.
- A host component implements the same method. Call it on the same button instance `call` rendered, so the row can use that button's `menu_row`.

A child with no `menu_row`, or whose `menu_row` does not return HTML, is rendered once and that HTML is placed in the row and again in the menu. It keeps its own chrome. The group only shapes the direct child (joined borders, outer corners, spacing). It does not read another component's targets, and it does not build a second copy of a child.

A dropdown joins the row when it is the direct child. Its root takes the segment shape, and its trigger copies that box. A wrapper around the dropdown is the direct child instead. The group does not restyle the trigger inside that wrapper.

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
- With `collapse: :menu`, the trigger has `aria-expanded`, `aria-controls`, and `aria-haspopup`. The wide row and the panel are each `role="group"`. One is hidden at a time. Opening, Escape, and an outside click update `aria-expanded`. Ids stay on the wide controls.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Button::Component`.
- A dropdown child in the phone panel uses `FlatPack::Menu::Collapse::Component`. See `docs/components/menu-collapse.md`.
