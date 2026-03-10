# Table Component

## Purpose
Render tabular data with composable column definitions, optional sorting links, and optional drag-and-drop row reordering.

## When to use
Use Table for datasets that need consistent headers, rows, formatting, and optional sorting/actions.

## Class
- Primary: `FlatPack::Table::Component`
- Related classes: `FlatPack::Table::Column::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `data` | Array | `[]` | No | Collection rendered as table rows. |
| `stimulus` | Boolean | `false` | No | Adds `flat-pack--table` Stimulus controller to the table wrapper. |
| `turbo_frame` | String | `nil` | No | Wraps the table output in `<turbo-frame id="...">`. |
| `sort` | String | `nil` | No | Current sort key used to render active header state/indicator. |
| `direction` | String | `nil` | No | Current sort direction (`"asc"` or `"desc"`). |
| `base_url` | String | `nil` | No | Base URL used by sortable headers to build sort links. |
| `tbody_class` | String | `nil` | No | Extra class merged into `<tbody>`. |
| `tbody_data` | Hash | `nil` | No | Data attributes applied to `<tbody>`. |
| `draggable_rows` | Boolean | `false` | No | Adds `flat-pack--table-sortable` controller and draggable row data hooks. |
| `reorder` | Hash | `nil` | No | Optional hash override for reorder settings (`url`, `resource`, `strategy`, `scope`, `version`, `row_id`). |
| `reorder_url` | String | `nil` | No | PATCH endpoint used by sortable controller to persist order. |
| `reorder_resource` | String | inferred | No | Resource key sent in reorder payload (defaults from sample row class/table name when possible). |
| `reorder_strategy` | String | `"dense_integer"` | No | Strategy key sent in reorder payload. |
| `reorder_scope` | Hash | `{}` | No | Scope metadata included in reorder payload. |
| `reorder_version` | String | `nil` | No | Version token included in reorder payload for conflict handling. |
| `row_id` | Proc or Symbol | `->(row) { row.id }` | No | Resolver used to populate row `data-id` for reorder tracking. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into wrapper element. |

## Slots

`columns` (`renders_many`) via `column`:

| name | type | required | description |
|------|------|----------|-------------|
| `title` | String | Yes | Header text for the column. |
| `html` | Proc | No | Cell renderer proc called with each row. Optional when block is provided. |
| `sortable` | Boolean | No | Enables sortable header behavior for this column. |
| `sort_key` | Symbol/String | No | Key written into sort query string for sortable headers. |

When both block and `html` are provided, `html` is used. When neither is provided, cells render empty strings.

## Variants

| variant | description |
|---------|-------------|
| Sortable headers | Set column `sortable: true` and provide `base_url` on table component. |
| Turbo frame wrapper | Provide `turbo_frame:` to wrap output in `<turbo-frame>`. |
| Stimulus table | Set `stimulus: true` to attach `flat-pack--table`. |
| Draggable reorder | Set `draggable_rows: true` and optionally `reorder_*` options. |

## Example

```erb
<%= render FlatPack::Table::Component.new(
  data: @users,
  turbo_frame: "users_table",
  sort: params[:sort],
  direction: params[:direction],
  base_url: request.path
) do |table| %>
  <% table.column(title: "Name", sortable: true, sort_key: :name) { |user| user.name } %>
  <% table.column(title: "Email", html: ->(user) { user.email }) %>
<% end %>
```

## Accessibility
Uses semantic table markup (`table`, `thead`, `tbody`, `th`, `td`). Sort indicators are visual arrows in sortable headers; provide meaningful header labels for screen-reader clarity.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional sort-link behavior depends on `base_url`, `sort`, and `direction` values.
- Optional drag-and-drop behavior requires Stimulus controller `flat-pack--table-sortable` (added by `draggable_rows: true`).
