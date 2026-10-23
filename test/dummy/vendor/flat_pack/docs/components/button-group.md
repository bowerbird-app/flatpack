# Button Group

## Purpose
Render multiple buttons as one row. `:joined` merges them into a segmented control. `:outlined` keeps each child's own look inside a bordered container.

## When to use
Use Button Group when a compact row of related actions belongs together. Use `:joined` when they should share one edge. Use `:outlined` when each action should keep its own shape, such as ghost links in a quiet frame.

## Class
- Primary: `FlatPack::ButtonGroup::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `variant` | `:joined`, `:outlined` | `:joined` | no | `:joined` merges direct children into one segmented control. `:outlined` draws one bordered container on the wide row, with a small gap, and leaves each child's border, radius, and fill alone. The container radius is `--button-group-radius`. Anything else raises `ArgumentError`. |
| `collapse` | `false`, `:menu` | `false` | no | `false` keeps the row. `:menu` keeps that row from `collapse_at` up and, below it, shows one hamburger trigger. The wide row and the phone menu are separate elements. The phone menu is the same for both variants. |
| `menu_label` | String, nil | `nil` | no | Visible trigger text when `collapse: :menu`. Also the accessible name of the group. Omit it for an icon-only trigger labelled "Menu". Ignored when `collapse` is `false`. |
| `menu_icon` | String | `"menu"` | no | Heroicon name on the trigger. `"menu"` is the bars glyph. Ignored when `collapse` is `false`. |
| `collapse_at` | Integer | `768` | no | Viewport width, in pixels, where the row replaces the menu. Ignored when `collapse` is `false`. |
| `visible` | Integer, nil | `nil` | no | How many children stay in the joined row, counting from the first. The rest go in the overflow menu. `nil` keeps every child that did not pass `overflow: true`. `0` parks every child that did not pass `overflow: false`. A negative number, or anything that is not a whole number, raises `ArgumentError`. |
| `overflow_label` | String, nil | `nil` | no | Visible text on the overflow trigger. Omit it, or pass a blank string, and the trigger is the icon alone. Its accessible name is the locale string "More" (`aria-label`). A label is followed by the trailing icon. There is no leading icon. The trigger is secondary when `variant` is `:joined`, and ghost when it is `:outlined`. |
| `overflow_icon` | String, Symbol, nil | `nil` | no | Heroicon on the overflow trigger. Omit it and the icon is `ellipsis-horizontal` when there is no label, and `chevron-down` when there is one. An explicit name replaces that default and keeps the same place: alone, or after the label. A symbol is accepted. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the group wrapper. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `button` | slot | no | Add rendered button-like content (typically `FlatPack::Button::Component`). `overflow: true` forces that child into the overflow menu. `overflow: false` keeps it in the row. Omit it and `visible` decides. Anything other than `true`, `false`, or omitted raises `ArgumentError`. |

## Variants
- Joined (`variant: :joined`, the default). The group rounds the outer corners and drops the shared edge on each direct child. The overflow trigger is secondary.
- Outlined (`variant: :outlined`). Desktop only. One border in `--surface-border-color`, small padding, and a small gap. No merged borders, no edge stripping, and no zeroed inner radii. The container radius is `--button-group-radius`: `--radius-md` on the default theme, `--radius-full` (a pill) on rounded. Pass `style: :ghost` on each button when they should read as links. Ghost hover follows `--button-border-radius` on the button, which is the same pill on rounded. The group does not restyle the button. The overflow trigger is ghost.
- Collapsing menu (`collapse: :menu`). Wide viewport: the row for the chosen variant, hamburger hidden. Narrow viewport: hamburger visible, panel hidden until opened, then one menu. Escape and a click outside close it. A click inside the panel does not. The phone menu does not draw the outline.
- Overflow menu. The first `visible` children stay in the row. The rest sit in a trailing dropdown. `overflow: true` on a child puts it in that menu even when it is among the first `visible`. `overflow: false` keeps it in the row even when it comes later. Visible children keep their order. Overflow children keep theirs. With `collapse: :menu`, the phone menu still lists every child once, in the order they were added. The overflow dropdown is part of the wide row, so it is hidden on a phone. Without `collapse: :menu`, the overflow dropdown stays in the row.

## Menu row
`collapse: :menu` asks each direct child for `menu_row`. The overflow menu asks the same method. The method returns HTML for that menu. The wide row is the child itself.

- `FlatPack::Button::Component#menu_row` is a plain row: the label, `href`, and icon, left aligned, with no button chrome. `style: :danger` is red text (`data-fp-style="danger"`), not a red fill. The wide control keeps `id`, `class`, and the button chrome. `menu_row` does not repeat `id`.
- `FlatPack::Button::Dropdown::Component#menu_row` renders that dropdown as `FlatPack::Menu::Collapse::Component`. The label and icon are the header. The items sit underneath. The wide row is still the floating dropdown. A dropdown outside a button group is unchanged.
- A host component implements the same method. Call it on the same button instance `call` rendered, so the row can use that button's `menu_row`.

