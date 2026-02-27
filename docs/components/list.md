# List

## Purpose
Render semantic ordered or unordered lists with optional spacing, divider, and selectable behavior.

## When to use
Use List when grouped items need consistent spacing and optional active-item selection handling.

## Class
- Primary: `FlatPack::List::Component`
- Related classes: `FlatPack::List::Item`

## Props
`FlatPack::List::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `ordered` | Boolean | `false` | no | Renders `<ol>` when true, otherwise `<ul>`. |
| `spacing` | Symbol | `:comfortable` | no | Vertical spacing preset; `:dense` uses tighter spacing, other values use comfortable spacing. |
| `divider` | Boolean | `false` | no | Adds row separators using `divide-y`. |
| `selectable` | Boolean | `false` | no | Enables active-item behavior via `flat-pack--list-selectable`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for list element. |

`FlatPack::List::Item`:

| name | type | default | required | description |
|---|---|---|---|---|
| `icon` | Symbol/String | `nil` | no | Leading icon; string values starting with `<svg` render inline SVG. |
| `leading` | String | `nil` | no | Custom leading content text. |
| `trailing` | String | `nil` | no | Trailing content text. |
| `href` | String | `nil` | no | Optional link URL. Sanitized and validated; unsafe URLs raise `ArgumentError`. |
| `hover` | Boolean | `false` | no | Enables hover background styling. |
| `active` | Boolean | `false` | no | Applies active item background styling. |
| `link_arguments` | Hash | `{}` | no | Extra attributes merged into internal link when `href` is present. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for `<li>`. |

## Slots
None.

## Variants
- Ordered vs unordered (`ordered: true/false`).
- Spacing variants via `spacing`.
- Selectable behavior via `selectable: true`.

## Example
```erb
<%= render FlatPack::List::Component.new(ordered: false, selectable: true, divider: true) do %>
  <%= render FlatPack::List::Item.new(icon: :check, href: "/tasks/1") { "First task" } %>
  <%= render FlatPack::List::Item.new(icon: :clock, href: "/tasks/2") { "Second task" } %>
<% end %>
```

## Accessibility
- List renders semantic `<ul>`/`<ol>` with `role="list"`.
- Items render `<li role="listitem">`.
- Selectable mode sets `aria-current="page"` on active links.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional selectable mode requires Stimulus controller `flat-pack--list-selectable`.
