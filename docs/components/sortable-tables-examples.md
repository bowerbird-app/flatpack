# Sortable Tables Examples

## Purpose
Provide concise copy-ready examples for sortable and draggable `FlatPack::Table::Component` usage.

## When to use
Use this reference when implementing URL-driven sorting and optional persisted drag reordering.

## Class
- Primary: `FlatPack::Table::Component`
- Related classes: `FlatPack::Table::Column::Component`

## Props
Sorting-focused props:

| name | type | default | required | description |
|---|---|---|---|---|
| `sort` | String | `nil` | no | Current sort key from params. |
| `direction` | String | `nil` | no | Current sort direction (`"asc"` or `"desc"`). |
| `base_url` | String | `nil` | yes for sorting | Base path used for generated sort links. |
| `turbo_frame` | String | `nil` | no | Target frame for Turbo-driven updates. |

Column sorting props:

| name | type | default | required | description |
|---|---|---|---|---|
| `sortable` | Boolean | `false` | no | Enables sort link in header. |
| `sort_key` | Symbol/String | `nil` | yes when sortable | Sort query key for this column. |

Drag reorder props:

| name | type | default | required | description |
|---|---|---|---|---|
| `draggable_rows` | Boolean | `false` | no | Enables row drag behavior. |
| `reorder_url` | String | `nil` | no | PATCH endpoint for persistence. |
| `reorder_strategy` | String | `"dense_integer"` | no | Ordering strategy identifier in payload. |
| `reorder_scope` | Hash | `{}` | no | Optional scope metadata in payload. |
| `reorder_version` | String | `nil` | no | Optional optimistic-lock token. |

## Slots
- `column(...)`: define sortable headers and cell rendering.

## Variants
- Header sorting only.
- Header sorting + Turbo frame updates.
- Drag reorder only.
- Combined sorting and drag reorder.

## Example
```erb
<%= render FlatPack::Table::Component.new(
  data: @users,
  turbo_frame: "users_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: request.path,
  draggable_rows: true,
  reorder_url: demo_tables_reorder_path,
  reorder_scope: { list_key: "users" },
  reorder_version: @version
) do |table| %>
  <% table.column(title: "Name", sortable: true, sort_key: :name, html: ->(u) { u.name }) %>
  <% table.column(title: "Email", sortable: true, sort_key: :email, html: ->(u) { u.email }) %>
<% end %>
```

## Accessibility
- Sortable headers are links and remain keyboard accessible.
- Keep column titles descriptive so sort context is understandable to assistive technology users.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional Turbo Frames for partial-table updates.
- Drag reorder behavior requires Stimulus controller `flat-pack--table-sortable`.