A child with no `menu_row`, or whose `menu_row` does not return HTML, is rendered once. That HTML is the wide control when the child stays in the row, and the overflow body when it does not. With `collapse: :menu` the same HTML is also the phone row. It keeps its own chrome. The group only shapes the direct child (joined borders, outer corners, spacing). It does not read another component's targets, and it does not build a second copy of a child.

A dropdown joins the row when it is the direct child. Its root takes the segment's outer radius and does not paint a border. The trigger copies that radius and draws the edge, in the button's own border color. A wrapper around the dropdown is the direct child instead. The group does not restyle the trigger inside that wrapper.

## Example — outlined
```erb
<%= render FlatPack::ButtonGroup::Component.new(variant: :outlined) do |group| %>
  <% group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Share", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :ghost, size: :sm)) %>
<% end %>
```

The same frame with overflow. Edit and Share stay in the row. Omit `overflow_label` and the trigger is an ellipsis, named "More". Pass `overflow_label: "More"` and the word sits in front of a chevron.

```erb
<%= render FlatPack::ButtonGroup::Component.new(variant: :outlined, visible: 2) do |group| %>
  <% group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Share", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Archive", style: :ghost, size: :sm)) %>
<% end %>

<%= render FlatPack::ButtonGroup::Component.new(variant: :outlined, visible: 2, overflow_label: "More") do |group| %>
  <% group.button(FlatPack::Button::Component.new(text: "Edit", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Share", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :ghost, size: :sm)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Archive", style: :ghost, size: :sm)) %>
<% end %>
```

## Example — overflow
```erb
<%= render FlatPack::ButtonGroup::Component.new(visible: 2, collapse: :menu) do |group| %>
  <% group.button(FlatPack::Button::Component.new(text: "Rename", style: :secondary)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Delete", style: :danger), overflow: true) %>
  <% group.button(FlatPack::Button::Component.new(text: "Share", style: :secondary)) %>
  <% group.button(FlatPack::Button::Component.new(text: "Duplicate", style: :secondary), overflow: false) %>
<% end %>
```

Rename and Duplicate stay in the row. Delete and Share sit under More. On a phone, the single menu is Rename, Delete, Share, Duplicate.

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
- The overflow trigger uses the dropdown's `aria-haspopup` and `aria-expanded`. With no `overflow_label`, the icon is the only visible content and `aria-label` is the locale string "More". With a label, that text is visible and the icon follows it. Choosing a row closes that menu. A nested dropdown is a `Menu::Collapse` section, so its header stays open while it expands. Rows are links and buttons, so Tab reaches them. `style: :danger` is red text.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Typically composed with `FlatPack::Button::Component`.
- A dropdown child in the phone panel uses `FlatPack::Menu::Collapse::Component`. See `docs/components/menu-collapse.md`.
