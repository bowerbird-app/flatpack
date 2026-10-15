# Table

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
| `min_width` | Symbol/String/nil | `:md` | No | Minimum table width so narrow viewports scroll the wrapper instead of squashing columns. Accepts `:none`, `:sm` (30rem), `:md` (40rem), `:lg` (48rem), or a Tailwind `min-w-*` class String. Independent of a column `min_width:`. |
| `headers` | Boolean | `true` | No | When `false`, the header row stays in the DOM and is visually hidden with `sr-only`. Column `title:` stays required. Anything other than `true` or `false` raises `ArgumentError`. |
| `style` | Symbol | `:default` | No | `:default` keeps the outer border, radius, and row hover. `:plain` drops all three. A checked control inside a default row paints `--table-row-selected-background-color` and keeps it on hover. Same param name as Button, Badge, and Card. Anything else raises `ArgumentError`. |
| `dividers` | Boolean | `true` | No | `true` draws the header rule and the row lines. `false` removes both. Anything other than `true` or `false` raises `ArgumentError`. |
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
| `title` | String | Yes | Header text for the column. Still required when `headers: false`. |
| `html` | Proc | No | Cell renderer proc called with each row. Optional when block is provided. |
| `sortable` | Boolean | No | Enables sortable header behavior for this column. |
| `sort_key` | Symbol/String | No | Key written into sort query string for sortable headers. |
| `width` | Symbol/String | No | `:fit` shrinks to content, `:fill` takes remaining space, or a CSS length such as `"12rem"`. Widths render on `<col>`. A length uses `table-layout: fixed` unless a sibling is `:fit` (fixed layout would clip that column). The length is still a cap via `max-width` on the header and cells. |
| `min_width` | String | No | CSS length such as `"8rem"`. Applied to the header and cells. Not the table scroll floor. |
| `max_width` | String | No | CSS length cap for the header and cells. |
| `align` | Symbol | `:start` | `:start`, `:center`, or `:end`. Logical alignment on the header and cells, so RTL flips start and end. |
| `wrap` | Symbol | `:wrap` | `:wrap`, `:nowrap`, or `:truncate`. `:truncate` clips with an ellipsis and sets `title` to the full text. On a `:fill` column the cell cap is `max-width: 0`, so the ellipsis uses the leftover space. |
| `hide_below` | Symbol | No | `:sm`, `:md`, `:lg`, or `:xl`. Hides the header and cells below that breakpoint. The column stays in the markup, so `colspan` still counts it. |

When both block and `html` are provided, `html` is used. When neither is provided, cells render empty strings.

## Variants

| variant | description |
|---------|-------------|
| Sortable headers | Set column `sortable: true` and provide `base_url` on table component. |
| Turbo frame wrapper | Provide `turbo_frame:` to wrap output in `<turbo-frame>`. |
| Stimulus table | Set `stimulus: true` to attach `flat-pack--table`. |
| Draggable reorder | Set `draggable_rows: true` and optionally `reorder_*` options. |
| Visually hidden headers | Set `headers: false`. The `<thead>` keeps each column `title` for screen readers and is hidden with the Tailwind `sr-only` class. |
| Plain frame | Set `style: :plain` to drop the outer border, radius, and row hover. |
| No row lines | Set `dividers: false`. |
| Fitted, fixed, and fill columns | Set column `width:` to `:fit`, a CSS length, or `:fill`. A length uses `table-layout: fixed` when no column is `:fit`. Beside `:fit`, automatic layout keeps the shrink, and `max-width` holds the length. Table `min_width:` still sets the scroll floor. |
| Clipped cell | Set `wrap: :truncate`. Hover shows the full text. A length `width:` gives the ellipsis a bound. |
| Column hidden on a phone | Set `hide_below:` to `:sm`, `:md`, `:lg`, or `:xl`. |
| URL-driven filter/search controls | Compose sibling controls (for example `FlatPack::ChartButtons::Component` and `FlatPack::Search::Component`) around the table and submit GET params into a shared Turbo Frame. |
| Inline mini charts | Render `FlatPack::Chart::Component` in a column `html` lambda for sparkline activity cells in dense rows. |

## Filter And Search Pattern

Use sibling controls as a separate surface around the table and keep all state in query params. This makes links shareable and keeps Turbo updates predictable.

```erb
<%= turbo_frame_tag "users-table-filters" do %>
  <%= render FlatPack::ChartButtons::Component.new(turbo_frame: "users-table-filters") do |controls| %>
    <% controls.button(text: "All", href: demo_tables_basic_path(filter_field: "status", filter_value: "all", q: params[:q]), selected: params[:filter_value] == "all") %>
    <% controls.dropdown(text: "Status", options: [
      {text: "Active", url: demo_tables_basic_path(filter_field: "status", filter_value: "active", q: params[:q])},
      {text: "Inactive", url: demo_tables_basic_path(filter_field: "status", filter_value: "inactive", q: params[:q])}
    ]) %>
  <% end %>

  <%= form_with url: demo_tables_basic_path, method: :get, data: {turbo_frame: "users-table-filters"} do %>
    <%= hidden_field_tag :filter_field, "status" %>
    <%= hidden_field_tag :filter_value, params[:filter_value] %>
    <%= render FlatPack::Search::Component.new(name: "q", value: params[:q], placeholder: "Search table rows...", max_width: :none) %>
  <% end %>

  <%= render FlatPack::Table::Component.new(data: @users) do |table| %>
    <% table.column(title: "Name", html: ->(user) { user.name }) %>
    <% table.column(title: "Email", html: ->(user) { user.email }) %>
  <% end %>
<% end %>
```

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

```erb
<%= render FlatPack::Table::Component.new(data: @users, headers: false) do |table| %>
  <% table.column(title: "Name") { |user| user.name } %>
  <% table.column(title: "Email") { |user| user.email } %>
<% end %>
```

```erb
<%= render FlatPack::Table::Component.new(data: rows, headers: false, style: :plain, min_width: :none) do |table| %>
  <% table.column(title: "Icon", width: :fit, align: :center, wrap: :nowrap) { |row| row.icon } %>
  <% table.column(title: "Key", width: "8rem", wrap: :nowrap) { |row| row.key } %>
  <% table.column(title: "Value", width: :fill) { |row| row.value } %>
<% end %>
```

## Accessibility
Uses semantic table markup (`table`, `thead`, `tbody`, `th`, `td`, and `colgroup` when a column sets width, min width, max width, or `hide_below`). Sort indicators are visual arrows in sortable headers; provide meaningful header labels for screen-reader clarity. `headers: false` keeps that `<thead>` in the accessibility tree and hides it with `sr-only`. Do not drop `title:` to hide a column name. `align:` uses logical start and end. `hide_below:` removes the header and cells from the accessibility tree below that breakpoint. `wrap: :truncate` puts the full cell text in the `title` attribute.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Optional sort-link behavior depends on `base_url`, `sort`, and `direction` values.
- Optional drag-and-drop behavior requires Stimulus controller `flat-pack--table-sortable` (added by `draggable_rows: true`).
