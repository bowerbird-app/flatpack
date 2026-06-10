# Chart

## Purpose
Render ApexCharts-based visualizations with FlatPack defaults and optional card framing.

## When to use
Use this for dashboard and analytics charts when data is available in ApexCharts-compatible series format.
Use `FlatPack::ChartButtons::Component` as a sibling when you need reusable Turbo Frame filter controls outside the chart card header.

## Class
- `FlatPack::Chart::Component`
- `FlatPack::Chart::DefaultFilterComponent`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `series` | Array or Hash | — | yes | Chart series payload passed to ApexCharts. |
| `type` | Symbol | `:line` | no | One of `:line`, `:bar`, `:area`, `:donut`, `:pie`, `:radar`. |
| `options` | Hash | `{}` | no | ApexCharts options deep-merged over component defaults. |
| `height` | Integer | `280` | no | Chart height in pixels; must be positive. |
| `card` | Boolean | `true` | no | Wraps chart in `FlatPack::Card::Component` with header/body/footer layout. |
| `title` | String, nil | `nil` | no | Optional title shown in card header. |
| `subtitle` | String, nil | `nil` | no | Optional subtitle shown under title. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes for outer container in chart-only mode. |

## Slots
| Slot | Description |
| --- | --- |
| `top_right_slot` | Header action area (for buttons, filters, menus) when `card: true`. |
| `footer` | Card footer content when `card: true`. |

## Variants
- Chart type variant via `type`
- Framed (`card: true`) and inline (`card: false`) rendering
- Axis defaults for line/bar/area/radar and non-axis defaults for donut/pie

## Related Classes
- `FlatPack::Chart::DefaultFilterComponent`: reusable date range + status filter row designed for chart dashboards.

### DefaultFilter Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `start_date_name` | String | `"start_date"` | no | GET/POST param name for the range start date hidden input. |
| `end_date_name` | String | `"end_date"` | no | GET/POST param name for the range end date hidden input. |
| `start_date_value` | String, Date, nil | `nil` | no | Selected start date value passed to DateInput range state. |
| `end_date_value` | String, Date, nil | `nil` | no | Selected end date value passed to DateInput range state. |
| `status_name` | String | `"status"` | no | Form param name for the status select input. |
| `status` | String, nil | `nil` | no | Selected status value. |
| `status_lists` | Array, Hash | — | yes | Select options in any `FlatPack::Select::Component`-supported format. |
| `status_placeholder` | String, nil | `"All statuses"` | no | Placeholder option label for the status select. |

## Example
```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Revenue", data: [44, 55, 57, 56, 61, 58, 63] },
    { name: "Expenses", data: [35, 41, 36, 26, 45, 48, 52] }
  ],
  type: :area,
  title: "Financial Overview",
  subtitle: "Last 7 months"
) do |chart| %>
  <% chart.top_right_slot do %>
    <%= render FlatPack::Button::Component.new(text: "Export", size: :sm, style: :ghost) %>
  <% end %>
<% end %>
```

```erb
<%= form_with url: demo_charts_path, method: :get do %>
  <%= render FlatPack::Chart::DefaultFilterComponent.new(
    start_date_value: params[:start_date],
    end_date_value: params[:end_date],
    status: params[:status],
    status_lists: [["Active", "active"], ["Paused", "paused"], ["Archived", "archived"]]
  ) %>

  <%= render FlatPack::Button::Component.new(text: "Apply filters", type: "submit", size: :sm) %>
<% end %>
```

```erb
<%= render FlatPack::Table::Component.new(data: repositories) do |table| %>
  <% table.column(title: "Repository", html: ->(row) { row[:name] }) %>
  <% table.column(title: "Activity", html: ->(row) {
    render FlatPack::Chart::Component.new(
      type: :area,
      series: [{ name: "Commits", data: row[:activity] }],
      card: false,
      height: 56,
      options: {
        chart: { sparkline: { enabled: true } },
        tooltip: { enabled: false },
        grid: { show: false },
        xaxis: { labels: { show: false }, axisBorder: { show: false }, axisTicks: { show: false } },
        yaxis: { show: false }
      }
    )
  }) %>
<% end %>
```

Use this compact pattern for dense tabular contexts such as repository activity rows. Keep `card: false`, small `height`, and sparkline-style options so the chart reads as a trend indicator instead of a full analytics panel.

## Accessibility
- Provide meaningful `title`/`subtitle` or nearby text that describes chart intent.
- For critical data, provide a tabular or textual alternative outside the chart canvas.
- Avoid relying only on color to communicate state across series.

## Dependencies
- Stimulus controller: `app/javascript/flat_pack/controllers/chart_controller.js` (`flat-pack--chart`).
- ApexCharts import map pin (`import "apexcharts"` via dynamic import in controller).
- `FlatPack::Card::Component` when `card: true`.
- `FlatPack::DateRangeInput::Component` for date-range selection.
- `FlatPack::Select::Component` for status selection options.
