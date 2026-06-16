# List

## Purpose
Render semantic ordered or unordered lists with optional spacing, divider, selectable behavior, and drag-to-reorder support.

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
| `spacing` | Symbol | `:comfortable` | no | Vertical spacing preset; `:dense` uses tighter spacing, other values use comfortable spacing. Ignored when `divider: true`. |
| `divider` | Boolean | `false` | no | Adds row separators using `divide-y` and omits vertical spacing so items sit flush against dividers. |
| `selectable` | Boolean | `false` | no | Enables active-item behavior via `flat-pack--list-selectable`. |
| `orderable` | Boolean | `false` | no | Enables drag-and-drop reordering via `flat-pack--list-orderable`. |
| `orderable_path` | String | `nil` | no | PATCH/PUT endpoint used to persist the new item position after drop. |
| `orderable_method` | String/Symbol | `:patch` | no | Request method sent by the orderable controller. |
| `param_uuid_name` | String | `"id"` | no | Form field name used for the dragged item UUID in orderable requests. |
| `param_target_position_name` | String | `"position"` | no | Form field name used for the destination position in orderable requests. |
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
- Orderable behavior via `orderable: true` and `orderable_path:`.

## Example
```erb
<%= render FlatPack::List::Component.new(ordered: false, selectable: true, divider: true) do %>
  <%= render FlatPack::List::Item.new(icon: :check, href: "/tasks/1") { "First task" } %>
  <%= render FlatPack::List::Item.new(icon: :clock, href: "/tasks/2") { "Second task" } %>
<% end %>
```

```erb
<%= render FlatPack::List::Component.new(
  orderable: true,
  orderable_path: patch_path,
  param_uuid_name: "moving_recording_id",
  param_target_position_name: "target_position"
) do %>
  <%= render FlatPack::List::Item.new(id: "2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11") { "First task" } %>
  <%= render FlatPack::List::Item.new(id: "44d7b3a8-9a16-4f34-8c7a-9f0c8cb2f3f2") { "Second task" } %>
<% end %>
```

The orderable controller sends a form-encoded payload shaped like:

```text
moving_recording_id=2b6f8d0d-3c1b-4ec0-9ed0-7a5d8d3b4e11&target_position=2
```

## Events
- `list:reordered` fires immediately after the DOM order changes, with `detail.id` and `detail.position` for the dragged item.
- `list:saved` fires after the backend returns `ok: true`.
- `list:error` fires when the backend rejects the update or the request fails.

## Accessibility
- List renders semantic `<ul>`/`<ol>` with `role="list"`.
- Items render `<li role="listitem">`.
- Selectable mode sets `aria-current="page"` on active links.
- Orderable mode expects stable item IDs so the controller can persist the dragged item's UUID and destination position.
- Orderable mode can customize the request parameter names with `param_uuid_name` and `param_target_position_name`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional selectable mode requires Stimulus controller `flat-pack--list-selectable`.
- Optional orderable mode requires Stimulus controller `flat-pack--list-orderable`.
