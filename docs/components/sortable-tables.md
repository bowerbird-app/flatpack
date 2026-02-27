# Sortable Tables

## Purpose
Document how to enable sortable table headers and optional drag-and-drop row persistence with `FlatPack::Table::Component`.

## When to use
Use this pattern when users need URL-driven column sorting and/or persisted manual row reordering.

## Class
- Primary: `FlatPack::Table::Component`
- Related classes: `FlatPack::Table::Column::Component`

## Props

Sortable header behavior (table-level):

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `sort` | String | `nil` | No | Current sort key for active header indicator logic. |
| `direction` | String | `nil` | No | Current sort direction (`"asc"`/`"desc"`). |
| `base_url` | String | `nil` | No | Base URL used to build sortable header links. If missing, sortable columns render plain text headers. |
| `turbo_frame` | String | `nil` | No | Wraps table in `<turbo-frame>` and is forwarded to sort links (`data-turbo-frame`). |

Sortable column behavior (`column` slot):

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `sortable` | Boolean | `false` | No | Enables sort link behavior for this column. |
| `sort_key` | Symbol/String | `nil` | No | Query value written into `sort` param when sortable is enabled. |

Drag-and-drop persistence behavior:

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `draggable_rows` | Boolean | `false` | No | Enables row dragging via `flat-pack--table-sortable`. |
| `reorder_url` | String | `nil` | No | PATCH endpoint for reorder persistence. |
| `reorder_resource` | String | inferred | No | Payload resource key. |
| `reorder_strategy` | String | `"dense_integer"` | No | Payload strategy key. |
| `reorder_scope` | Hash | `{}` | No | Payload scope metadata. |
| `reorder_version` | String | `nil` | No | Optimistic concurrency token in payload. |
| `row_id` | Proc/Symbol | `row.id` fallback | No | Row identifier resolver for ordered item ids. |

## Slots
Use `table.column(...)` definitions. Sort behavior is controlled per-column with `sortable` and `sort_key`.

## Variants

| variant | description |
|---------|-------------|
| Header sorting only | Set `sortable: true` on columns and pass `base_url` (plus optional `sort`, `direction`). |
| Turbo-frame sorting | Add `turbo_frame` so link clicks update frame content without full-page reload. |
| Drag reorder only | Set `draggable_rows: true` and configure `reorder_*` props. |
| Combined sorting + reorder | Supported together; sorting uses links, reorder uses drag events/persistence endpoint. |

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

Drag reorder payload contract sent by `flat-pack--table-sortable`:

```json
{
  "reorder": {
    "resource": "demo_table_rows",
    "strategy": "dense_integer",
    "scope": { "list_key": "users" },
    "version": "1739990000.12",
    "items": [
      { "id": 7, "position": 1 },
      { "id": 4, "position": 2 }
    ]
  }
}
```

## Accessibility
Sortable headers are rendered as links, so they are keyboard-focusable and activate with standard link keyboard behavior. Keep header text descriptive for assistive technologies.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional Turbo Frames for partial updates.
- Drag reorder requires Stimulus controller `flat-pack--table-sortable` (enabled by `draggable_rows: true`).
